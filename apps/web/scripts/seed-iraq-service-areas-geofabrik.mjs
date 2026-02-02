/**
 * Iraq service area seeder (all admin levels) using Geofabrik OSM shapefiles.
 *
 * Required env:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * Optional env:
 *   GEOFABRIK_SHP_URL=https://download.geofabrik.de/asia/iraq-latest-free.shp.zip
 *   TARGET_ADMIN_LEVELS=2,4,6,8   // comma-separated; default = all available
 *   DRY_RUN=1
 *   PRICING_CONFIG_ID=<uuid>
 *   CASH_STEP_IQD=250
 */

import { createClient } from '@supabase/supabase-js';
import booleanPointInPolygon from '@turf/boolean-point-in-polygon';
import centroid from '@turf/centroid';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { execFileSync } from 'node:child_process';
import shapefile from 'shapefile';

const required = ['SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY'];
for (const k of required) {
  if (!process.env[k]) {
    console.error(`Missing env var: ${k}`);
    process.exit(1);
  }
}

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const SHP_URL =
  process.env.GEOFABRIK_SHP_URL ||
  'https://download.geofabrik.de/asia/iraq-latest-free.shp.zip';

const DRY_RUN = process.env.DRY_RUN === '1' || process.env.DRY_RUN === 'true';
const DEFAULT_CASH_STEP = Math.trunc(Number(process.env.CASH_STEP_IQD || 250));

const TARGET_ADMIN_LEVELS = process.env.TARGET_ADMIN_LEVELS
  ? new Set(
      process.env.TARGET_ADMIN_LEVELS.split(',')
        .map((v) => Number.parseInt(v.trim(), 10))
        .filter((v) => Number.isFinite(v)),
    )
  : null;

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

function normalizeName(value) {
  return String(value ?? '')
    .normalize('NFKC')
    .replace(/\s+/g, ' ')
    .trim();
}

function parseAdminLevel(props) {
  const raw = pickProp(props, ['admin_level', 'admin_lvl', 'adminlevel', 'admin_levl']);
  if (raw == null) return null;
  const num = Number.parseInt(String(raw).trim(), 10);
  return Number.isFinite(num) ? num : null;
}

function resolveArabicName(props) {
  const nameAr = pickProp(props, ['name_ar', 'name:ar', 'name_ara', 'name_arabic']);
  return nameAr ? String(nameAr).trim() : null;
}

async function download(url, outFile) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  const buf = Buffer.from(await res.arrayBuffer());
  await fs.writeFile(outFile, buf);
}

function pickAdminShapefile(shpFiles) {
  const byName = (pattern) => shpFiles.find((f) => pattern.test(f));
  return (
    byName(/admin.*a.*free.*\.shp$/i) ||
    byName(/admin.*\.shp$/i) ||
    byName(/boundary.*\.shp$/i) ||
    shpFiles[0]
  );
}

function ensurePolygonGeometry(geom) {
  if (!geom) return null;
  if (geom.type === 'Polygon' || geom.type === 'MultiPolygon') return geom;
  return null;
}

async function resolvePricingConfigId(supabase) {
  if (process.env.PRICING_CONFIG_ID) return process.env.PRICING_CONFIG_ID;

  const def = await supabase
    .from('pricing_configs')
    .select('id')
    .eq('is_default', true)
    .eq('active', true)
    .order('effective_from', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (def.error) throw def.error;
  if (def.data?.id) return def.data.id;

  const any = await supabase
    .from('pricing_configs')
    .select('id')
    .eq('active', true)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (any.error) throw any.error;
  if (any.data?.id) return any.data.id;

  throw new Error('No active pricing config found. Create one in Admin → Pricing first.');
}

function priorityForAdminLevel(level) {
  if (!Number.isFinite(level)) return 0;
  return Math.max(1, Math.trunc(level) * 10);
}

async function loadAdminFeatures(shpPath) {
  const source = await shapefile.open(shpPath);
  const features = [];
  while (true) {
    const result = await source.read();
    if (result.done) break;
    if (result.value?.geometry) features.push(result.value);
  }
  return features;
}

async function main() {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const pricingConfigId = await resolvePricingConfigId(supabase);
  console.log(`Using pricing_config_id=${pricingConfigId}`);
  console.log(`DRY_RUN=${DRY_RUN ? '1' : '0'}`);
  console.log(`Downloading: ${SHP_URL}`);

  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), 'iraq-geofabrik-'));
  const zipPath = path.join(tmpDir, path.basename(new URL(SHP_URL).pathname));
  await download(SHP_URL, zipPath);

  execFileSync('unzip', ['-q', zipPath, '-d', tmpDir], { stdio: 'inherit' });
  const entries = await fs.readdir(tmpDir, { recursive: true });
  const shpFiles = entries
    .map((e) => String(e))
    .filter((f) => f.toLowerCase().endsWith('.shp'));

  if (shpFiles.length === 0) {
    throw new Error(`No .shp files found in ${SHP_URL}`);
  }

  const shpRel = pickAdminShapefile(shpFiles);
  const shpPath = path.join(tmpDir, shpRel);
  console.log(`Using shapefile: ${shpRel}`);

  const features = await loadAdminFeatures(shpPath);
  const admin4 = [];

  for (const feature of features) {
    const level = parseAdminLevel(feature.properties ?? {});
    if (level !== 4) continue;
    const nameAr = resolveArabicName(feature.properties ?? {});
    const geom = ensurePolygonGeometry(feature.geometry);
    if (!nameAr || !geom) continue;
    admin4.push({ name: normalizeName(nameAr), geometry: geom });
  }

  if (admin4.length === 0) {
    console.warn('[warn] No admin_level=4 governorate polygons detected.');
  }

  const seenNamesByGov = new Map();
  let total = 0;
  let upserted = 0;
  let skipped = 0;
  let missingArabic = 0;
  let missingGov = 0;

  for (const feature of features) {
    total++;
    const props = feature.properties ?? {};
    const level = parseAdminLevel(props);
    if (!level) {
      skipped++;
      continue;
    }
    if (TARGET_ADMIN_LEVELS && !TARGET_ADMIN_LEVELS.has(level)) {
      skipped++;
      continue;
    }

    const geom = ensurePolygonGeometry(feature.geometry);
    if (!geom) {
      skipped++;
      continue;
    }

    const nameAr = resolveArabicName(props);
    if (!nameAr) {
      missingArabic++;
      skipped++;
      continue;
    }

    let governorate = null;
    if (level === 4) {
      governorate = normalizeName(nameAr);
    } else if (admin4.length > 0) {
      const center = centroid(feature).geometry;
      const found = admin4.find((gov) => booleanPointInPolygon(center, gov.geometry));
      if (found) governorate = found.name;
      else missingGov++;
    }

    const baseName = governorate
      ? `${governorate} / ${normalizeName(nameAr)}`
      : normalizeName(nameAr);

    const set = seenNamesByGov.get(governorate ?? '__NONE__') ?? new Set();
    seenNamesByGov.set(governorate ?? '__NONE__', set);
    const normalized = normalizeName(baseName);
    let name = baseName;
    if (set.has(normalized)) {
      const osmId = pickProp(props, ['osm_id', 'osm_way_id', 'osm_rel_id']);
      name = osmId ? `${baseName} (${osmId})` : `${baseName} (${level})`;
    }
    set.add(normalizeName(name));

    const priority = priorityForAdminLevel(level);

    if (DRY_RUN) {
      console.log(`[dry-run] upsert L${level} ${name} priority=${priority}`);
      continue;
    }

    const { error } = await supabase.rpc('admin_upsert_service_area_geojson_v1', {
      p_name: name,
      p_governorate: governorate,
      p_geojson: geom,
      p_priority: priority,
      p_is_active: true,
      p_pricing_config_id: pricingConfigId,
      p_min_base_fare_iqd: null,
      p_surge_multiplier: 1.0,
      p_surge_reason: null,
      p_cash_rounding_step_iqd: DEFAULT_CASH_STEP,
    });

    if (error) {
      console.error(`Failed upserting ${name}:`, error);
    } else {
      upserted++;
    }
  }

  console.log(`Total features=${total}`);
  console.log(`Skipped=${skipped}`);
  console.log(`Missing Arabic names=${missingArabic}`);
  console.log(`Missing governorate assignment=${missingGov}`);
  console.log(`Upserted=${upserted}`);
  console.log('Done.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
