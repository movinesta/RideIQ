import { envTrim } from './config.ts';
import {
  CURRENCY_IQD,
  DEFAULT_ZAINCASH_LANGUAGE,
  DEFAULT_ZAINCASH_SCOPE,
  DEFAULT_HTTP_TIMEOUT_MS,
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
  // ZainCash docs mention an "API key" used for HS256 JWT verification.
  // In practice, some merchants (especially in UAT) are provided only client_secret.
  // To avoid blocking payment initialization, fall back to clientSecret when ZAINCASH_V2_API_KEY is not set.
  const apiKey = envTrim('ZAINCASH_V2_API_KEY') || clientSecret;
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

async function fetchJson(url: string, init: RequestInit, timeoutMs = DEFAULT_HTTP_TIMEOUT_MS): Promise<any> {
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), Math.max(1, timeoutMs));

  let res: Response;
  let txt = '';
  try {
    res = await fetch(url, { ...init, signal: controller.signal });
    txt = await res.text();
  } catch (e) {
    const err = new Error(e instanceof Error ? e.message : String(e));
    (err as any).status = 0;
    (err as any).body = { raw: txt };
    (err as any).url = url;
    (err as any).method = (init.method ?? 'GET').toUpperCase();
    (err as any).is_network_error = true;
    throw err;
  } finally {
    clearTimeout(t);
  }

  const data = safeJsonParse(txt) ?? { raw: txt };
  if (!res.ok) {
    const msg = (data && (data.message || data.error_description || data.error))
      ? String(data.message || data.error_description || data.error)
      : `HTTP ${res.status}`;
    const err = new Error(msg);
    (err as any).status = res.status;
    (err as any).body = data;
    (err as any).url = url;
    (err as any).method = (init.method ?? 'GET').toUpperCase();
    throw err;
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
  if (!token) throw new Error('Missing access_token in token response');

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

  const transactionId = String(data.transactionId || data.transaction_id || data.id || '').trim();
  const redirectUrl = String(data.redirectUrl || data.redirect_url || data.paymentUrl || data.url || '').trim();

  if (!transactionId || !redirectUrl) {
    throw new Error('Unexpected init response (missing transactionId/redirectUrl)');
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
