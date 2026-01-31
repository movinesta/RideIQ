# Observability with Langfuse via OpenRouter Broadcast

This project routes LLM calls through OpenRouter. OpenRouter's **Broadcast** feature can forward request/response traces to **Langfuse** without adding an observability SDK.

## What this repo already does (best-practice defaults)

- Sends **`user`** and **`session_id`** on OpenRouter calls (for Langfuse trace grouping).
  - `user` is the authenticated Supabase `user.id` (UUID).
  - `session_id` is derived per surface:
    - `merchant_chat`: `merchant_chat:<thread_id>`
    - `merchant`: `merchant:<merchant_id|request_id>`
    - `driver`: `driver:<request_id>`
    - `copilot`: `copilot:<request_id>`
  - The client may optionally send `session_id` in the request body to override grouping.

- Sets OpenRouter attribution headers (optional):
  - `HTTP-Referer` via `OPENROUTER_HTTP_REFERER` (fallback: `APP_BASE_URL`)
  - `X-Title` via `OPENROUTER_APP_TITLE` (fallback: `RideIQ`)

## Step-by-step setup

### 1) Create Langfuse keys
1. Create a Langfuse project.
2. Go to **Project Settings → API Keys**.
3. Create a key pair and copy both **Public Key** and **Secret Key**.

### 2) Enable OpenRouter Broadcast → Langfuse
1. Open your **OpenRouter dashboard**.
2. Go to **Settings → Broadcast** and enable Broadcast.
3. Choose **Langfuse** as a destination.
4. Paste the Langfuse **Public Key** + **Secret Key** (and host/region if prompted).
5. Use **Test connection** and save.

### 3) Configure Supabase Edge Function environment
Set these env vars in Supabase (Dashboard → Project Settings → Functions → Environment Variables):

- `OPENROUTER_API_KEY` (required)
- `OPENROUTER_HTTP_REFERER` (recommended)
- `OPENROUTER_APP_TITLE` (recommended)

### 4) Verify end-to-end
1. Call `supabase/functions/v1/ai-gateway` (any surface).
2. Open Langfuse and confirm a trace appears.
3. Confirm traces group by `session_id` and are attributable to `user`.

## Safety notes

- Do not pass phone numbers, emails, or raw PII into `user`/`session_id`.
- If you later add retrieval (RAG), prefer sending **document IDs** (not full doc text) as metadata.
