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

// ZainCash v2 documentation uses an origin-only base URL (e.g. https://pg-api-uat.zaincash.iq)
// and then endpoint paths like /oauth2/token and /api/v2/payment-gateway/transaction/init.
// In practice, misconfiguration is common (people paste a full endpoint URL). Normalize safely.
function normalizeBaseUrl(raw: string): string {
  let v = String(raw ?? '').trim();
  if (!v) return '';

  // Accept values without scheme (e.g. pg-api-uat.zaincash.iq)
  if (!/^https?:\/\//i.test(v)) v = `https://${v}`;

  let u: URL;
  try {
    u = new URL(v);
  } catch {
    return v.replace(/\/+$/, '');
  }

  // If someone pasted a full endpoint URL, strip known endpoint prefixes.
  // Keep any custom proxy prefix path (rare) unless it matches ZainCash endpoint roots.
  const pathname = (u.pathname || '').replace(/\/+$/, '');
  let prefix = pathname;
  const knownRoots = ['/api/v2/payment-gateway', '/oauth2'];
  for (const root of knownRoots) {
    const idx = prefix.toLowerCase().indexOf(root);
    if (idx >= 0) {
      prefix = prefix.slice(0, idx);
      break;
    }
  }

  // Remove trailing slash from the prefix and recompose.
  prefix = prefix.replace(/\/+$/, '');
  return `${u.origin}${prefix}`.replace(/\/+$/, '');
}

function mustEnv(name: string): string {
  const v = envTrim(name);
  if (!v) throw new Error(`Missing ${name}`);
  return v;
}

export function getZaincashV2Config(): ZaincashV2Config {
  const baseUrl = normalizeBaseUrl(mustEnv('ZAINCASH_V2_BASE_URL'));
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

async function fetchJson(url: string, init: RequestInit): Promise<any> {
  const res = await fetch(url, init);
  const txt = await res.text();
  const data = safeJsonParse(txt) ?? { raw: txt };
  if (!res.ok) {
    const method = String((init as any)?.method ?? 'GET').toUpperCase();
    const msg = (data && (data.message || data.error_description || data.error))
      ? String(data.message || data.error_description || data.error)
      : `HTTP ${res.status}`;
    // Include URL in the message so callers can diagnose misconfigured base URLs and paths.
    const err = new Error(`${msg} (${method} ${url})`);
    (err as any).status = res.status;
    (err as any).body = data;
    (err as any).url = url;
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
