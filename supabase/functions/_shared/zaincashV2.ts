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
  return {
    baseUrl,
    clientId: mustEnv('ZAINCASH_V2_CLIENT_ID'),
    clientSecret: mustEnv('ZAINCASH_V2_CLIENT_SECRET'),
    apiKey: mustEnv('ZAINCASH_V2_API_KEY'),
    scope: envTrim('ZAINCASH_V2_SCOPE') || DEFAULT_ZAINCASH_SCOPE,
    language: (envTrim('ZAINCASH_V2_LANGUAGE') as any) || DEFAULT_ZAINCASH_LANGUAGE,
    serviceType: envTrim('ZAINCASH_V2_SERVICE_TYPE') || envTrim('TOPUP_SERVICE_TYPE') || 'Ride top-up',
  };
}

type FetchJsonOut = {
  status: number;
  ok: boolean;
  url: string;
  contentType: string;
  data: any;
};

function safeStringify(obj: unknown, maxLen = 900): string {
  try {
    const s = JSON.stringify(obj);
    if (s.length <= maxLen) return s;
    return s.slice(0, maxLen) + '…';
  } catch {
    return String(obj);
  }
}

function safeJsonParse(text: string): any {
  try {
    return JSON.parse(text);
  } catch {
    const trimmed = (text ?? '').trim();
    return { raw: trimmed.slice(0, 2000) };
  }
}

async function fetchJson(url: string, init: RequestInit): Promise<FetchJsonOut> {
  const res = await fetch(url, init);
  const contentType = (res.headers.get('content-type') ?? '').toLowerCase();
  const text = await res.text();
  const data = safeJsonParse(text);

  // Treat non-JSON responses as provider errors even if HTTP is 2xx, because
  // ZainCash v2 endpoints are expected to return JSON.
  const looksJson = contentType.includes('application/json') || contentType.includes('+json');
  if (!looksJson && res.ok) {
    const err: any = new Error(
      `ZainCash HTTP ${res.status} non-JSON response from ${res.url} (check ZAINCASH_V2_BASE_URL / endpoint paths)`,
    );
    err.status = res.status;
    err.body = data;
    throw err;
  }

  if (!res.ok) {
    const err: any = new Error(`ZainCash HTTP ${res.status} from ${res.url}: ${safeStringify(data)}`);
    err.status = res.status;
    err.body = data;
    throw err;
  }

  return { status: res.status, ok: res.ok, url: res.url, contentType, data };
}

function isUuid(v: unknown): v is string {
  return typeof v === 'string' &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}

function isHttpUrl(v: unknown): v is string {
  return typeof v === 'string' && /^https?:\/\//i.test(v);
}

function normKey(k: string): string {
  return k.toLowerCase().replace(/[^a-z0-9]/g, '');
}

function deepFind(obj: any, match: (key: string, value: any) => boolean, maxDepth = 8) {
  const visited = new Set<any>();
  const stack: Array<{ v: any; depth: number }> = [{ v: obj, depth: 0 }];

  while (stack.length) {
    const { v, depth } = stack.pop()!;
    if (v == null) continue;
    if (typeof v !== 'object') continue;
    if (visited.has(v)) continue;
    visited.add(v);

    if (Array.isArray(v)) {
      if (depth < maxDepth) {
        for (let i = 0; i < v.length; i++) stack.push({ v: v[i], depth: depth + 1 });
      }
      continue;
    }

    for (const [k, val] of Object.entries(v)) {
      if (match(k, val)) return { key: k, value: val };
      if (depth < maxDepth && typeof val === 'object' && val !== null) stack.push({ v: val, depth: depth + 1 });
    }
  }

  return null;
}

function summarizeInitBody(data: any): string {
  if (data == null) return 'null';
  if (typeof data === 'string') return `string:${data.slice(0, 200)}`;
  if (typeof data !== 'object') return `type:${typeof data}`;

  const d: any = data;
  const msg = d.message ?? d.error ?? d.error_description ?? d.description ?? d.details ?? null;
  const code = d.code ?? d.errorCode ?? d.error_code ?? d.statusCode ?? null;
  const status = d.status ?? d.result ?? d.responseStatus ?? null;
  const keys = Object.keys(d).slice(0, 18).join(',');

  // If safeJsonParse fell back to {raw: ...}, surface that.
  const raw = typeof d.raw === 'string' ? d.raw.slice(0, 200) : null;

  return [
    keys ? `keys=[${keys}]` : null,
    status != null ? `status=${String(status)}` : null,
    code != null ? `code=${String(code)}` : null,
    msg != null ? `message=${String(msg).slice(0, 200)}` : null,
    raw ? `raw=${raw}` : null,
  ].filter(Boolean).join(' ');
}

async function getAccessToken(cfg: ZaincashV2Config): Promise<string> {
  const url = cfg.baseUrl + ZAINCASH_OAUTH_PATH;

  const body = new URLSearchParams({
    grant_type: 'client_credentials',
    client_id: cfg.clientId,
    client_secret: cfg.clientSecret,
    scope: cfg.scope,
  });

  const { data, status } = await fetchJson(url, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body,
  });

  const accessToken = (data?.access_token ?? data?.accessToken ?? '').toString();
  if (!accessToken) {
    const err: any = new Error(`ZainCash token response missing access_token: ${safeStringify(data)}`);
    err.status = status;
    err.body = data;
    throw err;
  }

  return accessToken;
}

export type ZaincashV2InitInput = {
  externalReferenceId: string;
  orderId: string;
  amountIQD: number;
  customerPhone: string | null;
  successUrl: string;
  failureUrl: string;
};

export async function zaincashV2InitPayment(
  cfg: ZaincashV2Config,
  input: ZaincashV2InitInput,
): Promise<{ transactionId: string; redirectUrl: string; raw: unknown }> {
  const token = await getAccessToken(cfg);
  const url = cfg.baseUrl + ZAINCASH_V2_INIT_PATH;

  const payload = {
    language: cfg.language,
    externalReferenceId: input.externalReferenceId,
    orderId: input.orderId,
    serviceType: cfg.serviceType,
    amount: { value: input.amountIQD, currency: CURRENCY_IQD },
    customer: input.customerPhone ? { phone: input.customerPhone } : undefined,
    redirectUrls: { successUrl: input.successUrl, failureUrl: input.failureUrl },
  };

  const out = await fetchJson(url, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${token}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const raw = out.data;

  // First: try the documented shape(s)
  const knownTransactionId =
    raw?.transactionId ??
    raw?.transactionID ??
    raw?.transaction_id ??
    raw?.data?.transactionId ??
    raw?.data?.transactionID ??
    raw?.data?.transaction_id ??
    raw?.result?.transactionId ??
    raw?.result?.transactionID ??
    raw?.result?.transaction_id ??
    raw?.response?.transactionId ??
    raw?.response?.transactionID ??
    raw?.response?.transaction_id ??
    raw?.payload?.transactionId ??
    raw?.payload?.transactionID ??
    raw?.payload?.transaction_id;

  const knownRedirectUrl =
    raw?.redirectUrl ??
    raw?.redirectURL ??
    raw?.redirect_url ??
    raw?.data?.redirectUrl ??
    raw?.data?.redirectURL ??
    raw?.data?.redirect_url ??
    raw?.result?.redirectUrl ??
    raw?.result?.redirectURL ??
    raw?.result?.redirect_url ??
    raw?.response?.redirectUrl ??
    raw?.response?.redirectURL ??
    raw?.response?.redirect_url ??
    raw?.payload?.redirectUrl ??
    raw?.payload?.redirectURL ??
    raw?.payload?.redirect_url ??
    raw?.paymentUrl ??
    raw?.payment_url ??
    raw?.data?.paymentUrl ??
    raw?.data?.payment_url;

  let transactionId = isUuid(knownTransactionId) ? knownTransactionId : '';
  let redirectUrl = isHttpUrl(knownRedirectUrl) ? knownRedirectUrl : '';

  // Second: robust deep extraction (handles additional wrapper objects)
  if (!transactionId) {
    const foundTx = deepFind(raw, (k, v) => {
      if (!isUuid(v)) return false;
      const nk = normKey(k);
      return nk.includes('transaction') && nk.includes('id');
    });
    if (foundTx && isUuid(foundTx.value)) transactionId = foundTx.value;
  }

  if (!redirectUrl) {
    const foundUrl = deepFind(raw, (k, v) => {
      if (!isHttpUrl(v)) return false;
      const nk = normKey(k);
      return nk.includes('redirect') && nk.includes('url') || nk.includes('payment') && nk.includes('url');
    });
    if (foundUrl && isHttpUrl(foundUrl.value)) redirectUrl = foundUrl.value;
  }

  if (!transactionId || !redirectUrl) {
    const details = summarizeInitBody(raw);
    const err: any = new Error(
      `Unexpected init response (missing transactionId/redirectUrl). ${details || ''}`.trim(),
    );
    err.status = out.status;
    err.body = raw;
    throw err;
  }

  return { transactionId, redirectUrl, raw };
}

export async function zaincashV2BuildInquiryUrl(cfg: ZaincashV2Config, transactionId: string) {
  return cfg.baseUrl + ZAINCASH_V2_INQUIRY_PREFIX + transactionId;
}
