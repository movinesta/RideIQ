import React from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import AdminNav from '../components/AdminNav';
import { supabase } from '../lib/supabaseClient';
import { getIsAdmin } from '../lib/admin';
import { errorText } from '../lib/errors';

type PricingConfigRow = {
  id: string;
  base_fare_iqd: number;
  per_km_iqd: number;
  per_min_iqd: number;
  minimum_fare_iqd: number;
  max_surge_multiplier: number;
  active: boolean;
  updated_at: string;
};

async function fetchPricingConfigs(): Promise<PricingConfigRow[]> {
  const { data, error } = await supabase
    .from('pricing_configs')
    .select('id,base_fare_iqd,per_km_iqd,per_min_iqd,minimum_fare_iqd,max_surge_multiplier,active,updated_at')
    .order('active', { ascending: false })
    .order('updated_at', { ascending: false });
  if (error) throw error;
  return (data as PricingConfigRow[]) ?? [];
}

export default function AdminPricingPage() {
  const qc = useQueryClient();
  const [isAdmin, setIsAdmin] = React.useState<boolean | null>(null);
  const [toast, setToast] = React.useState<string | null>(null);

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

  const pricing = useQuery({ queryKey: ['admin_pricing_configs_caps'], queryFn: fetchPricingConfigs, enabled: isAdmin === true });

  if (isAdmin === false) {
    return <div className="rounded-2xl border border-gray-200 bg-white p-6">Not authorized.</div>;
  }

  return (
    <div className="space-y-4">
      <AdminNav />
      <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="text-sm font-semibold">Pricing</div>
        <div className="text-xs text-gray-500 mt-1">
          Configure surge caps per pricing config. Surge multipliers are capped by <code>max_surge_multiplier</code> and do not affect product multipliers.
        </div>

        {toast ? <div className="mt-3 rounded-xl border p-3 text-sm bg-white">{toast}</div> : null}

        {pricing.isLoading ? <div className="mt-3 text-sm text-gray-600">Loading…</div> : null}
        {pricing.error ? <div className="mt-3 text-sm text-red-700">{errorText(pricing.error)}</div> : null}

        <div className="mt-4 space-y-2">
          {(pricing.data ?? []).map((p) => (
            <div key={p.id} className="rounded-xl border p-3">
              <div className="flex items-start justify-between gap-3 flex-wrap">
                <div className="text-sm">
                  <div className="font-medium">
                    {p.id} {p.active ? <span className="text-emerald-700">(active)</span> : <span className="text-gray-500">(inactive)</span>}
                  </div>
                  <div className="text-xs text-gray-600">
                    base={p.base_fare_iqd} • km={p.per_km_iqd} • min={p.per_min_iqd} • minfare={p.minimum_fare_iqd}
                  </div>
                </div>

                <label className="text-xs text-gray-600">
                  Max surge multiplier
                  <input
                    className="mt-1 w-40 rounded-md border px-2 py-1 text-sm"
                    type="number"
                    step="0.01"
                    min="1"
                    defaultValue={String(p.max_surge_multiplier ?? 1)}
                    onBlur={async (e) => {
                      const v = Number(e.target.value);
                      if (!Number.isFinite(v) || v < 1) {
                        setToast('Max surge multiplier must be a number >= 1.0');
                        return;
                      }
                      setToast(null);
                      const { error } = await supabase.rpc('admin_update_pricing_config_caps', {
                        p_id: p.id,
                        p_max_surge_multiplier: v,
                      });
                      if (error) {
                        setToast(`Error: ${errorText(error)}`);
                        return;
                      }
                      setToast('Saved.');
                      qc.invalidateQueries({ queryKey: ['admin_pricing_configs_caps'] });
                    }}
                  />
                </label>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
