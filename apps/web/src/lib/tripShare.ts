export function buildShareUrl(token: string): string {
  const t = String(token ?? '').trim();

  // GitHub Pages for a project repo is hosted under "/<repo>/"
  // Vite exposes that base via import.meta.env.BASE_URL (e.g. "/RideIQ/").
  const origin = typeof window !== 'undefined' ? window.location.origin : '';
  const base = (import.meta as any)?.env?.BASE_URL ?? '/';
  const basePath = String(base).replace(/\/+$/, ''); // drop trailing slash(es)

  // basePath is "" or "/RideIQ" or "/"
  const prefix = basePath === '/' ? '' : basePath;

  return `${origin}${prefix}/share/${t}`;
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
