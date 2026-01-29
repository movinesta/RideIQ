import React from 'react';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { errorText } from '../lib/errors';
import { MapView, type LatLng, type MapMarker } from '../components/maps/MapView';

type ShareResponse = {
  ok?: boolean;
  token_mode?: 'hash' | 'token' | 'legacy_token';
  ride?: {
    id: string;
    status: string;
    created_at: string;
    started_at?: string | null;
    completed_at?: string | null;
    fare_amount_iqd?: number | null;
    currency?: string | null;
  };
  request?: {
    id: string;
    status: string;
    pickup: { lat: number; lng: number; address?: string | null };
    dropoff: { lat: number; lng: number; address?: string | null };
    product_code?: string | null;
    service_area_id?: string | null;
    matched_at?: string | null;
    accepted_at?: string | null;
  } | null;
  driver?: { id: string } | null;
  vehicle?: {
    make: string | null;
    model: string | null;
    color: string | null;
    vehicle_type: string | null;
    capacity?: number | null;
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

function isValidLatLng(x: unknown): x is LatLng {
  const v = x as any;
  const lat = Number(v?.lat);
  const lng = Number(v?.lng);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false;
  if (Math.abs(lat) > 90 || Math.abs(lng) > 180) return false;
  // Treat (0,0) as "unset" in our app flows
  if (lat === 0 && lng === 0) return false;
  return true;
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

  const pickup = data?.request?.pickup;
  const dropoff = data?.request?.dropoff;
  const driverLoc = data?.location;

  const pickupPos = isValidLatLng(pickup) ? (pickup as LatLng) : null;
  const dropoffPos = isValidLatLng(dropoff) ? (dropoff as LatLng) : null;
  const driverPos = isValidLatLng(driverLoc) ? ({ lat: driverLoc!.lat, lng: driverLoc!.lng } as LatLng) : null;

  const center: LatLng | null = driverPos ?? pickupPos ?? dropoffPos ?? null;

  const markers: MapMarker[] = [];
  if (pickupPos) markers.push({ id: 'pickup', position: pickupPos, label: 'P', title: 'Pickup' });
  if (dropoffPos) markers.push({ id: 'dropoff', position: dropoffPos, label: 'D', title: 'Dropoff' });
  if (driverPos) markers.push({ id: 'driver', position: driverPos, label: '🚗', title: 'Driver' });

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

              {driverPos ? (
                <a className="btn" href={mapsLink(driverPos.lat, driverPos.lng)} target="_blank" rel="noreferrer">
                  {t('share.openMaps')}
                </a>
              ) : pickupPos ? (
                <a className="btn" href={mapsLink(pickupPos.lat, pickupPos.lng)} target="_blank" rel="noreferrer">
                  {t('share.openMaps')}
                </a>
              ) : null}
            </div>

            {center ? (
              <div className="rounded-xl border border-gray-200 overflow-hidden">
                <MapView
                  center={center}
                  zoom={14}
                  markers={markers}
                  className="h-72 w-full"
                />
              </div>
            ) : null}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="rounded-xl border border-gray-200 p-3">
                <div className="text-xs text-gray-500">{t('share.pickup')}</div>
                <div className="text-sm font-medium mt-1">
                  {pickupPos ? `${pickupPos.lat.toFixed(5)}, ${pickupPos.lng.toFixed(5)}` : '—'}
                </div>
                {pickup?.address ? <div className="text-xs text-gray-500 mt-1">{pickup.address}</div> : null}
              </div>
              <div className="rounded-xl border border-gray-200 p-3">
                <div className="text-xs text-gray-500">{t('share.dropoff')}</div>
                <div className="text-sm font-medium mt-1">
                  {dropoffPos ? `${dropoffPos.lat.toFixed(5)}, ${dropoffPos.lng.toFixed(5)}` : '—'}
                </div>
                {dropoff?.address ? <div className="text-xs text-gray-500 mt-1">{dropoff.address}</div> : null}
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
              {driverPos && data.location ? (
                <div>
                  {t('share.lastLocation')}: {driverPos.lat.toFixed(5)}, {driverPos.lng.toFixed(5)}
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
