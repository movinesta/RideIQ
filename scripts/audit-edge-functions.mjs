#!/usr/bin/env node
/**
 * Edge Functions security audit (static).
 *
 * Ensures every function configured with verify_jwt = false has an explicit
 * authorization / integrity check.
 */

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const CONFIG_TOML = path.join(ROOT, 'supabase', 'config.toml');
const FUNCTIONS_DIR = path.join(ROOT, 'supabase', 'functions');

function readText(p) {
  return fs.readFileSync(p, 'utf8');
}

function listVerifyJwtFalseFunctions(configToml) {
  const names = [];
  const lines = configToml.split(/\r?\n/);
  let current = null;
  for (const line of lines) {
    const sect = line.match(/^\s*\[functions\.([a-zA-Z0-9_-]+)\]\s*$/);
    if (sect) {
      current = sect[1];
      continue;
    }
    if (!current) continue;
    if (/^\s*verify_jwt\s*=\s*false\s*$/.test(line)) {
      names.push(current);
      current = null; // stop scanning until next section
    }
  }
  return names;
}

// Some endpoints are intentionally public + read-only.
const INTENTIONALLY_PUBLIC = new Set([
  'support-articles',
  'support-article-detail',
  'payments-config',
]);

// Tokenized public endpoints (must validate some token / signature, but not necessarily a user JWT).
const TOKENIZED_PUBLIC = new Set([
  'trip-share-view',
  'whatsapp-booking-view',
]);

// Webhook endpoints (must validate signature / token / HMAC).
const WEBHOOKS = new Set([
  'zaincash-webhook',
  'qicard-notify',
  'asiapay-notify',
]);

// Return/redirect handlers: should not do privileged writes.
const RETURNS = new Set([
  'zaincash-return',
  'qicard-return',
  'asiapay-return',
]);

// Cron / maintenance endpoints (must validate a secret header or environment secret).
const CRON = new Set([
  'topup-reconcile',
  'expire-rides',
  'driver-stats-rollup',
  'driver-leaderboard-refresh',
  'stats-rollup',
  'notifications-dispatch',
  'trusted-contacts-dispatch',
]);

function hasAny(patterns, text) {
  return patterns.some((re) => re.test(text));
}

const PATTERNS = {
  userAuth: [
    /\brequireUser\s*\(/,
    /\bauth\.getUser\b/i,
    /\bAuthorization\b/i,
  ],
  cronSecret: [
    /CRON_SECRET/i,
    /x-cron/i,
    /cron/i,
  ],
  signature: [
    /webhook_token/i,
    /signature/i,
    /hmac/i,
    /timingSafeEqual/i,
    /crypto\.subtle/i,
    /verifyJwt/i,
  ],
  token: [
    /\btoken\b/i,
    /token_hash/i,
    /sha-?256/i,
    /crypto\.subtle/i,
  ],
};

function getIndexPath(name) {
  const p = path.join(FUNCTIONS_DIR, name, 'index.ts');
  return p;
}

function audit() {
  if (!fs.existsSync(CONFIG_TOML)) {
    throw new Error(`Missing supabase/config.toml at ${CONFIG_TOML}`);
  }
  const config = readText(CONFIG_TOML);
  const names = listVerifyJwtFalseFunctions(config);

  const failures = [];
  const warnings = [];

  for (const name of names) {
    const indexPath = getIndexPath(name);
    if (!fs.existsSync(indexPath)) {
      failures.push({ name, reason: `Missing function entrypoint: ${indexPath}` });
      continue;
    }
    const src = readText(indexPath);

    // Intentionally public endpoints must be read-only (best-effort heuristic).
    if (INTENTIONALLY_PUBLIC.has(name)) {
      // payments-config is actually auth-only (it calls requireUser). enforce it.
      if (name === 'payments-config') {
        if (!hasAny(PATTERNS.userAuth, src)) {
          failures.push({ name, reason: 'payments-config must enforce user auth (requireUser/auth.getUser)' });
        }
      } else {
        // support endpoints should not write to DB (heuristic: reject obvious write calls).
        if (/\.rpc\(/.test(src) || /\.insert\(/.test(src) || /\.update\(/.test(src) || /\.delete\(/.test(src)) {
          warnings.push({ name, reason: 'Public endpoint appears to perform a write/RPC; verify this is safe.' });
        }
      }
      continue;
    }

    // Tokenized public endpoints: must validate a token.
    if (TOKENIZED_PUBLIC.has(name)) {
      if (!hasAny(PATTERNS.token, src)) {
        failures.push({ name, reason: 'Tokenized public endpoint must validate a token (token/token_hash/sha256).' });
      }
      continue;
    }

    // Webhooks: must validate signature/token/HMAC.
    if (WEBHOOKS.has(name)) {
      if (!hasAny(PATTERNS.signature, src)) {
        failures.push({ name, reason: 'Webhook endpoint must validate signature/token/HMAC.' });
      }
      continue;
    }

    // Return/redirect handlers: ensure they are not doing privileged writes.
    if (RETURNS.has(name)) {
      if (/SUPABASE_SERVICE_ROLE_KEY/.test(src) || /\.rpc\(/.test(src) || /\.(insert|update|delete)\(/.test(src)) {
        warnings.push({ name, reason: 'Return handler appears to do privileged operations; verify this is intended.' });
      }
      continue;
    }

    // Cron: must validate a secret.
    if (CRON.has(name)) {
      if (!hasAny(PATTERNS.cronSecret, src)) {
        failures.push({ name, reason: 'Cron endpoint must validate a CRON_SECRET (or equivalent header/secret).' });
      }
      continue;
    }

    // Fallback: require some auth or signature check.
    if (!hasAny([...PATTERNS.userAuth, ...PATTERNS.signature, ...PATTERNS.cronSecret, ...PATTERNS.token], src)) {
      failures.push({ name, reason: 'No recognizable auth/integrity guard found.' });
    }
  }

  return { names, failures, warnings };
}

try {
  const { names, failures, warnings } = audit();

  console.log(`\nEdge Functions audit: verify_jwt=false functions (${names.length})`);
  for (const n of names) console.log(`  - ${n}`);

  if (warnings.length) {
    console.log(`\nWarnings (${warnings.length}):`);
    for (const w of warnings) console.log(`  - ${w.name}: ${w.reason}`);
  }

  if (failures.length) {
    console.error(`\nFAIL (${failures.length}) — fix before merging:`);
    for (const f of failures) console.error(`  - ${f.name}: ${f.reason}`);
    process.exit(1);
  }

  console.log(`\n✅ Audit OK (no failures).`);
} catch (e) {
  const msg = e instanceof Error ? e.message : String(e);
  console.error(`\nEdge Functions audit crashed: ${msg}`);
  process.exit(1);
}
