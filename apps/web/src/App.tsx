import React from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import AuthGate from './components/AuthGate';
import Layout from './components/Layout';
import RiderPage from './pages/RiderPage';
import ScheduledRidesPage from './pages/ScheduledRidesPage';
import DriverPage from './pages/DriverPage';
import HistoryPage from './pages/HistoryPage';
import AdminIncidentsPage from './pages/AdminIncidentsPage';
import AdminPaymentsPage from './pages/AdminPaymentsPage';
import AdminScheduledRidesPage from './pages/AdminScheduledRidesPage';
import AdminIntegrityPage from './pages/AdminIntegrityPage';
import AdminServiceAreasPage from './pages/AdminServiceAreasPage';
import AdminWhatsAppPage from './pages/AdminWhatsAppPage';
import AdminPricingPage from './pages/AdminPricingPage';
import AdminRideIntentsPage from './pages/AdminRideIntentsPage';
import AdminRideCheckPage from './pages/AdminRideCheckPage';
import WalletPage from './pages/WalletPage';
import ShareTripPage from './pages/ShareTripPage';
import WhatsAppBookingPage from './pages/WhatsAppBookingPage';
import SafetyContactsPage from './pages/SafetyContactsPage';

function ProtectedApp() {
  return (
    <AuthGate>
      <Layout>
        <Routes>
          <Route path="/" element={<Navigate to="/rider" replace />} />
          <Route path="/rider" element={<RiderPage />} />
          <Route path="/scheduled" element={<ScheduledRidesPage />} />
          <Route path="/driver" element={<DriverPage />} />
          <Route path="/wallet" element={<WalletPage />} />
          <Route path="/safety/contacts" element={<SafetyContactsPage />} />
          <Route path="/history" element={<HistoryPage />} />
          <Route path="/admin/payments" element={<AdminPaymentsPage />} />
          <Route path="/admin/scheduled" element={<AdminScheduledRidesPage />} />
          <Route path="/admin/incidents" element={<AdminIncidentsPage />} />
          <Route path="/admin/integrity" element={<AdminIntegrityPage />} />
          <Route path="/admin/intents" element={<AdminRideIntentsPage />} />
          <Route path="/admin/ridecheck" element={<AdminRideCheckPage />} />
          <Route path="/admin/pricing" element={<AdminPricingPage />} />
          <Route path="/admin/service-areas" element={<AdminServiceAreasPage />} />
              <Route path="/admin/whatsapp" element={<AdminWhatsAppPage />} />
          <Route path="*" element={<div className="p-6">Not found</div>} />
        </Routes>
      </Layout>
    </AuthGate>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/share/:token" element={<ShareTripPage />} />
          <Route path="/booking/:token" element={<WhatsAppBookingPage />} />
      <Route path="/*" element={<ProtectedApp />} />
    </Routes>
  );
}
