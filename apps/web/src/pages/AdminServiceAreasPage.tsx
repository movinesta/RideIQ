import React from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import AdminNav from '../components/AdminNav';
import { AdminServiceAreaMap, type BBox } from '../components/maps/AdminServiceAreaMap';
import { AdminDriversPreviewMap, type NearbyDriverPoint } from '../components/maps/AdminDriversPreviewMap';
import { supabase } from '../lib/supabaseClient';
import { getIsAdmin } from '../lib/admin';
import { errorText } from '../lib/errors';

type ServiceAreaRow = {
  id: string;
  name: string;
  governorate: string | null;
  is_active: boolean;
  priority: number;
  pricing_config_id: string | null;
  min_base_fare_iqd: number | null;
  surge_multiplier: number;
  surge_reason: string | null;
  created_at: string;
  updated_at: string;
};

type PricingConfigRow = {
  id: string;
  base_fare_iqd: number;
  per_km_iqd: number;
  per_min_iqd: number;
  minimum_fare_iqd: number;
  active: boolean;
};

async function fetchAreas(): Promise<ServiceAreaRow[]> {
  const { data, error } = await supabase
    .from('service_areas')
    .select(
      'id,name,governorate,is_active,priority,pricing_config_id,min_base_fare_iqd,surge_multiplier,surge_reason,created_at,updated_at'
    )
    .order('priority', { ascending: false })
    .order('updated_at', { ascending: false });
  if (error) throw error;
  return (data as ServiceAreaRow[]) ?? [];
}

async function fetchPricingConfigs(): Promise<PricingConfigRow[]> {
  const { data, error } = await supabase
    .from('pricing_configs')
    .select('id,base_fare_iqd,per_km_iqd,per_min_iqd,minimum_fare_iqd,active')
    .order('active', { ascending: false })
    .order('updated_at', { ascending: false });
  if (error) throw error;
  return (data as PricingConfigRow[]) ?? [];
}

export default function AdminServiceAreasPage() {
  const qc = useQueryClient();
  const [isAdmin, setIsAdmin] = React.useState<boolean | null>(null);
  const [toast, setToast] = React.useState<string | null>(null);
  const [busy, setBusy] = React.useState(false);

  const [name, setName] = React.useState('New Area');
  const [governorate, setGovernorate] = React.useState('Baghdad');
  const [priority, setPriority] = React.useState('0');
  const [active, setActive] = React.useState(true);
  const [minLat, setMinLat] = React.useState('33.05');
  const [minLng, setMinLng] = React.useState('44.05');
  const [maxLat, setMaxLat] = React.useState('33.55');
  const [maxLng, setMaxLng] = React.useState('44.75');

  const bbox: BBox = React.useMemo(() => {
    const mnLat = Number(minLat);
    const mnLng = Number(minLng);
    const mxLat = Number(maxLat);
    const mxLng = Number(maxLng);

    // Fallback to a reasonable Baghdad-ish viewport if inputs are invalid.
    const fallback: BBox = { minLat: 33.05, minLng: 44.05, maxLat: 33.55, maxLng: 44.75 };
    if (![mnLat, mnLng, mxLat, mxLng].every((v) => Number.isFinite(v))) return fallback;
    if (mnLat >= mxLat || mnLng >= mxLng) return fallback;
    return { minLat: mnLat, minLng: mnLng, maxLat: mxLat, maxLng: mxLng };
  }, [minLat, minLng, maxLat, maxLng]);
  const [pricingConfigId, setPricingConfigId] = React.useState<string>('');
  const [minBaseFare, setMinBaseFare] = React.useState<string>('');
  const [surgeMultiplier, setSurgeMultiplier] = React.useState<string>('1.00');
  const [surgeReason, setSurgeReason] = React.useState<string>('');

  // Dispatch matching settings (used for preview)
  const [matchRadiusM, setMatchRadiusM] = React.useState<string>('5000');
  const [driverLocStaleAfterS, setDriverLocStaleAfterS] = React.useState<string>('120');

  // Admin diagnostics: preview nearby drivers on a map (does not mutate DB)
  const [previewCenter, setPreviewCenter] = React.useState<{ lat: number; lng: number }>(() => {
    // Center of the current bbox inputs (defaults to a Baghdad-ish viewport)
    return { lat: (33.05 + 33.55) / 2, lng: (44.05 + 44.75) / 2 };
  });
  const [previewDrivers, setPreviewDrivers] = React.useState<NearbyDriverPoint[]>([]);
  const [previewBusy, setPreviewBusy] = React.useState(false);


  const toastError = React.useCallback(
    (e: unknown, prefix: string) => {
      setToast(`${prefix}: ${errorText(e)}`);
    },
    [setToast],
  );

  React.useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const ok = await getIsAdmin();
        if (!alive) return;
        setIsAdmin(ok);
      } catch {
        if (!alive) return;
        setIsAdmin(false);
      }
    })();
    return () => {
      alive = false;
    };
  }, []);

  const areas = useQuery({ queryKey: ['admin_service_areas'], queryFn: fetchAreas, enabled: isAdmin === true });
  const pricing = useQuery({ queryKey: ['admin_pricing_configs'], queryFn: fetchPricingConfigs, enabled: isAdmin === true });

  const refreshPreview = React.useCallback(async () => {
    setPreviewBusy(true);
    try {
      const radius = Math.max(250, Math.min(50000, Number(matchRadiusM || 5000)));
      const stale = Math.max(15, Math.min(3600, Number(driverLocStaleAfterS || 120)));
      const { data, error } = await supabase.rpc('nearby_available_drivers_v1', {
        p_pickup_lat: previewCenter.lat,
        p_pickup_lng: previewCenter.lng,
        p_radius_m: radius,
        p_stale_after_seconds: stale,
      });
      if (error) throw error;
      setPreviewDrivers((data ?? []) as NearbyDriverPoint[]);
    } catch (e) {
      toastError(e, 'Failed to load nearby drivers');
      setPreviewDrivers([]);
    } finally {
      setPreviewBusy(false);
    }
  }, [matchRadiusM, driverLocStaleAfterS, previewCenter.lat, previewCenter.lng, toastError]);

  if (isAdmin === false) {
    return <div className="rounded-2xl border border-gray-200 bg-white p-6">Not authorized.</div>;
  }

  return (
    <div className="space-y-4">
      <AdminNav />
      <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="flex items-start justify-between gap-3 flex-wrap">
          <div>
            <div className="text-sm font-semibold">Service Areas</div>
            <div className="text-xs text-gray-500">
              Define active operating regions (bbox for now). Used to block out-of-area ride requests and scheduled rides.
            </div>
          </div>
        </div>

        {toast ? <div className="mt-3 rounded-xl border p-3 text-sm bg-white">{toast}</div> : null}

        <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-3">
          <Field label="Name" value={name} onChange={setName} />
          <Field label="Governorate" value={governorate} onChange={setGovernorate} />
          <Field label="Priority (higher wins)" value={priority} onChange={setPriority} />
          <label className="text-sm">
            Active
            <div className="mt-2">
              <input type="checkbox" checked={active} onChange={(e) => setActive(e.target.checked)} />
            </div>
          </label>

          <Field label="Min lat" value={minLat} onChange={setMinLat} />
          <Field label="Min lng" value={minLng} onChange={setMinLng} />
          <Field label="Max lat" value={maxLat} onChange={setMaxLat} />
          <Field label="Max lng" value={maxLng} onChange={setMaxLng} />

          <div className="md:col-span-2">
            <div className="text-sm">
              Map editor
              <div className="mt-1 text-xs text-gray-600">
                Draw/resize the rectangle to set the service area bbox. Values will sync into the fields above.
              </div>
            </div>
            <div className="mt-2 rounded-xl overflow-hidden border bg-white">
              <AdminServiceAreaMap
                initialBBox={bbox}
                onBBoxChange={(b) => {
                  setMinLat(b.minLat.toFixed(6));
                  setMinLng(b.minLng.toFixed(6));
                  setMaxLat(b.maxLat.toFixed(6));
                  setMaxLng(b.maxLng.toFixed(6));
                }}
              />
            </div>
          </div>

          <label className="text-sm md:col-span-2">
            Pricing config (optional)
            <select
              className="mt-1 w-full rounded-md border px-3 py-2"
              value={pricingConfigId}
              onChange={(e) => setPricingConfigId(e.target.value)}
            >
              <option value="">(none)</option>
              {(pricing.data ?? []).map((p) => (
                <option key={p.id} value={p.id}>
                  {p.id} — base {p.base_fare_iqd} / km {p.per_km_iqd} / min {p.per_min_iqd} / minfare {p.minimum_fare_iqd}
                  {p.active ? '' : ' (inactive)'}
                </option>
              ))}
            </select>
          </label>

          <Field label="Min base fare override (IQD, optional)" value={minBaseFare} onChange={setMinBaseFare} />

          <Field label="Area surge multiplier (>= 1.0)" value={surgeMultiplier} onChange={setSurgeMultiplier} />

          <Field label="Surge reason (optional)" value={surgeReason} onChange={setSurgeReason} />
        </div>

        <div className="mt-4 flex gap-2 flex-wrap">
          <button
            className="btn bg-black text-white disabled:opacity-50"
            disabled={busy || isAdmin !== true}
            onClick={async () => {
              setToast(null);
              const p = Number(priority);
              const a1 = Number(minLat);
              const o1 = Number(minLng);
              const a2 = Number(maxLat);
              const o2 = Number(maxLng);
              const mb = minBaseFare.trim() === '' ? null : Number(minBaseFare);
              const sm = Number(surgeMultiplier);
              if (!Number.isFinite(p) || !Number.isFinite(a1) || !Number.isFinite(o1) || !Number.isFinite(a2) || !Number.isFinite(o2)) {
                setToast('Please enter valid numeric bbox fields.');
                return;
              }
              if (a2 <= a1 || o2 <= o1) {
                setToast('Invalid bbox: max must be greater than min.');
                return;
              }
              if (mb !== null && (!Number.isFinite(mb) || mb < 0)) {
                setToast('Min base fare override must be a valid non-negative number.');
                return;
              }
              if (!Number.isFinite(sm) || sm < 1) {
                setToast('Surge multiplier must be a number >= 1.0');
                return;
              }

              setBusy(true);
              try {
                const { data, error } = await supabase.rpc('admin_create_service_area_bbox_v2', {
                  p_name: name,
                  p_governorate: governorate,
                  p_priority: p,
                  p_is_active: active,
                  p_min_lat: a1,
                  p_min_lng: o1,
                  p_max_lat: a2,
                  p_max_lng: o2,
                  p_pricing_config_id: pricingConfigId || null,
                  p_min_base_fare_iqd: mb === null ? null : Math.trunc(mb),
                  p_surge_multiplier: sm,
                  p_surge_reason: surgeReason.trim() === '' ? null : surgeReason.trim(),
                });
                if (error) throw error;
                const newId = Array.isArray(data) && data.length > 0 ? (data[0] as any).id : undefined;

                setToast(newId ? `Saved. id=${newId}` : 'Saved.');
                qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
              } catch (e: unknown) {
                setToast(`Error: ${errorText(e)}`);
              } finally {
                setBusy(false);
              }
            }}
          >
            Save (bbox)
          </button>

          <button
            className="btn"
            disabled={busy}
            onClick={() => {
              setName('New Area');
              setGovernorate('Baghdad');
              setPriority('0');
              setActive(true);
              setMinLat('33.05');
              setMinLng('44.05');
              setMaxLat('33.55');
              setMaxLng('44.75');
              setPricingConfigId('');
              setMinBaseFare('');
              setSurgeMultiplier('1.0');
              setSurgeReason('');
              setMatchRadiusM('5000');
              setDriverLocStaleAfterS('120');
            }}
          >
            Reset
          </button>
        </div>
      </div>

      <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="text-sm font-semibold">Dispatch matching settings</div>
            <div className="text-xs text-gray-500">
              These settings are used for the nearby driver preview below (they are not persisted to service areas).
            </div>
          </div>
        </div>

        <div className="mt-3 grid grid-cols-1 md:grid-cols-2 gap-3">
          <Field
            label="Match radius (meters)"
            value={matchRadiusM}
            onChange={setMatchRadiusM}
            placeholder="5000"
            help="Used by matching. Typical: 3000–8000 (city), 10000+ (suburbs)."
          />
          <Field
            label="Driver location stale window (seconds)"
            value={driverLocStaleAfterS}
            onChange={setDriverLocStaleAfterS}
            placeholder="120"
            help="Driver must have a location updated within this window. Keep >= your driver heartbeat interval."
          />
        </div>

        <div className="mt-5 flex flex-wrap items-center justify-between gap-3">
          <div>
            <div className="text-sm font-semibold">Nearby drivers preview (debug)</div>
            <div className="text-xs text-gray-500">
              Click on the map to set a center point, then refresh.
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button className="btn" disabled={previewBusy} onClick={() => refreshPreview()}>
              Refresh drivers
            </button>
            <div className="text-xs text-gray-500">{previewDrivers.length} driver(s)</div>
          </div>
        </div>

        <div className="mt-3">
          <AdminDriversPreviewMap
            center={previewCenter}
            bbox={bbox}
            radius_m={Number(matchRadiusM) || 0}
            drivers={previewDrivers}
            onCenterChange={setPreviewCenter}
          />
        </div>
      </div>

      <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="text-sm font-semibold">Existing areas</div>
        <div className="text-xs text-gray-500">You can toggle active/priority and delete. Geometry edits require bbox save above (overwrite).</div>

        {areas.isLoading ? <div className="mt-3 text-sm text-gray-600">Loading…</div> : null}
        {areas.error ? <div className="mt-3 text-sm text-red-700">{errorText(areas.error)}</div> : null}

        <div className="mt-3 space-y-2">
          {(areas.data ?? []).map((a) => (
            <div key={a.id} className="rounded-xl border p-3 flex items-start justify-between gap-3">
              <div className="text-sm">
                <div className="font-medium">
                  {a.name} {a.governorate ? <span className="text-gray-500">({a.governorate})</span> : null}
                </div>
                <div className="text-gray-600 text-xs">
                  id={a.id} • priority={a.priority} • {a.is_active ? 'active' : 'inactive'} • pricing={a.pricing_config_id ?? '(none)'}
                </div>

                <div className="mt-2 grid grid-cols-1 md:grid-cols-2 gap-2">
                  <label className="text-xs text-gray-600">
                    Pricing config
                    <select
                      className="mt-1 w-full rounded-md border px-2 py-1 text-sm"
                      defaultValue={a.pricing_config_id ?? ''}
                      onChange={async (e) => {
                        const v = e.target.value || null;
                        const { error } = await supabase.from('service_areas').update({ pricing_config_id: v }).eq('id', a.id);
                        if (error) setToast(`Error: ${errorText(error)}`);
                        else qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                      }}
                    >
                      <option value="">(none)</option>
                      {(pricing.data ?? []).map((p) => (
                        <option key={p.id} value={p.id}>
                          {p.id}
                        </option>
                      ))}
                    </select>
                  </label>

                  <label className="text-xs text-gray-600">
                    Min base fare override (IQD)
                    <input
                      className="mt-1 w-full rounded-md border px-2 py-1 text-sm"
                      type="number"
                      step="1"
                      min="0"
                      defaultValue={a.min_base_fare_iqd ?? ''}
                      onBlur={async (e) => {
                        const raw = e.target.value.trim();
                        const v = raw === '' ? null : Math.trunc(Number(raw));
                        if (v !== null && (!Number.isFinite(v) || v < 0)) {
                          setToast('Min base fare must be a non-negative integer (or blank).');
                          return;
                        }
                        const { error } = await supabase.from('service_areas').update({ min_base_fare_iqd: v }).eq('id', a.id);
                        if (error) setToast(`Error: ${errorText(error)}`);
                        else qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                      }}
                    />
                  </label>

                  <label className="text-xs text-gray-600">
                    Surge multiplier (≥ 1.0)
                    <input
                      className="mt-1 w-full rounded-md border px-2 py-1 text-sm"
                      type="number"
                      step="0.01"
                      min="1"
                      defaultValue={String(a.surge_multiplier ?? 1)}
                      onBlur={async (e) => {
                        const v = Number(e.target.value);
                        if (!Number.isFinite(v) || v < 1) {
                          setToast('Surge multiplier must be a number >= 1.0');
                          return;
                        }
                        const { error } = await supabase.from('service_areas').update({ surge_multiplier: v }).eq('id', a.id);
                        if (error) setToast(`Error: ${errorText(error)}`);
                        else qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                      }}
                    />
                  </label>

                  <label className="text-xs text-gray-600">
                    Surge reason
                    <input
                      className="mt-1 w-full rounded-md border px-2 py-1 text-sm"
                      defaultValue={a.surge_reason ?? ''}
                      onBlur={async (e) => {
                        const v = e.target.value.trim();
                        const { error } = await supabase
                          .from('service_areas')
                          .update({ surge_reason: v === '' ? null : v })
                          .eq('id', a.id);
                        if (error) setToast(`Error: ${errorText(error)}`);
                        else qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                      }}
                    />
                  </label>
                </div>

                <div className="mt-4" />
              </div>

              <div className="flex gap-2 flex-wrap items-center">
                <label className="text-xs flex items-center gap-2">
                  Active
                  <input
                    type="checkbox"
                    checked={a.is_active}
                    onChange={async (e) => {
                      setToast(null);
                      try {
                        const { error } = await supabase.from('service_areas').update({ is_active: e.target.checked }).eq('id', a.id);
                        if (error) throw error;
                        qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                      } catch (err: unknown) {
                        setToast(`Error: ${errorText(err)}`);
                      }
                    }}
                  />
                </label>

                <input
                  className="w-20 rounded-md border px-2 py-1 text-xs"
                  defaultValue={String(a.priority)}
                  onBlur={async (e) => {
                    const p = Number(e.target.value);
                    if (!Number.isFinite(p)) return;
                    setToast(null);
                    try {
                      const { error } = await supabase.from('service_areas').update({ priority: p }).eq('id', a.id);
                      if (error) throw error;
                      qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                    } catch (err: unknown) {
                      setToast(`Error: ${errorText(err)}`);
                    }
                  }}
                />

                <button
                  className="btn text-rose-700"
                  onClick={async () => {
                    setToast(null);
                    if (!confirm(`Delete service area "${a.name}"?`)) return;
                    try {
                      const { error } = await supabase.from('service_areas').delete().eq('id', a.id);
                      if (error) throw error;
                      qc.invalidateQueries({ queryKey: ['admin_service_areas'] });
                    } catch (err: unknown) {
                      setToast(`Error: ${errorText(err)}`);
                    }
                  }}
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
  placeholder,
  help,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  help?: string;
}) {
  return (
    <label className="text-sm">
      {label}
      <input
        className="mt-1 w-full rounded-md border px-3 py-2"
        value={value}
        placeholder={placeholder}
        onChange={(e) => onChange(e.target.value)}
      />
      {help ? <div className="mt-1 text-xs text-gray-500">{help}</div> : null}
    </label>
  );
}
