import React from 'react';
import { Link, useLocation } from 'react-router-dom';

export default function AdminNav() {
  const loc = useLocation();

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <div className="text-sm font-semibold">Admin</div>
          <div className="text-xs text-gray-500">Payments, incidents, and provider activity</div>
        </div>
        <div className="flex gap-2 flex-wrap">
          <Pill to="/admin/payments" active={loc.pathname.startsWith('/admin/payments')}>Payments</Pill>
          <Pill to="/admin/incidents" active={loc.pathname.startsWith('/admin/incidents')}>Incidents</Pill>
          <Pill to="/admin/ridecheck" active={loc.pathname.startsWith('/admin/ridecheck')}>RideCheck</Pill>
          <Pill to="/admin/integrity" active={loc.pathname.startsWith('/admin/integrity')}>Integrity</Pill>
          <Pill to="/admin/scheduled" active={loc.pathname.startsWith('/admin/scheduled')}>Scheduled</Pill>
          <Pill to="/admin/intents" active={loc.pathname.startsWith('/admin/intents')}>Intents</Pill>
          <Pill to="/admin/pricing" active={loc.pathname.startsWith('/admin/pricing')}>Pricing</Pill>
          <Pill to="/admin/whatsapp" active={loc.pathname.startsWith('/admin/whatsapp')}>WhatsApp</Pill>
          <Pill to="/admin/service-areas" active={loc.pathname.startsWith('/admin/service-areas')}>Service Areas</Pill>
        </div>
      </div>
    </div>
  );
}

function Pill({ to, active, children }: { to: string; active: boolean; children: React.ReactNode }) {
  return (
    <Link
      to={to}
      className={
        active
          ? 'px-3 py-2 rounded-xl bg-gray-900 text-white text-sm'
          : 'px-3 py-2 rounded-xl border border-gray-200 text-sm hover:bg-gray-50'
      }
    >
      {children}
    </Link>
  );
}
