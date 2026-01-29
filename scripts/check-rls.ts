/**
 * RLS (Row Level Security) Audit Script
 *
 * This script checks all tables in the `public` schema and reports
 * which ones do NOT have RLS enabled, which is a security risk.
 *
 * Run with: npx tsx scripts/check-rls.ts
 * Requires: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    console.error('Error: Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables.');
    console.error('Set them in a root .env file or export them before running this script.');
    process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function main() {
    console.log('🔍 Checking RLS status for all public schema tables...\n');

    // Query pg_catalog to find tables with rowsecurity disabled
    const { data, error } = await supabase.rpc('check_rls_status');

    if (error) {
        // If RPC doesn't exist, we need to create it or use raw SQL
        console.warn(
            `⚠️  RPC 'check_rls_status' not found. You may need to create it.\n`,
            `   Run this SQL in your Supabase dashboard:\n`,
        );
        console.log(`
CREATE OR REPLACE FUNCTION public.check_rls_status()
RETURNS TABLE(table_name text, rls_enabled boolean)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    c.relname::text AS table_name,
    c.relrowsecurity AS rls_enabled
  FROM pg_catalog.pg_class c
  JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'r'
  ORDER BY c.relname;
$$;
    `);
        process.exit(1);
    }

    const tables = data as { table_name: string; rls_enabled: boolean }[];
    const unprotected = tables.filter((t) => !t.rls_enabled);

    if (unprotected.length === 0) {
        console.log('✅ All tables in the public schema have RLS enabled!');
        process.exit(0);
    }

    console.log(`❌ Found ${unprotected.length} table(s) WITHOUT RLS enabled:\n`);
    for (const t of unprotected) {
        console.log(`   - ${t.table_name}`);
    }

    console.log('\n📌 To fix, run: ALTER TABLE public.<table_name> ENABLE ROW LEVEL SECURITY;\n');
    process.exit(1);
}

main();
