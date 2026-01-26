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
  const rid = r.requestId;
  return typeof rid === 'string' && rid.length ? rid : undefined;
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

export async function invokeEdge<T>(
  fnName: string,
  body?: EdgeInvokeBody,
  opts: InvokeEdgeOptions = {},
): Promise<{ data: T; requestId?: string }> {
  const attempts = Math.max(1, Math.trunc(opts.attempts ?? 2));
  const base = Math.max(50, Math.trunc(opts.baseDelayMs ?? 300));

  let lastErr: unknown;

  // Create a client-side correlation id and send it to the function.
  // Edge functions will echo it back via headers and (for our JSON helpers) also in the body.
  const requestId = typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function'
    ? crypto.randomUUID()
    : undefined;

  type InvokeOptions = {
    body?: EdgeInvokeBody;
    headers?: Record<string, string>;
  };

  for (let i = 0; i < attempts; i++) {
    try {
      const invokeOpts: InvokeOptions = {};
      if (body !== undefined) invokeOpts.body = body;
      if (requestId) invokeOpts.headers = { 'x-request-id': requestId };

      const { data, error } = await supabase.functions.invoke(fnName, invokeOpts);
      if (error) throw error as FunctionsError;
      const rid = extractRequestId(data) ?? requestId;
      return { data: data as T, requestId: rid };
    } catch (err) {
      lastErr = err;

      // Improve debuggability by surfacing the request id (if we have one).
      if (err instanceof FunctionsHttpError) {
        try {
          const payload = await err.context.json();
          const msg = typeof payload?.error === 'string' ? payload.error : err.message;
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
