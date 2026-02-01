/*
  Seed Iraq service areas (polygons) from HDX COD-AB (OCHA) dataset.

  Uses the CKAN API to discover a GeoJSON resource, downloads it, then upserts
  ADM2 (districts) as service_areas for the initial governorates.

  Required env:
    SUPABASE_URL
    SUPABASE_SERVICE_ROLE_KEY

  Optional env:
    PRICING_CONFIG_ID            -- explicit pricing_config to attach
    DRY_RUN=1                    -- logs only
    CASH_STEP_IQD=250            -- default cash rounding step (IQD)
    CASH_STEP_BAGHDAD=250        -- per-governorate override
    CODAB_DATASET_ID=cod-ab-irq  -- CKAN dataset id (default cod-ab-irq)
    SEED_ADMIN_LEVEL=2           -- 1=ADM1 governorates, 2=ADM2 districts (default 2)
    CODAB_RESOURCE_ID=<uuid>     -- optional: force a specific HDX resource id (debug/override)
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
const DATASET_ID = process.env.CODAB_DATASET_ID || 'cod-ab-irq';
const SEED_ADMIN_LEVEL = Number(process.env.SEED_ADMIN_LEVEL || 2);
const FORCED_RESOURCE_ID = process.env.CODAB_RESOURCE_ID || null;

if (![1, 2].includes(SEED_ADMIN_LEVEL)) {
  console.error(`SEED_ADMIN_LEVEL must be 1 or 2. Got: ${SEED_ADMIN_LEVEL}`);
  process.exit(1);
}

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
    if (
      props &&
      Object.prototype.hasOwnProperty.call(props, k) &&
      props[k] != null &&
      String(props[k]).trim() !== ''
    ) {
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

function isGeoCandidate(r) {
  const fmt = String(r.format ?? '').toLowerCase();
  const url = String(r.url ?? '').toLowerCase();
  return (
    r.url &&
    (
      fmt.includes('geojson') ||
      url.endsWith('.geojson') ||
      url.endsWith('.json') ||
      url.endsWith('.zip')
    )
  );
}

function resourceSort(a, b) {
  // Prefer direct GeoJSON over ZIP, then newest last_modified.
  const aIsGeo = String(a.format ?? '').toLowerCase().includes('geojson') || String(a.url ?? '').toLowerCase().endsWith('.geojson');
  const bIsGeo = String(b.format ?? '').toLowerCase().includes('geojson') || String(b.url ?? '').toLowerCase().endsWith('.geojson');
  if (aIsGeo !== bIsGeo) return aIsGeo ? -1 : 1;
  return String(b.last_modified ?? '').localeCompare(String(a.last_modified ?? ''));
}

async function discoverCodabGeojsonResource({ datasetId, adminLevel } = {}) {
  const pkg = await fetchJson(`https://data.humdata.org/api/3/action/package_show?id=${encodeURIComponent(datasetId)}`);
  if (!pkg?.success) throw new Error(`CKAN package_show failed for ${datasetId}`);

  const resources = pkg.result?.resources ?? [];
  const candidates = resources
    .map((r) => ({
      id: r.id,
      name: r.name,
      format: String(r.format ?? ''),
      url: r.url,
      last_modified: r.last_modified,
    }))
    .filter(isGeoCandidate)
    .sort(resourceSort);

  if (FORCED_RESOURCE_ID) {
    const forced = candidates.find((r) => r.id === FORCED_RESOURCE_ID);
    if (!forced) {
      throw new Error(`CODAB_RESOURCE_ID=${FORCED_RESOURCE_ID} not found in ${datasetId} resources`);
    }
    return forced;
  }

  const want =
    adminLevel === 1
      ? /adm\s*1|adm1|admin\s*1|governorate/i
      : /adm\s*2|adm2|admin\s*2|district|qadha|qadhaa|qaza/i;

  const labeled = candidates.filter((r) => want.test(r.name ?? '') || want.test(r.url ?? '')).sort(resourceSort);

  if (labeled.length > 0) return labeled[0];

  if (candidates.length === 0) {
    throw new Error(`No GeoJSON/ZIP candidates found in ${datasetId}`);
  }

  // Fallback: many COD-AB datasets publish “all layers” in one GeoJSON ZIP.
  console.warn(
    `[warn] No ADM${adminLevel}-labeled resource found in ${datasetId}. Falling back to most recent GeoJSON/ZIP: ${candidates[0].name}`
  );
  return candidates[0];
}

function scoreFeatureCollectionForLevel(fc, level) {
  if (!fc || fc.type !== 'FeatureCollection' || !Array.isArray(fc.features)) return 0;

  // Check for expected COD-AB property names
  const key = level === 1 ? 'adm1_pcode' : 'adm2_pcode';

  let hits = 0;
  const sample = fc.features.slice(0, 50);
  for (const f of sample) {
    const p = f?.properties ?? {};
    if (p[key] || p[key.toUpperCase()] || p[key.replace('_', '')] || p[key.replace('_', '').toUpperCase()]) hits += 1;
  }
  return hits;
}

async function loadGeojsonFromResource(resource, { adminLevel } = {}) {
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), 'codab-irq-'));
  const url = resource.url;
  const out = path.join(tmpDir, path.basename(new URL(url).pathname) || `codab_${resource.id}`);

  await downloadFile(url, out);

  // If ZIP, unzip and select the GeoJSON most likely matching admin level.
  if (out.toLowerCase().endsWith('.zip')) {
    execFileSync('unzip', ['-q', out, '-d', tmpDir], { stdio: 'inherit' });

    const files = await fs.readdir(tmpDir, { recursive: true });
    const geoFiles = files
      .map((f) => String(f))
      .filter((f) => f.toLowerCase().endsWith('.geojson') || f.toLowerCase().endsWith('.json'));

    if (geoFiles.length === 0) {
      throw new Error(`ZIP did not contain a GeoJSON/JSON file: ${url}`);
    }

    // Prefer filename matches first
    const nameWant = adminLevel === 1 ? /adm\s*1|adm1|admin\s*1/i : /adm\s*2|adm2|admin\s*2/i;
    const byName = geoFiles.filter((f) => nameWant.test(f)).sort();
    const candidates = (byName.length ? byName : geoFiles).slice(0, 20); // defensive cap

    let best = null;
    let bestScore = -1;

    for (const rel of candidates) {
      const geoPath = path.join(tmpDir, rel);
      try {
        const txt = await fs.readFile(geoPath, 'utf-8');
        const json = JSON.parse(txt);
        const s = scoreFeatureCollectionForLevel(json, adminLevel);
        if (s > bestScore) {
          best = json;
          bestScore = s;
        }
      } catch {
        // ignore parse failures; continue
      }
    }

    if (!best) {
      // fallback to first file
      const geoPath = path.join(tmpDir, geoFiles.sort()[0]);
      const txt = await fs.readFile(geoPath, 'utf-8');
      best = JSON.parse(txt);
    }

    return best;
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
  console.log(`Dataset=${DATASET_ID} seed_admin_level=ADM${SEED_ADMIN_LEVEL}`);

  const resource = await discoverCodabGeojsonResource({ datasetId: DATASET_ID, adminLevel: SEED_ADMIN_LEVEL });
  console.log(`COD-AB resource: ${resource.name} (${resource.format})`);
  console.log(`Downloading: ${resource.url}`);

  const geojson = await loadGeojsonFromResource(resource, { adminLevel: SEED_ADMIN_LEVEL });
  if (!geojson || geojson.type !== 'FeatureCollection' || !Array.isArray(geojson.features)) {
    throw new Error('Unexpected GeoJSON structure; expected FeatureCollection.');
  }

  const targetSet = new Set(TARGET_GOVERNORATES);
  let total = 0;
  let matchedGov = 0;
  let matchedLevel = 0;
  let upserted = 0;

  for (const f of geojson.features) {
    total += 1;
    const props = f.properties ?? {};

    // COD-AB commonly uses adm1_name/adm2_name/adm*_pcode; also keep legacy keys.
    const adm1 = pickProp(props, [
      'adm1_name', 'ADM1_EN', 'ADM1', 'ADM1NAME', 'ADM1NAME_EN',
      'ADM1_ENGL', 'admin1Name', 'governorate', 'gov',
    ]);

    const canonGov = canonicalGovernorate(adm1);
    if (!canonGov || !targetSet.has(canonGov)) continue;
    matchedGov += 1;

    // Filter by admin level:
    if (SEED_ADMIN_LEVEL === 1) {
      const adm1Pcode = pickProp(props, ['adm1_pcode', 'ADM1_PCODE', 'ADM1_PCOD']);
      if (!adm1Pcode && !adm1) continue; // ensure it's actually ADM1-like
      matchedLevel += 1;

      const name = canonGov;
      const geom = f.geometry;
      if (!geom) continue;

      const cashStep = Number(
        process.env[`CASH_STEP_${canonGov.toUpperCase().replace(/[^A-Z0-9]/g, '_')}`] ||
        process.env.CASH_STEP_IQD ||
        250
      );

      if (DRY_RUN) {
        console.log(`[dry-run] upsert ${name} (${canonGov}) cash_step=${cashStep}`);
        continue;
      }

      const { error } = await supabase.rpc('admin_upsert_service_area_geojson_v1', {
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
      continue;
    }

    // ADM2 seeding (districts)
    const adm2 = pickProp(props, [
      'adm2_name', 'ADM2_EN', 'ADM2', 'ADM2NAME', 'ADM2NAME_EN',
      'admin2Name', 'district', 'qadha', 'qadhaa', 'qaza',
    ]);
    const adm2Pcode = pickProp(props, ['adm2_pcode', 'ADM2_PCODE', 'ADM2_PCOD']);

    // Ensure we only seed districts (not ADM1/ADM3)
    if (!adm2 || !adm2Pcode) continue;
    matchedLevel += 1;

    const name = `${canonGov} / ${String(adm2).trim()}`;
    const geom = f.geometry;
    if (!geom) continue;

    const cashStep = Number(
      process.env[`CASH_STEP_${canonGov.toUpperCase().replace(/[^A-Z0-9]/g, '_')}`] ||
      process.env.CASH_STEP_IQD ||
      250
    );

    if (DRY_RUN) {
      console.log(`[dry-run] upsert ${name} (${canonGov}) cash_step=${cashStep}`);
      continue;
    }

    // Important: we pass ONLY the geometry object (not whole FeatureCollection).
    // PostGIS ST_GeomFromGeoJSON accepts GeoJSON geometry fragments only. :contentReference[oaicite:1]{index=1}
    const { error } = await supabase.rpc('admin_upsert_service_area_geojson_v1', {
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

  console.log(`GeoJSON features total=${total}`);
  console.log(`Matched target governorates=${matchedGov}`);
  console.log(`Matched admin level (ADM${SEED_ADMIN_LEVEL})=${matchedLevel}`);
  console.log(`Upserted=${upserted}`);
  console.log('Done.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
