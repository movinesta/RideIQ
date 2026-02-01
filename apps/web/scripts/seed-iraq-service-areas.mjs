/**
 * Seed Iraq service areas from HDX COD-AB.
 *
 * Key improvements:
 * - Robust resolution of target governorates (including Al-Qadisiyyah ↔ Al-Diwaniyah)
 * - Filters by ADM1 PCODE (stable) after resolving codes from dataset content
 * - Ensures ADM2 mode seeds ONLY ADM2 (districts) by excluding any feature that has adm3_pcode
 * - Always passes GeoJSON geometry fragment (feature.geometry) to PostGIS/RPC
 *
 * Required env:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * Optional env:
 *   CODAB_DATASET_ID=cod-ab-irq
 *   CODAB_RESOURCE_ID=<uuid>        // force a specific HDX resource
 *   SEED_ADMIN_LEVEL=2              // 1=ADM1, 2=ADM2 (default)
 *   DRY_RUN=1
 *   PRICING_CONFIG_ID=<uuid>
 *   CASH_STEP_IQD=250
 *   CASH_STEP_BAGHDAD=250, CASH_STEP_BABIL=..., etc
 *   TARGET_ADM1_PCODES="IQG..,IQG.." // optional hard override if you want to lock it
 */

import { createClient } from "@supabase/supabase-js";
import fs from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import { execFileSync } from "node:child_process";

// -------------------- ENV --------------------
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

const SEED_ADMIN_LEVEL = Number(process.env.SEED_ADMIN_LEVEL || 2);
if (![1, 2].includes(SEED_ADMIN_LEVEL)) {
  console.error(`SEED_ADMIN_LEVEL must be 1 or 2 (got ${SEED_ADMIN_LEVEL})`);
  process.exit(1);
}

const DRY_RUN = process.env.DRY_RUN === "1" || process.env.DRY_RUN === "true";
const DEFAULT_CASH_STEP = Math.trunc(Number(process.env.CASH_STEP_IQD || 250));

// Initial rollout governorates (canonical names in YOUR system)
const TARGET_GOVS = [
  "Baghdad",
  "Babil",
  "Al-Qadisiyyah",
  "Najaf",
  "Muthanna",
  "Karbala",
];

// -------------------- HELPERS --------------------
function norm(s) {
  return String(s ?? "")
    .normalize("NFKD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .replace(/[`´’'"]/g, "")
    .replace(/-/g, " ")
    .replace(/\b(governorate|province)\b/g, "")
    .replace(/\s+/g, " ")
    .trim();
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

/**
 * Expanded aliasing:
 * - Karbala sometimes appears as "Kerbala" in transliterations
 * - Al-Qadisiyyah is also known as "Al Diwaniyah" (common alternate) :contentReference[oaicite:3]{index=3}
 */
const GOV_ALIASES = new Map([
  ["Baghdad", new Set(["baghdad"])],
  ["Babil", new Set(["babil", "babylon"])],
  [
    "Al-Qadisiyyah",
    new Set([
      "al qadisiyyah",
      "al qadisiyah",
      "al qadisiyya",
      "al qadisiya",
      "qadisiyyah",
      "qadisiyah",
      "qadisiyya",
      "qadisiya",
      // Alternate commonly used name
      "al diwaniyah",
      "diwaniyah",
      "ad diwaniyah",
      "diwaniya",
    ]),
  ],
  ["Najaf", new Set(["najaf", "an najaf", "al najaf"])],
  ["Karbala", new Set(["karbala", "karbalaa", "kerbala"])],
  ["Muthanna", new Set(["muthanna", "al muthanna", "al muthana"])],
]);

function canonicalGovFromAdm1Name(adm1Name) {
  const n = norm(adm1Name);
  for (const [canon, set] of GOV_ALIASES.entries()) {
    if (set.has(n)) return canon;
  }
  return null;
}

function cashStepForGov(canonGov) {
  const key = `CASH_STEP_${canonGov.toUpperCase().replace(/[^A-Z0-9]/g, "_")}`;
  const v = process.env[key];
  if (!v) return DEFAULT_CASH_STEP;
  const n = Math.trunc(Number(v));
  return Number.isFinite(n) && n > 0 ? n : DEFAULT_CASH_STEP;
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
 * CKAN Action API package_show is how we enumerate HDX dataset resources. :contentReference[oaicite:4]{index=4}
 */
async function discoverCodabResource() {
  const pkg = await fetchJson(
    `https://data.humdata.org/api/3/action/package_show?id=${encodeURIComponent(DATASET_ID)}`
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

  // Try level-labeled resource names first, otherwise fallback.
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

async function loadGeojson(resource) {
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "codab-irq-"));
  const url = resource.url;
  const outPath = path.join(
    tmpDir,
    path.basename(new URL(url).pathname) || `codab_${resource.id}`
  );

  await download(url, outPath);

  if (outPath.toLowerCase().endsWith(".zip")) {
    execFileSync("unzip", ["-q", outPath, "-d", tmpDir], { stdio: "inherit" });

    const entries = await fs.readdir(tmpDir, { recursive: true });
    const jsonFiles = entries
      .map((e) => String(e))
      .filter(
        (f) =>
          f.toLowerCase().endsWith(".geojson") || f.toLowerCase().endsWith(".json")
      );

    if (jsonFiles.length === 0) {
      throw new Error(`ZIP did not contain .geojson/.json files: ${url}`);
    }

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
 * Resolve target ADM1 PCODES robustly:
 * - Build map from dataset: canonicalGov -> adm1_pcode
 * - Use adm1_name (English) + fallback adm1_ref_n when present
 * - If still missing, print all ADM1 candidates (pcode + name) so you can lock with TARGET_ADM1_PCODES.
 *
 * COD-AB is meant to be used with P-codes as stable IDs. :contentReference[oaicite:5]{index=5}
 */
function resolveTargetAdm1Pcodes(geojson) {
  const mapCanonToPcode = new Map();
  const candidates = new Map(); // adm1_pcode -> one representative name

  for (const f of geojson.features) {
    const p = f.properties ?? {};
    const adm1Pcode = pickProp(p, ["adm1_pcode", "ADM1_PCODE"]);
    if (!adm1Pcode) continue;

    const adm1Name = pickProp(p, ["adm1_name", "ADM1_EN", "ADM1", "adm1_ref_n"]);
    if (adm1Name) {
      candidates.set(String(adm1Pcode), String(adm1Name));
    }

    const canon = canonicalGovFromAdm1Name(adm1Name);
    if (canon && !mapCanonToPcode.has(canon)) {
      mapCanonToPcode.set(canon, String(adm1Pcode));
    }
  }

  const missing = TARGET_GOVS.filter((g) => !mapCanonToPcode.has(g));
  return { mapCanonToPcode, candidates, missing };
}

// -------------------- MAIN --------------------
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

  // Optional override: lock to known ADM1 PCODES (comma-separated)
  const envPcodes = process.env.TARGET_ADM1_PCODES
    ? process.env.TARGET_ADM1_PCODES.split(",").map((s) => s.trim()).filter(Boolean)
    : null;

  let targetAdm1Pcodes = null;

  if (envPcodes && envPcodes.length > 0) {
    targetAdm1Pcodes = new Set(envPcodes);
    console.log(`Target ADM1 PCODES (from env): ${[...targetAdm1Pcodes].join(", ")}`);
  } else {
    const { mapCanonToPcode, candidates, missing } = resolveTargetAdm1Pcodes(geojson);

    console.log(
      `Resolved target ADM1 PCODES:\n` +
        TARGET_GOVS.map((g) => `- ${g}: ${mapCanonToPcode.get(g) || "NOT_FOUND"}`).join("\n")
    );

    if (missing.length > 0) {
      console.warn(`[warn] Missing ADM1 PCODES for: ${missing.join(", ")}`);
      console.warn(`[warn] ADM1 candidates seen (pcode -> name sample):`);
      console.warn(
        [...candidates.entries()]
          .sort((a, b) => a[0].localeCompare(b[0]))
          .slice(0, 50)
          .map(([pc, nm]) => `- ${pc} -> ${nm}`)
          .join("\n")
      );
      console.warn(
        `[warn] If you want to hard-lock, set TARGET_ADM1_PCODES="pcode1,pcode2,..." in your workflow.`
      );
    }

    targetAdm1Pcodes = new Set(
      TARGET_GOVS.map((g) => mapCanonToPcode.get(g)).filter(Boolean)
    );
    console.log(`Target ADM1 PCODES (auto): ${[...targetAdm1Pcodes].join(", ")}`);
  }

  if (!targetAdm1Pcodes || targetAdm1Pcodes.size === 0) {
    throw new Error("No target ADM1 PCODES resolved. Use TARGET_ADM1_PCODES override.");
  }

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

    const adm1Name = pickProp(p, ["adm1_name", "ADM1_EN", "ADM1", "adm1_ref_n"]) || "Unknown";
    const canonGov = canonicalGovFromAdm1Name(adm1Name) || String(adm1Name).trim();

    const geom = f.geometry;
    if (!geom) continue;

    if (SEED_ADMIN_LEVEL === 1) {
      // Require it to be an ADM1 feature (no adm2/adm3 pcodes)
      const adm2Pcode = pickProp(p, ["adm2_pcode", "ADM2_PCODE"]);
      const adm3Pcode = pickProp(p, ["adm3_pcode", "ADM3_PCODE"]);
      if (adm2Pcode || adm3Pcode) continue;
      matchedLevel++;

      const name = `${canonGov} (ADM1)`;
      const cashStep = cashStepForGov(canonGov);

      if (DRY_RUN) {
        console.log(`[dry-run] upsert ADM1 ${name} cash_step=${cashStep}`);
        continue;
      }

      const { error } = await supabase.rpc("admin_upsert_service_area_geojson_v1", {
        p_name: name,
        p_governorate: canonGov,
        p_geojson: geom, // geometry fragment (best practice for PostGIS GeoJSON ingestion) :contentReference[oaicite:6]{index=6}
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

    // SEED_ADMIN_LEVEL === 2 (ADM2 districts)
    // IMPORTANT: exclude ADM3 by requiring adm2_pcode present and adm3_pcode absent.
    const adm2Name = pickProp(p, ["adm2_name", "ADM2_EN", "ADM2"]);
    const adm2Pcode = pickProp(p, ["adm2_pcode", "ADM2_PCODE"]);
    const adm3Pcode = pickProp(p, ["adm3_pcode", "ADM3_PCODE"]);
    if (!adm2Name || !adm2Pcode) continue;
    if (adm3Pcode) continue; // don't seed subdistricts
    matchedLevel++;

    const name = `${canonGov} / ${String(adm2Name).trim()}`;
    const cashStep = cashStepForGov(canonGov);

    if (DRY_RUN) {
      console.log(`[dry-run] upsert ADM2 ${name} cash_step=${cashStep}`);
      continue;
    }

    const { error } = await supabase.rpc("admin_upsert_service_area_geojson_v1", {
      p_name: name,
      p_governorate: canonGov,
      p_geojson: geom,
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
