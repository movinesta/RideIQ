import { getCorsHeaders } from './cors.ts';

function getRequestIdFromHeaders(headers: Record<string, string>): string | undefined {
  // Our internal code tends to use lowercase header names, but be defensive.
  return headers['x-request-id'] ?? headers['X-Request-Id'] ?? headers['x-requestId'];
}

function maybeAttachRequestId(data: unknown, headers: Record<string, string>) {
  // supabase-js Functions.invoke() does not expose response headers.
  // To make debugging easier in clients, also echo x-request-id in JSON bodies.
  const rid = getRequestIdFromHeaders(headers);
  if (!rid) return data;

  if (data && typeof data === 'object' && !Array.isArray(data)) {
    const obj = data as Record<string, unknown>;
    if (!('requestId' in obj)) {
      return { ...obj, requestId: rid };
    }
  }
  return data;
}

export function json(data: unknown, status = 200, headers: Record<string, string> = {}) {
  const body = maybeAttachRequestId(data, headers);
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json', ...getCorsHeaders(), ...headers },
  });
}

export function errorJson(
  message: string,
  status = 400,
  code?: string,
  extra?: Record<string, unknown>,
  headers: Record<string, string> = {},
) {
  const body: Record<string, unknown> = { error: message };
  if (code) body.code = code;
  if (extra) Object.assign(body, extra);
  return json(body, status, headers);
}
