import React from 'react';
import { Link } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../lib/supabaseClient';
import { getMyProfileBasics } from '../lib/profile';
import { claimOrderDelivery, listAvailableDeliveries, listMyDeliveries, setDeliveryStatus, type MerchantOrderDelivery } from '../lib/deliveries';
import { formatIQD } from '../lib/money';
import { errorText } from '../lib/errors';

function addrText(snapshot: any) {
  if (!snapshot) return '';
  const bits = [snapshot.city, snapshot.area, snapshot.address_line1, snapshot.address_line2].filter(Boolean);
  return bits.join(' • ');
}

export default function DriverDeliveriesPage() {
  const qc = useQueryClient();

  const profileQ = useQuery({ queryKey: ['my-profile-basics'], queryFn: getMyProfileBasics });

  const uidQ = useQuery({
    queryKey: ['my-uid'],
    queryFn: async () => {
      const { data } = await supabase.auth.getSession();
      return data.session?.user.id ?? null;
    },
  });

  const uid = uidQ.data;

  const availableQ = useQuery({
    queryKey: ['deliveries', 'available'],
    queryFn: () => listAvailableDeliveries(100),
    enabled: Boolean(uid),
    refetchInterval: 5000,
  });

  const myQ = useQuery({
    queryKey: ['deliveries', 'mine', uid],
    queryFn: () => listMyDeliveries(uid as string, 100),
    enabled: Boolean(uid),
    refetchInterval: 5000,
  });

  // Realtime updates
  React.useEffect(() => {
    if (!uid) return;
    const ch = supabase
      .channel(`driver-deliveries:${uid}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'merchant_order_deliveries' }, () => {
        void qc.invalidateQueries({ queryKey: ['deliveries'] });
      })
      .subscribe();

    return () => {
      void supabase.removeChannel(ch);
    };
  }, [uid, qc]);

  const claimM = useMutation({
    mutationFn: async (deliveryId: string) => {
      await claimOrderDelivery(deliveryId);
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ['deliveries'] });
      await qc.invalidateQueries({ queryKey: ['user_notifications'] });
    },
  });

  const setStatusM = useMutation({
    mutationFn: async (input: { deliveryId: string; status: 'picked_up' | 'delivered' }) => {
      await setDeliveryStatus(input.deliveryId, input.status);
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ['deliveries'] });
      await qc.invalidateQueries({ queryKey: ['user_notifications'] });
    },
  });

  const role = profileQ.data?.active_role;

  if (uidQ.isLoading) return <div className="p-6">Loading…</div>;
  if (!uid) return <div className="p-6">Please sign in.</div>;

  if (role !== 'driver') {
    return (
      <div className="p-6 space-y-3">
        <div className="text-xl font-semibold">Driver Deliveries</div>
        <div className="text-sm text-gray-600">Switch your active role to <span className="font-medium">driver</span> to access delivery jobs.</div>
        <Link className="btn" to="/driver">Go to Driver</Link>
      </div>
    );
  }

  const available = (availableQ.data ?? []) as MerchantOrderDelivery[];
  const mine = (myQ.data ?? []) as MerchantOrderDelivery[];

  const activeMine = mine.filter((d) => d.status !== 'delivered' && d.status !== 'cancelled');

  return (
    <div className="p-4 md:p-6 space-y-4">
      <div className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <div className="text-xl font-semibold">Delivery jobs</div>
          <div className="text-xs text-gray-500">Claim a job → pick up → deliver</div>
        </div>
        <Link className="btn" to="/driver">Back to driver</Link>
      </div>

      {(availableQ.error || myQ.error || claimM.error || setStatusM.error) ? (
        <div className="text-sm text-red-700">
          {errorText(availableQ.error || myQ.error || claimM.error || setStatusM.error)}
        </div>
      ) : null}

      <div className="grid md:grid-cols-2 gap-4">
        <div className="card p-5 space-y-3">
          <div className="font-semibold">Available</div>
          {availableQ.isLoading ? <div className="text-sm text-gray-500">Loading…</div> : null}
          {available.length === 0 && !availableQ.isLoading ? <div className="text-sm text-gray-500">No delivery requests right now.</div> : null}
          <div className="space-y-3">
            {available.map((d) => (
              <div key={d.id} className="rounded-2xl border border-gray-200 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="text-sm font-semibold">Order #{String(d.order_id).slice(0, 8)}</div>
                    <div className="text-xs text-gray-500 mt-1">Fee: {formatIQD(d.fee_iqd)}</div>
                    <div className="text-xs text-gray-500 mt-1">Pickup: {d.pickup_snapshot?.business_name || d.pickup_snapshot?.address_text || '—'}</div>
                    <div className="text-xs text-gray-500 mt-1">Dropoff: {addrText(d.dropoff_snapshot) || '—'}</div>
                  </div>
                  <button
                    className="btn btn-primary"
                    disabled={claimM.isPending}
                    onClick={() => claimM.mutate(d.id)}
                  >
                    {claimM.isPending ? 'Claiming…' : 'Claim'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="card p-5 space-y-3">
          <div className="font-semibold">My active deliveries</div>
          {myQ.isLoading ? <div className="text-sm text-gray-500">Loading…</div> : null}
          {activeMine.length === 0 && !myQ.isLoading ? <div className="text-sm text-gray-500">No active deliveries.</div> : null}
          <div className="space-y-3">
            {activeMine.map((d) => (
              <div key={d.id} className="rounded-2xl border border-gray-200 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="text-sm font-semibold">Order #{String(d.order_id).slice(0, 8)}</div>
                    <div className="text-xs text-gray-500 mt-1">Status: <span className="font-medium">{d.status}</span></div>
                    <div className="text-xs text-gray-500 mt-1">Pickup: {d.pickup_snapshot?.business_name || d.pickup_snapshot?.address_text || '—'}</div>
                    <div className="text-xs text-gray-500 mt-1">Dropoff: {addrText(d.dropoff_snapshot) || '—'}</div>
                  </div>
                  <div className="flex flex-col gap-2">
                    {d.status === 'assigned' ? (
                      <button
                        className="btn"
                        disabled={setStatusM.isPending}
                        onClick={() => setStatusM.mutate({ deliveryId: d.id, status: 'picked_up' })}
                      >
                        Mark picked up
                      </button>
                    ) : null}
                    {d.status === 'picked_up' ? (
                      <button
                        className="btn btn-primary"
                        disabled={setStatusM.isPending}
                        onClick={() => setStatusM.mutate({ deliveryId: d.id, status: 'delivered' })}
                      >
                        Mark delivered
                      </button>
                    ) : null}
                    <Link className="btn" to={`/orders/${d.order_id}`}>View order</Link>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="text-xs text-gray-500">
        Security: delivery claim is concurrency-safe; status transitions are enforced server-side.
      </div>
    </div>
  );
}
