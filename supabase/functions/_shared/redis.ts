import { Redis as IORedis } from 'npm:ioredis@5.6.1';
import { envTrim } from './config.ts';

let client: IORedis | null = null;
let connectPromise: Promise<void> | null = null;

function isPositiveInt(v: unknown): v is number {
  return typeof v === 'number' && Number.isFinite(v) && v > 0;
}

export function isRedisConfigured(): boolean {
  return envTrim('REDIS_URL').length > 0;
}

function requireRedisUrl(): string {
  const url = envTrim('REDIS_URL');
  if (!url) throw new Error('REDIS_NOT_CONFIGURED');
  return url;
}

function getClient(): IORedis {
  if (client) return client;

  const url = requireRedisUrl();

  // Prefer fail-fast behavior. Callers should fall back to Postgres/provider on any Redis issue.
  client = new IORedis(url, {
    lazyConnect: true,
    enableOfflineQueue: false,
    maxRetriesPerRequest: 1,
    connectTimeout: 2000,
    // Returning null stops reconnection attempts for that failure.
    retryStrategy: () => null,
  });

  client.on('error', () => {
    // ioredis errors are noisy; we don't log here to avoid leaking details or spamming.
    // Callers handle failures and fall back.
  });

  return client;
}

async function ensureConnected(c: IORedis): Promise<void> {
  if (c.status === 'ready') return;

  // ioredis will throw "Stream isn't writeable" when enableOfflineQueue=false unless we wait for connect().
  if (!connectPromise) {
    connectPromise = c.connect().finally(() => {
      connectPromise = null;
    });
  }
  await connectPromise;
}

async function withClient<T>(fn: (c: IORedis) => Promise<T>): Promise<T> {
  const c = getClient();
  try {
    await ensureConnected(c);
    return await fn(c);
  } catch (err) {
    // Reset so next request can attempt a fresh connection.
    try {
      c.disconnect();
    } catch {
      // ignore
    }
    client = null;
    connectPromise = null;
    throw err;
  }
}

export async function getJson<T>(key: string): Promise<T | null> {
  const raw = await withClient((c) => c.get(key));
  if (raw == null) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export async function setJson(key: string, value: unknown, ttlSeconds: number): Promise<void> {
  const ttl = isPositiveInt(ttlSeconds) ? Math.trunc(ttlSeconds) : 0;
  if (ttl <= 0) return;
  const payload = JSON.stringify(value);
  await withClient((c) => c.set(key, payload, 'EX', ttl));
}
