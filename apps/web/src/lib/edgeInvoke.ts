import {
  FunctionsFetchError,
  FunctionsHttpError,
  FunctionsRelayError,
  type FunctionsError,
} from '@supabase/supabase-js';
import { supabase } from './supabaseClient';
import { errorText } from './errors';

export type InvokeEdgeOptions = {
  /** Total attempts including the first. Default: 2 */
  attempts?: number;
  /** Base delay in ms for backoff. Default: 300 */
  baseDelayMs?: number;
};

function sleep(ms: number) {
  return new Promise((r) => setTimeout(r, ms));
}

function isRetryable(err: unknown): boolean {
  const msg = errorText(err).toLowerCase();
  return (
    msg.includes('fetch') ||
    msg.includes('network') ||
    msg.includes('timeout') ||
    msg.includes('econn') ||
    msg.includes('enotfound') ||
    msg.includes('eai_again') ||
    msg.includes('connection')
  );
}

function extractRequestId(v: unknown): string | undefined {
  if (typeof v !== 'object' || v === null) return undefined;
  const r = v as Record<string, unknown>;
  const rid = (r.request_id ?? r.requestId) as unknown;
  return typeof rid === 'string' && rid.length ? rid : undefined;
}

function isUuid(v: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}

function makeTraceIdHex32(): string | undefined {
  if (typeof crypto === 'undefined') return undefined;
  if (typeof crypto.randomUUID === 'function') {
    try {
      return crypto.randomUUID().replace(/-/g, '').toLowerCase();
    } catch {
      return undefined;
    }
  }
  if (typeof crypto.getRandomValues === 'function') {
    try {
      const bytes = new Uint8Array(16);
      crypto.getRandomValues(bytes);
      return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
    } catch {
      return undefined;
    }
  }
  return undefined;
}

function makeParentIdHex16(): string | undefined {
  if (typeof crypto === 'undefined' || typeof crypto.getRandomValues !== 'function') return undefined;
  try {
    const bytes = new Uint8Array(8);
    crypto.getRandomValues(bytes);
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  } catch {
    return undefined;
  }
}

function inferCorrelationId(body?: EdgeInvokeBody): string | undefined {
  if (!body || typeof body !== 'object') return undefined;
  if (body instanceof Blob || body instanceof File || body instanceof FormData || body instanceof ArrayBuffer) return undefined;
  if (body instanceof ReadableStream) return undefined;

  const b = body as Record<string, unknown>;
  const candidates = [
    'trip_id',
    'tripId',
    'ride_id',
    'rideId',
    'intent_id',
    'intentId',
    'payment_intent_id',
    'paymentIntentId',
    'withdraw_id',
    'withdrawId',
  ];
  for (const k of candidates) {
    const v = b[k];
    if (typeof v === 'string' && isUuid(v)) return v;
  }
  return undefined;
}

// Matches the supabase-js Functions.invoke() accepted bodies.
export type EdgeInvokeBody =
  | string
  | File
  | Blob
  | ArrayBuffer
  | FormData
  | ReadableStream<Uint8Array>
  | Record<string, unknown>;


export function makeEdgeTraceHeaders(body?: EdgeInvokeBody): Record<string, string> {
  const requestId = typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function'
    ? crypto.randomUUID()
    : undefined;

  const traceId = makeTraceIdHex32();
  const parentId = makeParentIdHex16();
  const traceparent = traceId && parentId ? `00-${traceId}-${parentId}-01` : undefined;
  const correlationId = inferCorrelationId(body);

  const h: Record<string, string> = {};
  if (requestId) h['x-request-id'] = requestId;
  if (traceId) h['x-trace-id'] = traceId;
  if (traceparent) h['traceparent'] = traceparent;
  if (correlationId) h['x-correlation-id'] = correlationId;
  return h;
}
export async function invokeEdge<T>(
  fnName: string,
  body?: EdgeInvokeBody,
  opts: InvokeEdgeOptions = {},
): Promise<{ data: T; requestId?: string }> {
  const attempts = Math.max(1, Math.trunc(opts.attempts ?? 2));
  const base = Math.max(50, Math.trunc(opts.baseDelayMs ?? 300));

  let lastErr: unknown;

  // Create trace + request IDs client-side to support end-to-end request correlation.
  // Edge functions echo these back via response headers and (for our JSON helpers) also in the body.
  const requestId = typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function'
    ? crypto.randomUUID()
    : undefined;

  const traceId = makeTraceIdHex32();
  const parentId = makeParentIdHex16();
  const traceparent = traceId && parentId ? `00-${traceId}-${parentId}-01` : undefined;
  const correlationId = inferCorrelationId(body);

  type InvokeOptions = {
    body?: EdgeInvokeBody;
    headers?: Record<string, string>;
  };

  for (let i = 0; i < attempts; i++) {
    try {
      const invokeOpts: InvokeOptions = {};
      if (body !== undefined) invokeOpts.body = body;
      const h: Record<string, string> = {};
      if (requestId) h['x-request-id'] = requestId;
      if (traceId) h['x-trace-id'] = traceId;
      if (traceparent) h['traceparent'] = traceparent;
      if (correlationId) h['x-correlation-id'] = correlationId;
      if (Object.keys(h).length) invokeOpts.headers = h;

      const { data, error } = await supabase.functions.invoke(fnName, invokeOpts);
      if (error) throw error as FunctionsError;
      const rid = extractRequestId(data) ?? requestId;
      return { data: data as T, requestId: rid };
    } catch (err) {
      lastErr = err;

      // If the access token becomes invalid (e.g., key rotation, session restored from old storage),
      // Supabase Edge Functions may return 401 "Invalid JWT" at the gateway layer.
      // Refresh the session once and retry transparently.
      if (err instanceof FunctionsHttpError) {
        const status = err.context?.status;
        if (status === 401 && i < attempts - 1) {
          try {
            await supabase.auth.refreshSession();
            continue;
          } catch {
            // If refresh fails, we'll fall through and surface the original 401.
          }
        }

        // Improve debuggability by surfacing the request id (if we have one).
        try {
          const res = err.context;
          const payload = await (typeof (res as any)?.clone === 'function' ? (res as any).clone().json() : res.json());
          const msg =
            typeof payload?.error === 'string'
              ? payload.error
              : typeof payload?.message === 'string'
                ? payload.message
                : err.message;
          const rid = extractRequestId(payload) ?? requestId;
          throw new Error(rid ? `${msg} (requestId: ${rid})` : msg);
        } catch {
          // Fall through to generic retry handling.
        }
      } else if (err instanceof FunctionsRelayError || err instanceof FunctionsFetchError) {
        const msg = errorText(err);
        throw new Error(requestId ? `${msg} (requestId: ${requestId})` : msg);
      }

      if (i < attempts - 1 && isRetryable(err)) {
        const delay = base * Math.pow(2, i);
        await sleep(delay);
        continue;
      }
      throw err;
    }
  }

  throw lastErr;
}
