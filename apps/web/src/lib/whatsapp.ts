function normalizeWhatsAppNumber(input: string): string {
  const raw = input.trim();
  // WhatsApp click-to-chat requires an international phone number without '+' or leading zeros.
  // We keep it conservative: digits only.
  return raw.replace(/[^0-9]/g, '');
}

export function getWhatsAppBookingNumber(): string | null {
  const v = (import.meta.env.VITE_WHATSAPP_BOOKING_NUMBER as string | undefined) ?? '';
  const n = normalizeWhatsAppNumber(v);
  return n.length >= 8 ? n : null;
}

export function buildWhatsAppClickToChatUrl(numberDigitsOnly: string, message: string): string {
  const n = normalizeWhatsAppNumber(numberDigitsOnly);
  const text = encodeURIComponent(message ?? '');
  return `https://wa.me/${n}?text=${text}`;
}

// Generic share (no phone number). Useful when the user wants to pick the recipient inside WhatsApp.
// We intentionally use the official web endpoint to maximize compatibility.
export function buildWhatsAppShareUrl(message: string): string {
  const text = encodeURIComponent(message ?? '');
  return `https://api.whatsapp.com/send?text=${text}`;
}
