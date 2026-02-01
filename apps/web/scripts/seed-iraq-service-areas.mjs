/**
 * Seed Iraq service areas from HDX COD-AB using ADM1 P-codes.
 *
 * - Discovers a GeoJSON/ZIP resource in HDX (CKAN Action API package_show)
 * - Downloads & unzips if needed
 * - Selects the GeoJSON most likely containing ADM2 features (or ADM1 if configured)
 * - Builds TARGET ADM1 PCODES (Baghdad, Babil, Najaf, Karbala, Al-Qadisiyyah, Muthanna)
 * - Seeds either:
 *     - ADM1 (one polygon per governorate)  OR
 *     - ADM2 (one polygon per district within selected governorates)
 * - Upserts via admin_upsert_service_area_geojson_v1, passing ONLY GeoJSON geometry fragments
 *   (PostGIS ST_GeomFromGeoJSON requires geometry fragments). :contentReference[oaicite:2]{index=2}
 *
 * Required env:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * Optional env:
 *   CODAB_DATASET_ID=cod-ab-irq
 *   CODAB_RESOURCE_ID=<uuid>        // force a specific resource
 *   SEED_ADMIN_LEVEL=2              // 1 = ADM1, 2 = ADM2 (default)
 *   DRY_RUN=1                       // log only, no DB writes
 *   PRICING_CONFIG_ID=<uuid>        // force pricing config; else auto picks default active
 *   CASH_STEP_IQD=250               // default rounding step
 *   CASH_STEP_BAGHDAD=250           // per-governorate override
 *   CASH_STEP_KARBALA=250
 *   CASH_STEP_NAJAF=250
 *   CASH_STEP_AL_QADISIYYAH=250
 *   CASH_STEP_MUTHANNA=250
 *   CASH_STEP_BABIL=250
 */

import { createClient } from "@supabase/supabase-js";
import fs from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import { execFileSync } from "node:child_process";

const required = ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"];
for (const k of required) {
  if (!process.env[k]) {
    console.error(`Missing env var: ${k}`);
    process.exit(1);
  }
}

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const DATASET_ID = process.env.CODAB_DATASET_ID || "cod-ab-irq";
const FORCED_RESOURCE_ID = process.env.CODAB_RESOURCE_ID || null;

const SEED_ADMIN_LEVEL = Number(process.env.SEED_ADMIN_LEVEL || 2); // 1 or 2
if (![1, 2].includes(SEED_ADMIN_LEVEL)) {
  console.error(`SEED_ADMIN_LEVEL must be 1 or 2 (got ${SEED_ADMIN_LEVEL})`);
  process.exit(1);
}

const DRY_RUN = process.env.DRY_RUN === "1" || process.env.DRY_RUN === "true";
const DEFAULT_CASH_STEP = Math.trunc(Number(process.env.CASH_STEP_IQD || 250));

/**
 * Target governorates (initial rollout):
 * Baghdad, Babil, Al-Qadisiyyah, Najaf, Muthanna, Karbala
 */
const TARGET_GOVS = [
  "Baghdad",
  "Babil",
  "Al-Qadisiyyah",
  "Najaf",
  "Muthanna",
  "Karbala",
];

/**
 * Normalize strings for matching (diacritics, hyphens, whitespace, suffixes).
 */
function norm(s) {
  return String(s ?? "")
    .normalize("NFKD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .replace(/-/g, " ")
    .replace(/\b(governorate|province)\b/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * Governorate name aliases (for mapping ADM1_NAME -> canonical).
 */
const GOV_ALIASES = new Map([
  ["Baghdad", new Set(["baghdad"])],
  ["Babil", new Set(["babil", "babylon"])],
  [
    "Al-Qadisiyyah",
    new Set([
      "al qadisiyyah",
      "al qadisiyah",
      "qadisiyyah",
      "qadisiyah",
      "al qadisiyya",
    ]),
  ],
  ["Najaf", new Set(["najaf", "an najaf", "al najaf"])],
  ["Karbala", new Set(["karbala", "karbalaa"])],
  ["Muthanna", new Set(["muthanna", "al muthanna", "al muthana"])],
]);

function canonicalGov(rawAdm1Name) {
  const n = norm(rawAdm1Name);
  for (const [canon, set] of GOV_ALIASES.entries()) {
    if (set.has(n)) return canon;
  }
  return null;
}

function pickProp(props, keys) {
  for (const k of keys) {
    if (
      props &&
      Object.prototype.hasOwnProperty.call(props, k) &&
      props[k] != null &&
      String(props[k]).trim() !== ""
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

async function download(url, outFile) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  const buf = Buffer.from(await res.arrayBuffer());
  await fs.writeFile(outFile, buf);
}

function resourceIsGeoCandidate(r) {
  const fmt = String(r.format ?? "").toLowerCase();
  const url = String(r.url ?? "").toLowerCase();
  return (
    r.url &&
    (fmt.includes("geojson") ||
      url.endsWith(".geojson") ||
      url.endsWith(".json") ||
      url.endsWith(".zip"))
  );
}

function resourceSort(a, b) {
  // Prefer GeoJSON over ZIP; then most recent last_modified.
  const aGeo =
    String(a.format ?? "").toLowerCase().includes("geojson") ||
    String(a.url ?? "").toLowerCase().endsWith(".geojson");
  const bGeo =
    String(b.format ?? "").toLowerCase().includes("geojson") ||
    String(b.url ?? "").toLowerCase().endsWith(".geojson");
  if (aGeo !== bGeo) return aGeo ? -1 : 1;
  return String(b.last_modified ?? "").localeCompare(String(a.last_modified ?? ""));
}

/**
 * Discover COD-AB resource using CKAN Action API package_show.
 * Falls back to "most recent GeoJSON/ZIP" if not labeled per ADM level.
 * CKAN Action API is documented here. :contentReference[oaicite:3]{index=3}
 */
async function discoverCodabResource() {
  const pkg = await fetchJson(
    `https://data.humdata.org/api/3/action/package_show?id=${encodeURIComponent(
      DATASET_ID
    )}`
  );

  if (!pkg?.success) throw new Error(`CKAN package_show failed for ${DATASET_ID}`);

  const resources = (pkg.result?.resources ?? [])
    .map((r) => ({
      id: r.id,
      name: r.name,
      format: String(r.format ?? ""),
      url: r.url,
      last_modified: r.last_modified,
    }))
    .filter(resourceIsGeoCandidate)
    .sort(resourceSort);

  if (FORCED_RESOURCE_ID) {
    const forced = resources.find((r) => r.id === FORCED_RESOURCE_ID);
    if (!forced) throw new Error(`CODAB_RESOURCE_ID ${FORCED_RESOURCE_ID} not found`);
    return forced;
  }

  // Try to find an ADM-labeled resource by name/url.
  const want =
    SEED_ADMIN_LEVEL === 1
      ? /adm\s*1|adm1|admin\s*1|governorate/i
      : /adm\s*2|adm2|admin\s*2|district|qadha|qaza/i;

  const labeled = resources.filter(
    (r) => want.test(r.name ?? "") || want.test(r.url ?? "")
  );

  if (labeled.length > 0) return labeled[0];

  if (resources.length === 0) {
    throw new Error(`No GeoJSON/ZIP resources found in dataset ${DATASET_ID}`);
  }

  console.warn(
    `[warn] No ADM${SEED_ADMIN_LEVEL}-labeled resource found; falling back to most recent: ${resources[0].name}`
  );
  return resources[0];
}

function scoreFeatureCollectionForAdm(fc, adminLevel) {
  if (!fc || fc.type !== "FeatureCollection" || !Array.isArray(fc.features)) return 0;
  const key = adminLevel === 1 ? "adm1_pcode" : "adm2_pcode";
  let hits = 0;
  for (const f of fc.features.slice(0, 200)) {
    const p = f?.properties ?? {};
    if (p[key] || p[key.toUpperCase()]) hits++;
  }
  return hits;
}

/**
 * Download and parse GeoJSON.
 * If ZIP: unzip and pick the GeoJSON file that best matches the requested admin level.
 */
async function loadGeojson(resource) {
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "codab-irq-"));
  const url = resource.url;
  const outPath = path.join(tmpDir, path.basename(new URL(url).pathname) || `codab_${resource.id}`);

  await download(url, outPath);

  if (outPath.toLowerCase().endsWith(".zip")) {
    // unzip is typically present on GitHub runners; install if needed.
    execFileSync("unzip", ["-q", outPath, "-d", tmpDir], { stdio: "inherit" });

    // find json/geojson files
    const entries = await fs.readdir(tmpDir, { recursive: true });
    const jsonFiles = entries
      .map((e) => String(e))
      .filter((f) => f.toLowerCase().endsWith(".geojson") || f.toLowerCase().endsWith(".json"));

    if (jsonFiles.length === 0) {
      throw new Error(`ZIP did not contain .geojson/.json files: ${url}`);
    }

    // Prefer files that look like ADM1/ADM2 by filename.
    const nameWant = SEED_ADMIN_LEVEL === 1 ? /adm\s*1|adm1/i : /adm\s*2|adm2/i;
    const byName = jsonFiles.filter((f) => nameWant.test(f)).sort();

    const candidates = (byName.length ? byName : jsonFiles).slice(0, 25);
    let best = null;
    let bestScore = -1;

    for (const rel of candidates) {
      const p = path.join(tmpDir, rel);
      try {
        const txt = await fs.readFile(p, "utf8");
        const fc = JSON.parse(txt);
        const s = scoreFeatureCollectionForAdm(fc, SEED_ADMIN_LEVEL);
        if (s > bestScore) {
          best = fc;
          bestScore = s;
        }
      } catch {
        // ignore
      }
    }

    if (!best) {
      const p = path.join(tmpDir, candidates[0]);
      best = JSON.parse(await fs.readFile(p, "utf8"));
    }

    return best;
  }

  return JSON.parse(await fs.readFile(outPath, "utf8"));
}

/**
 * Determine pricing_config_id:
 * - use PRICING_CONFIG_ID if set
 * - else pick latest active default
 * - else pick any active
 */
async function resolvePricingConfigId(supabase) {
  if (process.env.PRICING_CONFIG_ID) return process.env.PRICING_CONFIG_ID;

  const def = await supabase
    .from("pricing_configs")
    .select("id")
    .eq("is_default", true)
    .eq("active", true)
    .order("effective_from", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (def.error) throw def.error;
  if (def.data?.id) return def.data.id;

  const any = await supabase
    .from("pricing_configs")
    .select("id")
    .eq("active", true)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (any.error) throw any.error;
  if (any.data?.id) return any.data.id;

  throw new Error("No active pricing config found. Create one in Admin → Pricing first.");
}

/**
 * Build target ADM1 PCODES by scanning features and mapping adm1_name -> adm1_pcode.
 * We use P-codes as stable keys. :contentReference[oaicite:4]{index=4}
 */
function buildTargetAdm1PcodesFromGeojson(geojson) {
  const nameToPcode = new Map(); // norm(adm1_name) -> adm1_pcode
  const freq = new Map();

  for (const f of geojson.features) {
    const p = f.properties ?? {};
    // Only look at features likely to be at least ADM2 (they contain adm1_pcode anyway).
    const adm1Name = pickProp(p, ["adm1_name", "ADM1_EN", "ADM1"]);
    const adm1Pcode = pickProp(p, ["adm1_pcode", "ADM1_PCODE"]);
    if (!adm1Name || !adm1Pcode) continue;

    const key = norm(adm1Name);
    nameToPcode.set(key, String(adm1Pcode));
    freq.set(key, (freq.get(key) || 0) + 1);
  }

  const targets = new Map(); // canonicalGov -> adm1_pcode
  for (const gov of TARGET_GOVS) {
    // Try all alias strings as lookup keys
    const aliasSet = GOV_ALIASES.get(gov) || new Set([norm(gov)]);
    let found = null;

    for (const alias of aliasSet) {
      if (nameToPcode.has(alias)) {
        found = nameToPcode.get(alias);
        break;
      }
    }

    if (found) targets.set(gov, found);
  }

  return { targets, nameToPcode, freq };
}

function cashStepForGov(canonGov) {
  const key = `CASH_STEP_${canonGov.toUpperCase().replace(/[^A-Z0-9]/g, "_")}`;
  const v = process.env[key];
  if (!v) return DEFAULT_CASH_STEP;
  const n = Math.trunc(Number(v));
  return Number.isFinite(n) && n > 0 ? n : DEFAULT_CASH_STEP;
}

/**
 * Seed: upsert service_areas using admin_upsert_service_area_geojson_v1.
 * Always pass ONLY `feature.geometry` (GeoJSON Geometry fragment). :contentReference[oaicite:5]{index=5}
 */
async function main() {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const pricingConfigId = await resolvePricingConfigId(supabase);
  console.log(`Using pricing_config_id=${pricingConfigId}`);
  console.log(`SEED_ADMIN_LEVEL=ADM${SEED_ADMIN_LEVEL} DRY_RUN=${DRY_RUN ? "1" : "0"}`);

  const resource = await discoverCodabResource();
  console.log(`COD-AB resource: ${resource.name} (${resource.format})`);
  console.log(`Downloading: ${resource.url}`);

  const geojson = await loadGeojson(resource);
  if (!geojson || geojson.type !== "FeatureCollection" || !Array.isArray(geojson.features)) {
    throw new Error("Expected FeatureCollection GeoJSON");
  }

  // Compute ADM1 P-codes for the 6 target governorates
  const { targets, nameToPcode } = buildTargetAdm1PcodesFromGeojson(geojson);

  // If any are missing, print helpful debug output.
  const missing = TARGET_GOVS.filter((g) => !targets.has(g));
  if (missing.length > 0) {
    console.warn(`[warn] Could not resolve ADM1 P-codes for: ${missing.join(", ")}`);
    console.warn(`[warn] Available ADM1 names (sample):`);
    console.warn(
      [...nameToPcode.keys()].sort().slice(0, 40).map((k) => `- ${k}`).join("\n")
    );
  }

  // Allow overriding targets from env if you want to lock it.
  // Example: TARGET_ADM1_PCODES="IQG01,IQG02,..."
  const envPcodes = process.env.TARGET_ADM1_PCODES
    ? process.env.TARGET_ADM1_PCODES.split(",").map((s) => s.trim()).filter(Boolean)
    : null;

  const targetAdm1Pcodes = envPcodes
    ? new Set(envPcodes)
    : new Set([...targets.values()]);

  console.log(`Target ADM1 PCODES: ${[...targetAdm1Pcodes].join(", ")}`);

  let total = 0;
  let matchedAdm1 = 0;
  let matchedLevel = 0;
  let upserted = 0;

  for (const f of geojson.features) {
    total++;
    const p = f.properties ?? {};

    const adm1Pcode = pickProp(p, ["adm1_pcode", "ADM1_PCODE"]);
    if (!adm1Pcode || !targetAdm1Pcodes.has(String(adm1Pcode))) continue;
    matchedAdm1++;

    const adm1Name = pickProp(p, ["adm1_name", "ADM1_EN", "ADM1"]) || "Unknown";
    const canonGov = canonicalGov(adm1Name) || adm1Name;

    if (SEED_ADMIN_LEVEL === 1) {
      // We only want one feature per ADM1. Prefer the feature that has adm1_pcode but no adm2_pcode.
      const adm2Pcode = pickProp(p, ["adm2_pcode", "ADM2_PCODE"]);
      if (adm2Pcode) continue; // skip district features when seeding ADM1
      matchedLevel++;

      const geom = f.geometry;
      if (!geom) continue;

      const name = `${canonGov} (ADM1)`;
      const cashStep = cashStepForGov(canonGov);

      if (DRY_RUN) {
        console.log(`[dry-run] upsert ADM1 ${name} cash_step=${cashStep}`);
        continue;
      }

      const { error } = await supabase.rpc("admin_upsert_service_area_geojson_v1", {
        p_name: name,
        p_governorate: canonGov,
        p_geojson: geom, // geometry fragment only
        p_priority: 0,
        p_is_active: true,
        p_pricing_config_id: pricingConfigId,
        p_min_base_fare_iqd: null,
        p_surge_multiplier: 1.0,
        p_surge_reason: null,
        p_cash_rounding_step_iqd: cashStep,
      });

      if (error) {
        console.error(`Failed upserting ${name}:`, error);
        continue;
      }
      upserted++;
      continue;
    }

    // ADM2 seeding
    const adm2Name = pickProp(p, ["adm2_name", "ADM2_EN", "ADM2"]);
    const adm2Pcode = pickProp(p, ["adm2_pcode", "ADM2_PCODE"]);
    if (!adm2Name || !adm2Pcode) continue; // ensures district-level feature
    matchedLevel++;

    const geom = f.geometry;
    if (!geom) continue;

    const name = `${canonGov} / ${String(adm2Name).trim()}`;
    const cashStep = cashStepForGov(canonGov);

    if (DRY_RUN) {
      console.log(`[dry-run] upsert ADM2 ${name} cash_step=${cashStep}`);
      continue;
    }

    const { error } = await supabase.rpc("admin_upsert_service_area_geojson_v1", {
      p_name: name,
      p_governorate: canonGov,
      p_geojson: geom, // geometry fragment only
      p_priority: 0,
      p_is_active: true,
      p_pricing_config_id: pricingConfigId,
      p_min_base_fare_iqd: null,
      p_surge_multiplier: 1.0,
      p_surge_reason: null,
      p_cash_rounding_step_iqd: cashStep,
    });

    if (error) {
      console.error(`Failed upserting ${name}:`, error);
      continue;
    }
    upserted++;
    if (upserted % 25 === 0) console.log(`Upserted ${upserted}...`);
  }

  console.log(`GeoJSON features total=${total}`);
  console.log(`Matched target ADM1 PCODE features=${matchedAdm1}`);
  console.log(`Matched admin level (ADM${SEED_ADMIN_LEVEL})=${matchedLevel}`);
  console.log(`Upserted=${upserted}`);
  console.log("Done.");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
