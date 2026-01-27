#!/usr/bin/env node
/**
 * Single-source-of-truth generator for the P0 DB hardening migration.
 *
 * Why:
 *  - Our DB uses deny-by-default EXECUTE on public functions.
 *  - The app needs a small allowlist of RPCs for anon/authenticated.
 *  - Maintaining the allowlist in multiple places is error-prone.
 *
 * Source of truth:
 *  - config/security/rpc-allowlist.json
 *
 * This script updates ONLY the allowlist blocks inside:
 *  - supabase/migrations/202601270001_p0_security_hardening.sql
 *
 * Usage:
 *   node scripts/generate-security-hardening.mjs        # write
 *   node scripts/generate-security-hardening.mjs --check # verify in sync
 */

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const ALLOWLIST_PATH = path.join(ROOT, 'config', 'security', 'rpc-allowlist.json');

const SECURITY_TEST_PATH = path.join(ROOT, 'supabase', 'tests', '005_security_hardening.test.sql');

const MIGRATION_PATH = path.join(
  ROOT,
  'supabase',
  'migrations',
  '202601270001_p0_security_hardening.sql'
);

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
  // One item per line, comma-terminated (except last).
  return items
    .map((n, i) => `${indent}'${n}'${i === items.length - 1 ? '' : ','}`)
    .join('\n');
}

function replaceBlock(sql, marker, newBody) {
  const begin = `-- BEGIN ${marker}`;
  const end = `-- END ${marker}`;
  const re = new RegExp(`${begin}[\\s\\S]*?${end}`, 'm');
  if (!re.test(sql)) {
    throw new Error(`Missing marker block in migration: ${marker}`);
  }
  return sql.replace(re, `${begin}\n${newBody}\n${end}`);
}


function replaceBlockInText(text, marker, newBody) {
  const begin = `-- BEGIN ${marker}`;
  const end = `-- END ${marker}`;
  const re = new RegExp(`${begin}[\\s\\S]*?${end}`, 'm');
  if (!re.test(text)) {
    throw new Error(`Missing marker block: ${marker}`);
  }
  return text.replace(re, `${begin}\n${newBody}\n${end}`);
}

function buildTestList(items) {
  // One per line; SQL already expects quoted items.
  return items.map((n, i) => `        '${n}'${i === items.length - 1 ? '' : ','}`).join('\n');
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

function generate() {
  if (!fs.existsSync(ALLOWLIST_PATH)) {
    throw new Error(`Missing allowlist: ${ALLOWLIST_PATH}`);
  }
  if (!fs.existsSync(MIGRATION_PATH)) {
    throw new Error(`Missing migration: ${MIGRATION_PATH}`);
  }

  const { anon, authenticated } = loadAllowlist();
  if (!anon.length) throw new Error('Allowlist anon is empty — refuses to generate.');
  if (!authenticated.length) throw new Error('Allowlist authenticated is empty — refuses to generate.');

  let sql = readText(MIGRATION_PATH);

  sql = replaceBlock(sql, 'RPC_ALLOWLIST_ANON', buildAnonBlock(anon));
  sql = replaceBlock(sql, 'RPC_ALLOWLIST_AUTHENTICATED', buildAuthBlock(authenticated));

  // Also keep the pgTAP regression test allowlists in sync
  if (!fs.existsSync(SECURITY_TEST_PATH)) {
    throw new Error(`Missing test file: ${SECURITY_TEST_PATH}`);
  }
  let testSql = readText(SECURITY_TEST_PATH);
  testSql = replaceBlockInText(testSql, 'RPC_ALLOWLIST_ANON_TEST', buildTestList(anon));
  testSql = replaceBlockInText(testSql, 'RPC_ALLOWLIST_AUTHENTICATED_TEST', buildTestList(authenticated));

  return { migrationSql: sql, testSql };
}

function main() {
  const check = process.argv.includes('--check');
  const next = generate();
  const current = readText(MIGRATION_PATH);
  const currentTest = readText(SECURITY_TEST_PATH);

  if (check) {
    if (current !== next.migrationSql || currentTest !== next.testSql) {
      console.error('\nFAIL — P0 hardening migration is out of sync with rpc-allowlist.json');
      console.error('Run: node scripts/generate-security-hardening.mjs');
      process.exit(1);
    }
    console.log('OK — Security allowlists are in sync (migration + pgTAP tests)');
    return;
  }

  fs.writeFileSync(MIGRATION_PATH, next.migrationSql);
  fs.writeFileSync(SECURITY_TEST_PATH, next.testSql);
  console.log(`Updated: ${path.relative(ROOT, MIGRATION_PATH)}`);
  console.log(`Updated: ${path.relative(ROOT, SECURITY_TEST_PATH)}`);
}

try {
  main();
} catch (e) {
  console.error(`\nGenerator failed: ${(e && e.message) || e}`);
  process.exit(2);
}
