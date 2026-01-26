import i18n from '../i18n';

export function formatIQD(amount: number | bigint): string {
  const n = typeof amount === 'bigint' ? Number(amount) : amount;
  if (!Number.isFinite(n)) return '—';

  // Iraq's de-facto UX is whole dinars (no decimals).
  try {
    const lang = (i18n.language ?? '').toLowerCase();
    const locale = lang.startsWith('ar') ? 'ar-IQ' : 'en-IQ';
    return new Intl.NumberFormat(locale, {
      style: 'currency',
      currency: 'IQD',
      maximumFractionDigits: 0,
    }).format(n);
  } catch {
    return `${Math.trunc(n).toLocaleString()} IQD`;
  }
}

export function formatSignedIQD(amount: number | bigint): string {
  const n = typeof amount === 'bigint' ? Number(amount) : amount;
  if (!Number.isFinite(n)) return '—';
  const sign = n > 0 ? '+' : n < 0 ? '−' : '';
  const abs = Math.abs(Math.trunc(n));
  // Keep the sign outside the currency formatting to avoid locale edge-cases.
  return `${sign}${formatIQD(abs)}`;
}
