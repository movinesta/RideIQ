#!/usr/bin/env node
/**
 * Single-source-of-truth generator for DB hardening allowlists.
 *
 * Why:
 *  - DB uses deny-by-default EXECUTE on public functions.
 *  - The app needs a small allowlist of RPCs for anon/authenticated.
 *  - Keeping allowlists in multiple places is error-prone.
 *
 * Source of truth:
 *  - config/security/rpc-allowlist.json
 *
 * Targets:
 *  - supabase/schema.sql (REQUIRED)
 *    The user asked for the project to work when applying schema.sql directly.
 *  - supabase/migrations/202601270001_p0_security_hardening.sql (OPTIONAL)
 *    Updated if present, but the generator will NOT fail if this migration is missing.
 *
 * Also keeps pgTAP regression test allowlists in sync:
 *  - supabase/tests/005_security_hardening.test.sql
 *
 * Usage:
 *   node scripts/generate-security-hardening.mjs
 *   node scripts/generate-security-hardening.mjs --check
 */

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const ALLOWLIST_PATH = path.join(ROOT, 'config', 'security', 'rpc-allowlist.json');

const SCHEMA_SQL_PATH = path.join(ROOT, 'supabase', 'schema.sql');
const MIGRATION_PATH = path.join(ROOT, 'supabase', 'migrations', '202601270001_p0_security_hardening.sql');
const SECURITY_TEST_PATH = path.join(ROOT, 'supabase', 'tests', '005_security_hardening.test.sql');

function readText(p) {
  return fs.readFileSync(p, 'utf8');
}

function loadAllowlist() {
  const raw = readText(ALLOWLIST_PATH);
  const parsed = JSON.parse(raw);
  const anon = Array.from(new Set(parsed.anon ?? [])).sort();
  const authenticated = Array.from(new Set(parsed.authenticated ?? [])).sort();
  return { anon, authenticated };
}

function formatSqlStringArray(items, indent = '        ') {
  return items
    .map((n, i) => `${indent}'${n}'${i === items.length - 1 ? '' : ','}`)
    .join('\n');
}

function replaceBlockInText(text, marker, newBody, fileLabel) {
  const begin = `-- BEGIN ${marker}`;
  const end = `-- END ${marker}`;
  const re = new RegExp(`${begin}[\\s\\S]*?${end}`, 'm');
  if (!re.test(text)) {
    throw new Error(`Missing marker block: ${marker} in ${fileLabel}`);
  }
  return text.replace(re, `${begin}\n${newBody}\n${end}`);
}

function buildAnonBlock(anon) {
  return [
    '      and p.proname = any (array[',
    '        -- Generated from config/security/rpc-allowlist.json',
    formatSqlStringArray(anon, '        '),
    '      ])',
  ].join('\n');
}

function buildAuthBlock(authenticated) {
  return [
    '      and p.proname = any (array[',
    '        -- Generated from config/security/rpc-allowlist.json',
    formatSqlStringArray(authenticated, '        '),
    '      ])',
  ].join('\n');
}

function buildTestList(items) {
  return items
    .map((n, i) => `        '${n}'${i === items.length - 1 ? '' : ','}`)
    .join('\n');
}

function updateTargetFile(targetPath, markerAnon, markerAuth) {
  const label = path.relative(ROOT, targetPath);
  if (!fs.existsSync(targetPath)) {
    return { label, exists: false };
  }

  const { anon, authenticated } = loadAllowlist();
  if (!anon.length) throw new Error('Allowlist anon is empty — refuses to generate.');
  if (!authenticated.length) throw new Error('Allowlist authenticated is empty — refuses to generate.');

  let text = readText(targetPath);
  text = replaceBlockInText(text, markerAnon, buildAnonBlock(anon), label);
  text = replaceBlockInText(text, markerAuth, buildAuthBlock(authenticated), label);

  return { label, exists: true, nextText: text };
}

function generate() {
  if (!fs.existsSync(ALLOWLIST_PATH)) {
    throw new Error(`Missing allowlist: ${ALLOWLIST_PATH}`);
  }
  if (!fs.existsSync(SCHEMA_SQL_PATH)) {
    throw new Error(`Missing required schema file: ${SCHEMA_SQL_PATH}`);
  }
  if (!fs.existsSync(SECURITY_TEST_PATH)) {
    throw new Error(`Missing required test file: ${SECURITY_TEST_PATH}`);
  }

  const { anon, authenticated } = loadAllowlist();

  // Update supabase/schema.sql (required)
  const schemaOut = updateTargetFile(SCHEMA_SQL_PATH, 'RPC_ALLOWLIST_ANON', 'RPC_ALLOWLIST_AUTHENTICATED');
  if (!schemaOut.exists) {
    throw new Error(`Missing required schema file: ${SCHEMA_SQL_PATH}`);
  }

  // Update migration if present (optional)
  const migrationOut = updateTargetFile(MIGRATION_PATH, 'RPC_ALLOWLIST_ANON', 'RPC_ALLOWLIST_AUTHENTICATED');

  // Update pgTAP test allowlists
  let testSql = readText(SECURITY_TEST_PATH);
  testSql = replaceBlockInText(testSql, 'RPC_ALLOWLIST_ANON_TEST', buildTestList(anon), path.relative(ROOT, SECURITY_TEST_PATH));
  testSql = replaceBlockInText(
    testSql,
    'RPC_ALLOWLIST_AUTHENTICATED_TEST',
    buildTestList(authenticated),
    path.relative(ROOT, SECURITY_TEST_PATH)
  );

  return { schemaOut, migrationOut, testSql };
}

function main() {
  const check = process.argv.includes('--check');
  const next = generate();

  const currentSchema = readText(SCHEMA_SQL_PATH);
  const currentTest = readText(SECURITY_TEST_PATH);

  const currentMigration = fs.existsSync(MIGRATION_PATH) ? readText(MIGRATION_PATH) : null;

  if (check) {
    const schemaMismatch = currentSchema !== next.schemaOut.nextText;
    const testMismatch = currentTest !== next.testSql;

    const migrationMismatch =
      next.migrationOut.exists && currentMigration !== null ? currentMigration !== next.migrationOut.nextText : false;

    if (schemaMismatch || testMismatch || migrationMismatch) {
      console.error('\nFAIL — Security allowlists are out of sync with config/security/rpc-allowlist.json');
      console.error('Run: node scripts/generate-security-hardening.mjs');
      process.exit(1);
    }

    console.log('OK — Security allowlists are in sync (schema.sql + pgTAP tests)');
    if (!next.migrationOut.exists) {
      console.log('NOTE — migration file not found; skipped (this is OK if you apply schema.sql directly).');
    }
    return;
  }

  fs.writeFileSync(SCHEMA_SQL_PATH, next.schemaOut.nextText);
  fs.writeFileSync(SECURITY_TEST_PATH, next.testSql);
  console.log(`Updated: ${path.relative(ROOT, SCHEMA_SQL_PATH)}`);
  console.log(`Updated: ${path.relative(ROOT, SECURITY_TEST_PATH)}`);

  if (next.migrationOut.exists) {
    fs.writeFileSync(MIGRATION_PATH, next.migrationOut.nextText);
    console.log(`Updated: ${path.relative(ROOT, MIGRATION_PATH)}`);
  } else {
    console.log('Skipped: supabase/migrations/202601270001_p0_security_hardening.sql (not present)');
  }
}

try {
  main();
} catch (e) {
  console.error(`\nGenerator failed: ${(e && e.message) || e}`);
  process.exit(2);
}
