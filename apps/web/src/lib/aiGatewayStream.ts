import { supabase, SUPABASE_ANON_KEY, SUPABASE_URL } from './supabaseClient';

export type AiGatewaySurface = 'auto' | 'copilot' | 'merchant' | 'driver' | 'merchant_chat';

export type AiGatewayStreamArgs = {
  surface: AiGatewaySurface;
  message: string;
  thread_id?: string;
  merchant_id?: string;
  ui_path?: string;
  hours?: number;
  signal?: AbortSignal;
  onMeta?: (meta: any) => void;
  onDelta?: (delta: string) => void;
  onDone?: (payload: any) => void;
  onError?: (payload: any) => void;
};

function createSseParser(onEvent: (event: string, data: any) => void) {
  let evt: string | null = null;
  let dataLines: string[] = [];

  function flush() {
    if (!evt) {
      dataLines = [];
      return;
    }
    const raw = dataLines.join('\n').trim();
    dataLines = [];
    if (!raw) {
      evt = null;
      return;
    }

    let data: any = raw;
    try {
      data = JSON.parse(raw);
    } catch {
      // keep raw string
    }
    onEvent(evt, data);
    evt = null;
  }

  return {
    feed(text: string) {
      const lines = text.split('\n');
      for (const rawLine of lines) {
        const line = rawLine.replace(/\r$/, '');
        if (line.startsWith(':')) continue; // SSE comment

        if (line === '') {
          flush();
          continue;
        }

        if (line.startsWith('event:')) {
          evt = line.slice('event:'.length).trim();
          continue;
        }

        if (line.startsWith('data:')) {
          dataLines.push(line.slice('data:'.length).trim());
          continue;
        }
      }
    },
  };
}

export async function aiGatewayStream(args: AiGatewayStreamArgs): Promise<void> {
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) throw new Error('Supabase is not configured');

  const { data: sessData, error: sessErr } = await supabase.auth.getSession();
  if (sessErr) throw sessErr;

  const token = sessData.session?.access_token;
  if (!token) throw new Error('Not authenticated');

  const res = await fetch(`${SUPABASE_URL}/functions/v1/ai-gateway`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
      'Content-Type': 'application/json',
      Accept: 'text/event-stream',
    },
    body: JSON.stringify({
      surface: args.surface,
      message: args.message,
      thread_id: args.thread_id,
      merchant_id: args.merchant_id,
      ui_path: args.ui_path,
      hours: args.hours,
      stream: true,
    }),
    signal: args.signal,
  });

  // Pre-stream errors are normal JSON errors.
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(text || `HTTP ${res.status}`);
  }

  const reader = res.body?.getReader();
  if (!reader) throw new Error('Missing response body');

  const dec = new TextDecoder();
  let finished = false;
  const parser = createSseParser((event, data) => {
    if (event === 'meta') args.onMeta?.(data);
    else if (event === 'delta') args.onDelta?.(String(data?.delta ?? ''));
    else if (event === 'done') {
      finished = true;
      args.onDone?.(data);
    } else if (event === 'error') {
      finished = true;
      args.onError?.(data);
    }
  });

  while (!finished) {
    const { done, value } = await reader.read();
    if (done) break;
    parser.feed(dec.decode(value, { stream: true }));
  }
}

// Back-compat: some screens import callAiGatewayStream.
export const callAiGatewayStream = aiGatewayStream;
