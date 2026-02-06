#!/usr/bin/env node

/**
 * Edge Function Supabase-key requirement audit.
 *
 * Session 05 contract:
 * - Every function under supabase/functions (except _shared + tests) must be declared
 *   in supabase/functions/key-requirements.json as one of:
 *     - "anon"         (publishable/anon key only, RLS enforced)
 *     - "service_role" (secret/service_role key required)
 *     - "none"         (does not use Supabase API keys)
 * - Any function that imports/uses createServiceClient() MUST be declared "service_role".
 */

import fs from 'node:fs';
import path from 'node:path';

const REPO_ROOT = process.cwd();
const FUNCTIONS_ROOT = path.join(REPO_ROOT, 'supabase', 'functions');
const REQUIREMENTS_PATH = path.join(FUNCTIONS_ROOT, 'key-requirements.json');

const ALLOWED = new Set(['anon', 'service_role', 'none']);

function die(msg) {
  console.error(`\n❌ ${msg}\n`);
  process.exit(1);
}

function warn(msg) {
  console.warn(`⚠️  ${msg}`);
}

function readJson(p) {
  try {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch (e) {
    die(`Failed to read ${p}: ${e?.message ?? String(e)}`);
  }
}

function listFunctionDirs() {
  return fs
    .readdirSync(FUNCTIONS_ROOT, { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => d.name)
    .filter((n) => n !== '_shared' && n !== 'tests')
    .sort();
}

function readIndexSrc(fnName) {
  const idx = path.join(FUNCTIONS_ROOT, fnName, 'index.ts');
  if (!fs.existsSync(idx)) {
    die(`Function "${fnName}" is missing index.ts at ${path.relative(REPO_ROOT, idx)}`);
  }
  return fs.readFileSync(idx, 'utf8');
}

function usesServiceClient(src) {
  // Local string checks are sufficient because our shared client helpers have stable names.
  return src.includes('createServiceClient') || src.includes('requireSupabaseSecret');
}

function usesUserOrPublicClient(src) {
  return (
    src.includes('createUserClient') ||
    src.includes('createAnonClient') ||
    src.includes('createPublicClient') ||
    src.includes('requireUser') ||
    src.includes('requireUserStrict')
  );
}

function main() {
  if (!fs.existsSync(REQUIREMENTS_PATH)) {
    die(
      `Missing ${path.relative(
        REPO_ROOT,
        REQUIREMENTS_PATH
      )}. Session 05 requires a key requirement declaration for every Edge Function.`
    );
  }

  const req = readJson(REQUIREMENTS_PATH);
  if (!req || typeof req !== 'object' || Array.isArray(req)) {
    die(`key-requirements.json must be a JSON object of { "function-name": "anon|service_role|none" }`);
  }

  const dirs = listFunctionDirs();
  const missing = dirs.filter((n) => !(n in req));
  if (missing.length) {
    die(
      `key-requirements.json is missing ${missing.length} function(s): ${missing
        .map((x) => `"${x}"`)
        .join(', ')}`
    );
  }

  const unknownKeys = Object.keys(req)
    .filter((k) => !dirs.includes(k))
    .sort();
  if (unknownKeys.length) {
    die(
      `key-requirements.json contains unknown function(s): ${unknownKeys
        .map((x) => `"${x}"`)
        .join(', ')}`
    );
  }

  const invalid = Object.entries(req)
    .filter(([, v]) => !ALLOWED.has(String(v)))
    .map(([k, v]) => `${k}=${JSON.stringify(v)}`);
  if (invalid.length) {
    die(`key-requirements.json has invalid values: ${invalid.join(', ')}`);
  }

  let errors = 0;
  const warnings = [];

  for (const fn of dirs) {
    const declared = String(req[fn]);
    const src = readIndexSrc(fn);

    const service = usesServiceClient(src);
    const userish = usesUserOrPublicClient(src);

    if (service && declared !== 'service_role') {
      console.error(
        `❌ ${fn}: uses createServiceClient()/requireSupabaseSecret but is declared "${declared}" (must be "service_role")`
      );
      errors++;
    }

    if (!service && declared === 'service_role') {
      warnings.push(`${fn}: declared service_role but does not appear to use createServiceClient() (verify intent)`);
    }

    if ((service || userish) && declared === 'none') {
      console.error(`❌ ${fn}: declared "none" but appears to use Supabase client helpers`);
      errors++;
    }

    if (!service && !userish && declared !== 'none') {
      warnings.push(
        `${fn}: declared "${declared}" but does not appear to use Supabase client helpers (consider "none")`
      );
    }
  }

  for (const w of warnings) warn(w);

  if (errors) {
    die(`Key requirement audit failed with ${errors} error(s).`);
  }

  console.log(`✅ Key requirement audit passed for ${dirs.length} Edge Functions.`);
}

main();
