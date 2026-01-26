export function buildShareUrl(token: string): string {
  const t = String(token ?? '').trim();
  const origin = typeof window !== 'undefined' ? window.location.origin : '';
  return `${origin}/share/${t}`;
}

export function buildTripShareMessage(url: string): string {
  return `RideIQ: Track my trip in real time: ${url}`;
}

export async function copyToClipboard(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch {
    return false;
  }
}
