import React from 'react';
import type { Session } from '@supabase/supabase-js';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import { errorText } from '../lib/errors';
import { invokeEdge } from '../lib/edgeInvoke';

type BookingView = {
  booking?: {
    pickup: { lat: number; lng: number; address: string | null };
    dropoff: { lat: number; lng: number; address: string | null };
    expires_at: string;
  };
  error?: string;
};

function mapsLink(lat: number, lng: number) {
  return `https://www.google.com/maps?q=${encodeURIComponent(`${lat},${lng}`)}`;
}

async function fetchBooking(token: string): Promise<BookingView> {
  const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL as string | undefined) ?? '';
  const anon = (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) ?? '';
  if (!supabaseUrl || !anon) throw new Error('Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY');

  const url = `${supabaseUrl.replace(/\/$/, '')}/functions/v1/whatsapp-booking-view?token=${encodeURIComponent(token)}`;
  const res = await fetch(url, {
    method: 'GET',
    headers: {
      apikey: anon,
      Authorization: `Bearer ${anon}`,
    },
  });

  const data = (await res.json().catch(() => ({}))) as unknown;
  if (!res.ok) {
    if (typeof data === 'object' && data !== null && 'error' in data && typeof data.error === 'string') {
      return { error: data.error };
    }
    return { error: `HTTP ${res.status}` };
  }
  if (typeof data === 'object' && data !== null) {
    return data as BookingView;
  }
  return {};
}

export default function WhatsAppBookingPage() {
  const { token } = useParams();
  const [loading, setLoading] = React.useState(true);
  const [booking, setBooking] = React.useState<BookingView | null>(null);
  const [err, setErr] = React.useState<string | null>(null);

  const [session, setSession] = React.useState<Session | null>(null);
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [authMode, setAuthMode] = React.useState<'signin' | 'signup'>('signin');
  const [authBusy, setAuthBusy] = React.useState(false);

  const [confirmBusy, setConfirmBusy] = React.useState(false);
  const [confirmOk, setConfirmOk] = React.useState<string | null>(null);

  React.useEffect(() => {
    let mounted = true;

    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return;
      setSession(data.session ?? null);
    });

    const { data: sub } = supabase.auth.onAuthStateChange((_evt, s) => {
      setSession(s ?? null);
    });

    return () => {
      mounted = false;
      sub?.subscription?.unsubscribe();
    };
  }, []);

  React.useEffect(() => {
    let mounted = true;
    setLoading(true);
    setErr(null);
    setBooking(null);

    const t = (token ?? '').trim();
    if (!t) {
      setErr('Missing token');
      setLoading(false);
      return;
    }

    fetchBooking(t)
      .then((d) => {
        if (!mounted) return;
        if (d.error) setErr(d.error);
        setBooking(d);
      })
      .catch((e) => mounted && setErr(errorText(e)))
      .finally(() => mounted && setLoading(false));

    return () => {
      mounted = false;
    };
  }, [token]);

  async function doAuth() {
    setAuthBusy(true);
    setErr(null);
    try {
      if (authMode === 'signin') {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
      } else {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
      }
    } catch (e) {
      setErr(errorText(e));
    } finally {
      setAuthBusy(false);
    }
  }

  async function confirmRide() {
    const t = (token ?? '').trim();
    if (!t) return;

    setConfirmBusy(true);
    setConfirmOk(null);
    setErr(null);
    try {
      const { data } = await invokeEdge<{ ride_intent_id: string }>('whatsapp-booking-consume', { token: t });
      setConfirmOk(data.ride_intent_id);
    } catch (e) {
      setErr(errorText(e));
    } finally {
      setConfirmBusy(false);
    }
  }

  const b = booking?.booking;

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="mx-auto max-w-2xl p-6">
        <div className="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm">
          <div className="text-xl font-semibold">RideIQ WhatsApp Booking</div>
          <div className="text-sm text-gray-500 mt-1">
            Confirm your ride request created from WhatsApp.
          </div>

          {loading ? <div className="mt-6 text-sm text-gray-500">Loading…</div> : null}

          {err ? (
            <div className="mt-6 rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-800">
              {err}
            </div>
          ) : null}

          {b ? (
            <div className="mt-6 space-y-4">
              <div className="rounded-2xl border border-gray-200 p-4">
                <div className="text-sm font-semibold">Pickup</div>
                <div className="text-sm text-gray-700 mt-1">
                  {b.pickup.address ? b.pickup.address : `${b.pickup.lat}, ${b.pickup.lng}`}
                </div>
                <a
                  className="text-sm text-blue-600 hover:underline"
                  href={mapsLink(b.pickup.lat, b.pickup.lng)}
                  target="_blank"
                  rel="noreferrer"
                >
                  Open in Google Maps
                </a>
              </div>

              <div className="rounded-2xl border border-gray-200 p-4">
                <div className="text-sm font-semibold">Drop-off</div>
                <div className="text-sm text-gray-700 mt-1">
                  {b.dropoff.address ? b.dropoff.address : `${b.dropoff.lat}, ${b.dropoff.lng}`}
                </div>
                <a
                  className="text-sm text-blue-600 hover:underline"
                  href={mapsLink(b.dropoff.lat, b.dropoff.lng)}
                  target="_blank"
                  rel="noreferrer"
                >
                  Open in Google Maps
                </a>
              </div>

              <div className="text-xs text-gray-500">
                Token expires at: {new Date(b.expires_at).toLocaleString()}
              </div>
            </div>
          ) : null}

          <div className="mt-8 border-t border-gray-100 pt-6">
            {!session ? (
              <div>
                <div className="text-sm font-semibold">Sign in to confirm</div>
                <div className="text-sm text-gray-500 mt-1">
                  Sign in (or create an account) to attach this WhatsApp request to your profile.
                </div>

                <div className="mt-4 flex gap-2">
                  <button
                    className={authMode === 'signin' ? 'px-3 py-2 rounded-xl bg-gray-900 text-white text-sm' : 'px-3 py-2 rounded-xl border border-gray-200 text-sm hover:bg-gray-50'}
                    onClick={() => setAuthMode('signin')}
                    type="button"
                    disabled={authBusy}
                  >
                    Sign in
                  </button>
                  <button
                    className={authMode === 'signup' ? 'px-3 py-2 rounded-xl bg-gray-900 text-white text-sm' : 'px-3 py-2 rounded-xl border border-gray-200 text-sm hover:bg-gray-50'}
                    onClick={() => setAuthMode('signup')}
                    type="button"
                    disabled={authBusy}
                  >
                    Sign up
                  </button>
                </div>

                <div className="mt-4 grid gap-3">
                  <input
                    className="w-full rounded-2xl border border-gray-200 px-4 py-3 text-sm"
                    placeholder="Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    type="email"
                    autoComplete="email"
                  />
                  <input
                    className="w-full rounded-2xl border border-gray-200 px-4 py-3 text-sm"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    type="password"
                    autoComplete={authMode === 'signin' ? 'current-password' : 'new-password'}
                  />
                  <button
                    className="w-full rounded-2xl bg-gray-900 px-4 py-3 text-sm font-semibold text-white disabled:opacity-60"
                    onClick={doAuth}
                    disabled={authBusy || !email || !password}
                    type="button"
                  >
                    {authBusy ? 'Please wait…' : authMode === 'signin' ? 'Sign in' : 'Create account'}
                  </button>
                </div>

                <div className="mt-4 text-xs text-gray-500">
                  After signing in, this page will allow you to confirm the ride.
                </div>
              </div>
            ) : (
              <div>
                <div className="text-sm font-semibold">Ready</div>
                <div className="text-sm text-gray-500 mt-1">
                  Signed in as <span className="font-mono">{session.user?.email}</span>
                </div>

                <div className="mt-4 flex items-center gap-3 flex-wrap">
                  <button
                    className="rounded-2xl bg-emerald-600 px-4 py-3 text-sm font-semibold text-white disabled:opacity-60"
                    onClick={confirmRide}
                    disabled={confirmBusy || !b}
                    type="button"
                  >
                    {confirmBusy ? 'Confirming…' : 'Confirm ride'}
                  </button>
                  <Link className="text-sm text-blue-600 hover:underline" to="/rider">
                    Go to app
                  </Link>
                </div>

                {confirmOk ? (
                  <div className="mt-4 rounded-2xl border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-900">
                    Confirmed. Ride intent created: <span className="font-mono">{confirmOk}</span>
                  </div>
                ) : null}
              </div>
            )}
          </div>

          <div className="mt-8 text-xs text-gray-400">
            Tip: In WhatsApp, type <span className="font-semibold">START</span> to begin a new request.
          </div>
        </div>
      </div>
    </div>
  );
}
