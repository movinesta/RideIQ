import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Navigate, Route, Routes, useLocation } from 'react-router-dom';
import AuthGate from './components/AuthGate';
import Layout from './components/Layout';
import { getMyAppContext } from './lib/profile';
import HomeHubPage from './pages/HomeHubPage';
import RiderPage from './pages/RiderPage';
import ScheduledRidesPage from './pages/ScheduledRidesPage';
import DriverPage from './pages/DriverPage';
import DriverDeliveriesPage from './pages/DriverDeliveriesPage';
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
import AdminUsersPage from './pages/AdminUsersPage';
import AdminWithdrawalsPage from './pages/AdminWithdrawalsPage';
import AdminPayoutQueuePage from './pages/AdminPayoutQueuePage';
import WalletPage from './pages/WalletPage';
import ShareTripPage from './pages/ShareTripPage';
import WhatsAppBookingPage from './pages/WhatsAppBookingPage';
import SafetyContactsPage from './pages/SafetyContactsPage';
import BusinessesPage from './pages/BusinessesPage';
import BusinessDetailPage from './pages/BusinessDetailPage';
import MerchantDashboardPage from './pages/MerchantDashboardPage';
import MerchantProductsPage from './pages/MerchantProductsPage';
import MerchantPromotionsPage from './pages/MerchantPromotionsPage';
import MerchantChatsPage from './pages/MerchantChatsPage';
import MerchantChatPage from './pages/MerchantChatPage';
import AdminMerchantsPage from './pages/AdminMerchantsPage';
import CustomerChatsPage from './pages/CustomerChatsPage';
import RoleChooserPage from './pages/RoleChooserPage';
import DriverOnboardingPage from './pages/DriverOnboardingPage';
import MerchantOnboardingPage from './pages/MerchantOnboardingPage';
import OrdersPage from './pages/OrdersPage';
import OrderDetailPage from './pages/OrderDetailPage';
import CheckoutPage from './pages/CheckoutPage';
import AddressesPage from './pages/AddressesPage';

function RoleGate({ children }: { children: React.ReactNode }) {
  const loc = useLocation();
  const q = useQuery({
    queryKey: ['my-app-context'],
    queryFn: getMyAppContext,
  });

  if (q.isLoading) return <div className="p-6">Loading…</div>;
  if (q.isError) return <div className="p-6">Failed to load profile.</div>;

  const completed = q.data.role_onboarding_completed;
  const isOnboardingRoute = loc.pathname.startsWith('/onboarding');

  if (!completed && !isOnboardingRoute) {
    return <Navigate to="/onboarding/role" replace />;
  }

  return <>{children}</>;
}

function ProtectedApp() {
  return (
    <AuthGate>
      <RoleGate>
        <Layout>
        <Routes>
          <Route path="/onboarding/role" element={<RoleChooserPage />} />
          <Route path="/onboarding/driver" element={<DriverOnboardingPage />} />
          <Route path="/onboarding/merchant" element={<MerchantOnboardingPage />} />

          <Route path="/" element={<Navigate to="/home" replace />} />
          <Route path="/home" element={<HomeHubPage />} />
          <Route path="/rider" element={<RiderPage />} />
          <Route path="/scheduled" element={<ScheduledRidesPage />} />
          <Route path="/driver" element={<DriverPage />} />
          <Route path="/driver/deliveries" element={<DriverDeliveriesPage />} />
          <Route path="/wallet" element={<WalletPage />} />
          <Route path="/safety/contacts" element={<SafetyContactsPage />} />
          <Route path="/history" element={<HistoryPage />} />
          <Route path="/businesses" element={<BusinessesPage />} />
          <Route path="/chats" element={<CustomerChatsPage />} />
          <Route path="/business/:id" element={<BusinessDetailPage />} />
          <Route path="/checkout/:merchantId" element={<CheckoutPage />} />
          <Route path="/orders" element={<OrdersPage />} />
          <Route path="/orders/:id" element={<OrderDetailPage />} />
          <Route path="/addresses" element={<AddressesPage />} />
          <Route path="/merchant" element={<MerchantDashboardPage />} />
          <Route path="/merchant/products" element={<MerchantProductsPage />} />
          <Route path="/merchant/promotions" element={<MerchantPromotionsPage />} />
          <Route path="/merchant/chats" element={<MerchantChatsPage />} />
          <Route path="/merchant-chat/:threadId" element={<MerchantChatPage />} />
          <Route path="/admin/payments" element={<AdminPaymentsPage />} />
          <Route path="/admin/withdrawals" element={<AdminWithdrawalsPage />} />
          <Route path="/admin/payout-queue" element={<AdminPayoutQueuePage />} />
          <Route path="/admin/scheduled" element={<AdminScheduledRidesPage />} />
          <Route path="/admin/incidents" element={<AdminIncidentsPage />} />
          <Route path="/admin/integrity" element={<AdminIntegrityPage />} />
          <Route path="/admin/intents" element={<AdminRideIntentsPage />} />
          <Route path="/admin/ridecheck" element={<AdminRideCheckPage />} />
          <Route path="/admin/pricing" element={<AdminPricingPage />} />
          <Route path="/admin/service-areas" element={<AdminServiceAreasPage />} />
          <Route path="/admin/whatsapp" element={<AdminWhatsAppPage />} />
          <Route path="/admin/merchants" element={<AdminMerchantsPage />} />
          <Route path="/admin/users" element={<AdminUsersPage />} />
          <Route path="*" element={<div className="p-6">Not found</div>} />
        </Routes>
        </Layout>
      </RoleGate>
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
