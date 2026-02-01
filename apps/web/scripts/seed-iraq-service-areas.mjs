/*
  Seed Iraq service areas (polygons) from HDX COD-AB (OCHA) dataset.

  Uses the CKAN API to discover a GeoJSON resource, downloads it, filters to a
  small set of governorates, and upserts districts (ADM2) as service_areas.

  Usage (from repo root):
    pnpm -C apps/web node scripts/seed-iraq-service-areas.mjs

  Required env:
    SUPABASE_URL
    SUPABASE_SERVICE_ROLE_KEY

  Optional env:
    PRICING_CONFIG_ID            -- explicit pricing_config to attach
    DRY_RUN=1                    -- logs only
    CASH_STEP_IQD=250            -- default cash rounding step (IQD)
    CASH_STEP_BAGHDAD=250        -- per-governorate override

  Notes:
    - This script uses the HDX COD-AB Iraq dataset via CKAN. It will select an
      ADM2 (district) GeoJSON resource if available.
*/

import { createClient } from '@supabase/supabase-js';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';

const REQUIRED_ENV = ['SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY'];
for (const k of REQUIRED_ENV) {
  if (!process.env[k]) {
    console.error(`Missing env var: ${k}`);
    process.exit(1);
  }
}

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const DRY_RUN = process.env.DRY_RUN === '1' || process.env.DRY_RUN === 'true';

// Governorates requested for initial rollout.
const TARGET_GOVERNORATES = [
  'Baghdad',
  'Babil',
  'Al-Qadisiyyah',
  'Najaf',
  'Muthanna',
  'Karbala',
];

// Normalize names to improve match reliability across datasets.
const norm = (s) =>
  String(s ?? '')
    .trim()
    .toLowerCase()
    .replace(/[`´’']/g, '')
    .replace(/\s+/g, ' ')
    .replace(/[^a-z0-9\s-]/g, '');

const GOV_ALIASES = new Map([
  ['Baghdad', new Set(['baghdad'])],
  ['Babil', new Set(['babil', 'babylon'])],
  ['Al-Qadisiyyah', new Set(['al-qadisiyyah', 'al qadisiyyah', 'qadisiyyah', 'al-qadisiyah', 'al qadisiyah'])],
  ['Najaf', new Set(['najaf', 'an najaf', 'al najaf'])],
  ['Muthanna', new Set(['muthanna', 'al muthanna', 'al-muthanna', 'al muthana', 'al-muthana'])],
  ['Karbala', new Set(['karbala', 'karbalaa'])],
]);

function canonicalGovernorate(raw) {
  const r = norm(raw);
  for (const [canon, set] of GOV_ALIASES.entries()) {
    if (set.has(r)) return canon;
  }
  return null;
}

function pickProp(props, keys) {
  for (const k of keys) {
    if (props && Object.prototype.hasOwnProperty.call(props, k) && props[k] != null && String(props[k]).trim() !== '') {
      return props[k];
    }
  }
  return null;
}

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  return await res.json();
}

async function downloadFile(url, outPath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  const buf = Buffer.from(await res.arrayBuffer());
  await fs.writeFile(outPath, buf);
}

async function discoverCodabGeojsonResource({ datasetId = 'cod-ab-irq', adminLevel = 2 } = {}) {
  // CKAN: https://data.humdata.org/api/3/action/package_show?id=<dataset>
  const pkg = await fetchJson(`https://data.humdata.org/api/3/action/package_show?id=${encodeURIComponent(datasetId)}`);
  if (!pkg?.success) throw new Error(`CKAN package_show failed for ${datasetId}`);
  const resources = pkg.result?.resources ?? [];

  const want = adminLevel === 1 ? /adm\s*1|admin\s*1|governorate/i : /adm\s*2|admin\s*2|district|qadha/i;
  const geo = resources
    .map((r) => ({
      id: r.id,
      name: r.name,
      format: String(r.format ?? ''),
      url: r.url,
      last_modified: r.last_modified,
    }))
    .filter((r) => r.url && (r.format.toLowerCase().includes('geojson') || r.url.toLowerCase().endsWith('.geojson') || r.url.toLowerCase().endsWith('.zip')))
    .filter((r) => want.test(r.name ?? '') || want.test(r.url ?? ''));

  // Prefer direct GeoJSON over ZIP.
  geo.sort((a, b) => {
    const aIsGeo = a.format.toLowerCase().includes('geojson') || a.url.toLowerCase().endsWith('.geojson');
    const bIsGeo = b.format.toLowerCase().includes('geojson') || b.url.toLowerCase().endsWith('.geojson');
    if (aIsGeo !== bIsGeo) return aIsGeo ? -1 : 1;
    return String(b.last_modified ?? '').localeCompare(String(a.last_modified ?? ''));
  });

  if (geo.length === 0) {
    throw new Error(`No GeoJSON/ZIP resource found in ${datasetId} for ADM${adminLevel}`);
  }

  return geo[0];
}

async function loadGeojsonFromResource(resource) {
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), 'codab-irq-'));
  const url = resource.url;
  const out = path.join(tmpDir, path.basename(new URL(url).pathname) || `codab_${resource.id}`);

  await downloadFile(url, out);

  // If ZIP, unzip and find a .geojson.
  if (out.toLowerCase().endsWith('.zip')) {
    execFileSync('unzip', ['-q', out, '-d', tmpDir], { stdio: 'inherit' });
    const files = await fs.readdir(tmpDir, { recursive: true });
    const geo = files
      .map((f) => String(f))
      .filter((f) => f.toLowerCase().endsWith('.geojson') || f.toLowerCase().endsWith('.json'))
      .sort();

    if (geo.length === 0) {
      throw new Error(`ZIP did not contain a GeoJSON/JSON file: ${url}`);
    }

    const geoPath = path.join(tmpDir, geo[0]);
    const txt = await fs.readFile(geoPath, 'utf-8');
    return JSON.parse(txt);
  }

  const txt = await fs.readFile(out, 'utf-8');
  return JSON.parse(txt);
}

async function main() {
  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  // Choose pricing config id.
  const providedPricingId = process.env.PRICING_CONFIG_ID || null;
  let pricingConfigId = providedPricingId;

  if (!pricingConfigId) {
    const { data: def, error: defErr } = await supabase
      .from('pricing_configs')
      .select('id')
      .eq('is_default', true)
      .eq('active', true)
      .order('effective_from', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (defErr) throw defErr;
    pricingConfigId = def?.id ?? null;
  }

  if (!pricingConfigId) {
    const { data: anyCfg, error: anyErr } = await supabase
      .from('pricing_configs')
      .select('id')
      .eq('active', true)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();
    if (anyErr) throw anyErr;
    pricingConfigId = anyCfg?.id ?? null;
  }

  if (!pricingConfigId) {
    throw new Error('No active pricing_config found. Apply migrations (seed) first or set PRICING_CONFIG_ID.');
  }

  console.log(`Using pricing_config_id=${pricingConfigId}${providedPricingId ? ' (from env)' : ''}`);

  const resource = await discoverCodabGeojsonResource({ adminLevel: 2 });
  console.log(`COD-AB resource: ${resource.name} (${resource.format})`);
  console.log(`Downloading: ${resource.url}`);

  const geojson = await loadGeojsonFromResource(resource);
  if (!geojson || geojson.type !== 'FeatureCollection' || !Array.isArray(geojson.features)) {
    throw new Error('Unexpected GeoJSON structure; expected FeatureCollection.');
  }

  const targetSet = new Set(TARGET_GOVERNORATES);
  let total = 0;
  let matched = 0;
  let upserted = 0;

  for (const f of geojson.features) {
    total += 1;
    const props = f.properties ?? {};

    const adm1 = pickProp(props, ['ADM1_EN', 'ADM1', 'admin1Name', 'ADM1NAME', 'ADM1NAME_EN', 'gov', 'governorate']);
    const canonGov = canonicalGovernorate(adm1);
    if (!canonGov || !targetSet.has(canonGov)) continue;

    matched += 1;

    const adm2 = pickProp(props, ['ADM2_EN', 'ADM2', 'admin2Name', 'ADM2NAME', 'district', 'qadha']);
    const name = adm2 ? `${canonGov} / ${String(adm2).trim()}` : canonGov;

    const geom = f.geometry;
    if (!geom) continue;

    const cashStep = Number(process.env[`CASH_STEP_${canonGov.toUpperCase().replace(/[^A-Z0-9]/g, '_')}`] || process.env.CASH_STEP_IQD || 250);

    if (DRY_RUN) {
      console.log(`[dry-run] upsert ${name} (${canonGov}) cash_step=${cashStep}`);
      continue;
    }

    const { data, error } = await supabase.rpc('admin_upsert_service_area_geojson_v1', {
      p_name: name,
      p_governorate: canonGov,
      p_geojson: geom,
      p_priority: 0,
      p_is_active: true,
      p_pricing_config_id: pricingConfigId,
      p_min_base_fare_iqd: null,
      p_surge_multiplier: 1.0,
      p_surge_reason: null,
      p_cash_rounding_step_iqd: Math.trunc(cashStep),
    });

    if (error) {
      console.error(`Failed upserting ${name}:`, error);
      continue;
    }

    upserted += 1;
    if (upserted % 20 === 0) console.log(`Upserted ${upserted}...`);
  }

  console.log(`GeoJSON features total=${total}, matched(target gov)=${matched}, upserted=${upserted}`);
  console.log('Done.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
