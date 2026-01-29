import React from 'react';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { errorText } from '../lib/errors';

type ShareResponse = {
  ride?: {
    id: string;
    status: string;
    pickup: { lat: number; lng: number };
    dropoff: { lat: number; lng: number };
    created_at: string;
  };
  vehicle?: {
    make: string | null;
    model: string | null;
    color: string | null;
    vehicle_type: string | null;
    plate_suffix: string | null;
  } | null;
  location?: {
    lat: number;
    lng: number;
    updated_at: string;
  } | null;
  error?: string;
};

function mapsLink(lat: number, lng: number) {
  return `https://www.google.com/maps?q=${encodeURIComponent(`${lat},${lng}`)}`;
}

async function fetchShare(token: string): Promise<ShareResponse> {
  const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL as string | undefined) ?? '';
  const anon = (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) ?? '';
  if (!supabaseUrl || !anon) throw new Error('Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY');

  const url = `${supabaseUrl.replace(/\/$/, '')}/functions/v1/trip-share-view?token=${encodeURIComponent(token)}`;
  const res = await fetch(url, {
    method: 'GET',
    headers: {
      apikey: anon,
      Authorization: `Bearer ${anon}`,
    },
  });

  const data = (await res.json().catch(() => ({}))) as ShareResponse;
  if (!res.ok) {
    const msg = typeof data?.error === 'string' && data.error ? data.error : `HTTP ${res.status}`;
    throw new Error(msg);
  }
  return data;
}

export default function ShareTripPage() {
  const { t } = useTranslation();
  const { token } = useParams();
  const [data, setData] = React.useState<ShareResponse | null>(null);
  const [err, setErr] = React.useState<string | null>(null);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    let mounted = true;
    const tk = (token ?? '').trim();
    if (!tk) {
      setErr('missing_token');
      setLoading(false);
      return;
    }

    const run = async () => {
      setLoading(true);
      try {
        const r = await fetchShare(tk);
        if (!mounted) return;
        setData(r);
        setErr(null);
      } catch (e: unknown) {
        if (!mounted) return;
        setErr(errorText(e));
      } finally {
        if (mounted) setLoading(false);
      }
    };

    void run();
    const id = window.setInterval(run, 8000);
    return () => {
      mounted = false;
      window.clearInterval(id);
    };
  }, [token]);

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-2xl mx-auto space-y-3">
        <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm">
          <div className="text-base font-semibold">{t('share.title')}</div>
          <div className="text-xs text-gray-500 mt-1">{t('share.subtitle')}</div>
        </div>

        {loading ? (
          <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm text-sm text-gray-600">{t('share.loading')}</div>
        ) : err ? (
          <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm text-sm text-red-600">
            {t('share.error')}: {err}
          </div>
        ) : data?.ride ? (
          <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm space-y-3">
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <div className="text-sm font-semibold">{t('share.ride')} {data.ride.id.slice(0, 8)}…</div>
                <div className="text-xs text-gray-500 mt-1">{t('share.status')}: {data.ride.status}</div>
                <div className="text-xs text-gray-500">{t('share.created')}: {new Date(data.ride.created_at).toLocaleString()}</div>
              </div>

              {data.location ? (
                <a
                  className="btn"
                  href={mapsLink(data.location.lat, data.location.lng)}
                  target="_blank"
                  rel="noreferrer"
                >
                  {t('share.openMaps')}
                </a>
              ) : null}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="rounded-xl border border-gray-200 p-3">
                <div className="text-xs text-gray-500">{t('share.pickup')}</div>
                <div className="text-sm font-medium mt-1">
                  {data.ride.pickup.lat.toFixed(5)}, {data.ride.pickup.lng.toFixed(5)}
                </div>
              </div>
              <div className="rounded-xl border border-gray-200 p-3">
                <div className="text-xs text-gray-500">{t('share.dropoff')}</div>
                <div className="text-sm font-medium mt-1">
                  {data.ride.dropoff.lat.toFixed(5)}, {data.ride.dropoff.lng.toFixed(5)}
                </div>
              </div>
            </div>

            {data.vehicle ? (
              <div className="rounded-xl border border-gray-200 p-3">
                <div className="text-xs text-gray-500">{t('share.vehicle')}</div>
                <div className="text-sm mt-1">
                  {[data.vehicle.vehicle_type, data.vehicle.color, data.vehicle.make, data.vehicle.model].filter(Boolean).join(' · ') || '—'}
                </div>
                {data.vehicle.plate_suffix ? (
                  <div className="text-xs text-gray-500 mt-1">{t('share.plateSuffix')}: {data.vehicle.plate_suffix}</div>
                ) : null}
              </div>
            ) : null}

            <div className="rounded-xl border border-gray-200 bg-gray-50 p-3 text-xs text-gray-600">
              {data.location ? (
                <div>
                  {t('share.lastLocation')}: {data.location.lat.toFixed(5)}, {data.location.lng.toFixed(5)}
                  <span className="text-gray-400"> · {new Date(data.location.updated_at).toLocaleTimeString()}</span>
                </div>
              ) : (
                <div>{t('share.noLocation')}</div>
              )}
            </div>
          </div>
        ) : (
          <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm text-sm text-gray-600">{t('share.notFound')}</div>
        )}
      </div>
    </div>
  );
}
