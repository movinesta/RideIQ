import { envTrim } from './config.ts';

export type ResponsesInputItem =
  | {
      type: 'message';
      role: 'system' | 'user' | 'assistant';
      content: Array<{ type: 'input_text' | 'output_text'; text: string; annotations?: unknown[] }>;
      id?: string;
      status?: string;
    }
  | {
      type: 'function_call';
      id: string;
      call_id: string;
      name: string;
      arguments: string;
    }
  | {
      type: 'function_call_output';
      id: string;
      call_id: string;
      output: string;
    };

export type ToolDef = {
  type: 'function';
  name: string;
  description?: string;
  strict?: null | boolean;
  parameters: Record<string, unknown>;
};

export type Reasoning = { effort?: 'minimal' | 'low' | 'medium' | 'high' };

function getHeaders(extra?: Record<string, string>) {
  const apiKey = envTrim('OPENROUTER_API_KEY');
  if (!apiKey) throw new Error('OPENROUTER_API_KEY not configured');

  // OpenRouter recommends providing a referer/title for analytics.
  const referer = envTrim('OPENROUTER_HTTP_REFERER') || envTrim('APP_BASE_URL') || '';
  const title = envTrim('OPENROUTER_APP_TITLE') || 'RideIQ';

  return {
    Authorization: `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
    ...(referer ? { 'HTTP-Referer': referer } : {}),
    ...(title ? { 'X-Title': title } : {}),
    ...(extra ?? {}),
  } as Record<string, string>;
}

export type CallResponsesArgs = {
  model: string;
  input: string | ResponsesInputItem[];
  tools?: ToolDef[];
  tool_choice?: 'auto' | 'none' | { type: 'function'; name: string };
  reasoning?: Reasoning;
  max_output_tokens?: number;
  temperature?: number;
  stream?: boolean;
};

async function postResponses(args: CallResponsesArgs): Promise<Response> {
  return await fetch('https://openrouter.ai/api/v1/responses', {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(args),
  });
}

export async function callOpenRouterResponses(args: CallResponsesArgs) {
  const res = await postResponses({ ...args, stream: false });

  const json = await res.json().catch(async () => ({ error: { message: await res.text() } }));
  if (!res.ok) {
    const msg = json?.error?.message ?? `OpenRouter error (${res.status})`;
    const code = json?.error?.code ?? 'OPENROUTER_ERROR';
    throw new Error(`${code}:${msg}`);
  }
  return json as any;
}

/**
 * Stream a Responses API request. Returns the raw fetch Response (SSE body).
 * Caller must parse the SSE stream.
 */
export async function callOpenRouterResponsesStream(args: CallResponsesArgs): Promise<Response> {
  const res = await postResponses({ ...args, stream: true });
  if (!res.ok) {
    const txt = await res.text().catch(() => '');
    throw new Error(`OPENROUTER_ERROR:stream_failed:${res.status}:${txt}`);
  }
  return res;
}

export function extractOutputText(resp: any): string {
  const out = resp?.output;
  if (!Array.isArray(out)) return '';
  const chunks: string[] = [];
  for (const item of out) {
    if (item?.type === 'message' && Array.isArray(item?.content)) {
      for (const c of item.content) {
        if (c?.type === 'output_text' && typeof c?.text === 'string') chunks.push(c.text);
      }
    }
  }
  return chunks.join("\n").trim();
}

export type FunctionCall = { id: string; call_id: string; name: string; arguments: string };

export function extractFunctionCalls(resp: any): FunctionCall[] {
  const out = resp?.output;
  if (!Array.isArray(out)) return [];
  const calls: FunctionCall[] = [];
  for (const item of out) {
    if (item?.type === 'function_call' && item?.call_id && item?.name) {
      calls.push({
        id: String(item.id ?? crypto.randomUUID()),
        call_id: String(item.call_id),
        name: String(item.name),
        arguments: String(item.arguments ?? '{}'),
      });
    }
  }
  return calls;
}
