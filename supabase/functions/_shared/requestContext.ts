import { getCorsHeaders } from './cors.ts';

export type RequestContext = {
  fn: string;
  requestId: string;
  startedAtMs: number;
  headers: Record<string, string>;
  log: (message: string, extra?: Record<string, unknown>) => void;
  error: (message: string, extra?: Record<string, unknown>) => void;
};

function makeLogger(level: 'info' | 'error', fn: string, requestId: string) {
  return (message: string, extra: Record<string, unknown> = {}) => {
    const payload = {
      level,
      fn,
      requestId,
      message,
      ...extra,
      ts: new Date().toISOString(),
    };
    if (level === 'error') console.error(JSON.stringify(payload));
    else console.log(JSON.stringify(payload));
  };
}

function attachCors(headers: Headers) {
  const cors = getCorsHeaders();
  for (const [k, v] of Object.entries(cors)) {
    // Do not clobber if a handler explicitly set it.
    if (!headers.has(k)) headers.set(k, v);
  }
}

export async function withRequestContext(
  fn: string,
  req: Request,
  handler: (ctx: RequestContext) => Promise<Response>,
): Promise<Response> {
  const incoming = req.headers.get('x-request-id');
  const requestId = incoming && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(incoming)
    ? incoming
    : crypto.randomUUID();
  const startedAtMs = Date.now();
  const ctx: RequestContext = {
    fn,
    requestId,
    startedAtMs,
    headers: { 'x-request-id': requestId },
    log: makeLogger('info', fn, requestId),
    error: makeLogger('error', fn, requestId),
  };

  // Avoid noisy logs for CORS preflight.
  if (req.method === 'OPTIONS') {
    return handler(ctx);
  }

  ctx.log('request.start', { method: req.method, path: new URL(req.url).pathname });

  try {
    const res = await handler(ctx);

    // Always attach request id for traceability + ensure CORS is present.
    const headers = new Headers(res.headers);
    headers.set('x-request-id', requestId);
    attachCors(headers);

    const wrapped = new Response(res.body, { status: res.status, headers });
    ctx.log('request.end', { status: res.status, duration_ms: Date.now() - startedAtMs });
    return wrapped;
  } catch (err) {
    ctx.error('request.unhandled_error', { error: String(err), duration_ms: Date.now() - startedAtMs });
    const headers = new Headers({ 'content-type': 'application/json', 'x-request-id': requestId });
    attachCors(headers);
    return new Response(JSON.stringify({ error: 'Internal server error', requestId }), {
      status: 500,
      headers,
    });
  }
}
