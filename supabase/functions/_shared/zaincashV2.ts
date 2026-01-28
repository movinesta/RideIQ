import { envTrim } from './config.ts';
import {
  CURRENCY_IQD,
  DEFAULT_ZAINCASH_LANGUAGE,
  DEFAULT_ZAINCASH_SCOPE,
  ZAINCASH_OAUTH_PATH,
  ZAINCASH_V2_INIT_PATH,
  ZAINCASH_V2_INQUIRY_PREFIX,
} from './constants.ts';

export type ZaincashV2Config = {
  baseUrl: string;
  clientId: string;
  clientSecret: string;
  apiKey: string;
  scope: string;
  language: 'En' | 'Ar' | 'Ku';
  serviceType: string;
};

function mustEnv(name: string): string {
  const v = envTrim(name);
  if (!v) throw new Error(`Missing ${name}`);
  return v;
}

export function getZaincashV2Config(): ZaincashV2Config {
  const baseUrl = mustEnv('ZAINCASH_V2_BASE_URL').replace(/\/$/, '');
  const clientId = mustEnv('ZAINCASH_V2_CLIENT_ID');
  const clientSecret = mustEnv('ZAINCASH_V2_CLIENT_SECRET');
  const apiKey = mustEnv('ZAINCASH_V2_API_KEY');
  const scope = envTrim('ZAINCASH_V2_SCOPE') || DEFAULT_ZAINCASH_SCOPE;
  const languageRaw = (envTrim('ZAINCASH_V2_LANGUAGE') || DEFAULT_ZAINCASH_LANGUAGE) as string;
  const language = (['En', 'Ar', 'Ku'].includes(languageRaw) ? languageRaw : 'En') as ZaincashV2Config['language'];
  const serviceType = mustEnv('ZAINCASH_V2_SERVICE_TYPE');

  return { baseUrl, clientId, clientSecret, apiKey, scope, language, serviceType };
}

type TokenCache = { token: string; expiresAtMs: number };
let tokenCache: TokenCache | null = null;

function safeJsonParse(txt: string): any {
  try {
    return JSON.parse(txt);
  } catch {
    return null;
  }
}

function getPath(obj: any, path: string): any {
  if (!obj || typeof obj !== 'object') return undefined;
  const parts = path.split('.');
  let cur: any = obj;
  for (const p of parts) {
    if (!cur || typeof cur !== 'object') return undefined;
    cur = cur[p];
  }
  return cur;
}

function pickFirst(obj: any, paths: string[]): string {
  for (const p of paths) {
    const v = getPath(obj, p);
    if (v === null || v === undefined) continue;
    const s = String(v).trim();
    if (s) return s;
  }
  return '';
}

class ZaincashV2Error extends Error {
  status?: number;
  body?: any;
  constructor(message: string, opts?: { status?: number; body?: any }) {
    super(message);
    this.name = 'ZaincashV2Error';
    if (opts) {
      this.status = opts.status;
      this.body = opts.body;
    }
  }
}

async function fetchJson(url: string, init: RequestInit): Promise<any> {
  const res = await fetch(url, init);
  const txt = await res.text();
  const data = safeJsonParse(txt) ?? { raw: txt };
  if (!res.ok) {
    const msg = (data && (data.message || data.error_description || data.error))
      ? String(data.message || data.error_description || data.error)
      : `HTTP ${res.status}`;
    throw new ZaincashV2Error(msg, { status: res.status, body: data });
  }
  return data;
}

export async function zaincashV2GetAccessToken(cfg: ZaincashV2Config): Promise<string> {
  const now = Date.now();
  if (tokenCache && tokenCache.expiresAtMs > now + 30_000) return tokenCache.token;

  const body = new URLSearchParams({
    grant_type: 'client_credentials',
    client_id: cfg.clientId,
    client_secret: cfg.clientSecret,
    scope: cfg.scope,
  });

  const data = await fetchJson(`${cfg.baseUrl}${ZAINCASH_OAUTH_PATH}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body,
  });

  const token = String(data.access_token || '').trim();
  const expiresIn = Number(data.expires_in || 0);
  if (!token) throw new ZaincashV2Error('Missing access_token in token response', { status: 200, body: data });

  // refresh 60s early
  const expiresAtMs = now + Math.max(30, expiresIn - 60) * 1000;
  tokenCache = { token, expiresAtMs };

  return token;
}

export type ZaincashV2InitInput = {
  externalReferenceId: string;
  orderId: string;
  amountIQD: number;
  customerPhone?: string | null;
  successUrl: string;
  failureUrl: string;
};

export async function zaincashV2InitPayment(cfg: ZaincashV2Config, input: ZaincashV2InitInput): Promise<{ transactionId: string; redirectUrl: string; raw: any }> {
  const token = await zaincashV2GetAccessToken(cfg);

  const payload: any = {
    language: cfg.language,
    externalReferenceId: input.externalReferenceId,
    orderId: input.orderId,
    serviceType: cfg.serviceType,
    amount: { value: input.amountIQD, currency: CURRENCY_IQD },
    redirectUrls: {
      successUrl: input.successUrl,
      failureUrl: input.failureUrl,
    },
  };

  if (input.customerPhone) {
    payload.customer = { phone: input.customerPhone };
  }

  const data = await fetchJson(`${cfg.baseUrl}${ZAINCASH_V2_INIT_PATH}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const transactionId = pickFirst(data, [
    'transactionId',
    'transaction_id',
    'id',
    'data.transactionId',
    'data.transaction_id',
    'data.id',
    'result.transactionId',
    'result.transaction_id',
    'result.id',
    'transaction.transactionId',
    'transaction.transaction_id',
    'transaction.id',
  ]);

  const redirectUrl = pickFirst(data, [
    'redirectUrl',
    'redirect_url',
    'paymentUrl',
    'payment_url',
    'url',
    'data.redirectUrl',
    'data.redirect_url',
    'data.paymentUrl',
    'data.payment_url',
    'data.url',
    'result.redirectUrl',
    'result.redirect_url',
    'result.paymentUrl',
    'result.payment_url',
    'result.url',
  ]);

  if (!transactionId || !redirectUrl) {
    throw new ZaincashV2Error('Unexpected init response (missing transactionId/redirectUrl)', { status: 200, body: data });
  }

  return { transactionId, redirectUrl, raw: data };
}

export async function zaincashV2Inquiry(cfg: ZaincashV2Config, transactionId: string): Promise<{ status: string; raw: any }> {
  const token = await zaincashV2GetAccessToken(cfg);
  const data = await fetchJson(`${cfg.baseUrl}${ZAINCASH_V2_INQUIRY_PREFIX}${encodeURIComponent(transactionId)}`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });

  const status = String(
    data.status ||
      data.transactionStatus ||
      data.transaction_status ||
      data.transaction?.status ||
      data.data?.status ||
      ''
  ).toUpperCase();

  return { status, raw: data };
}
