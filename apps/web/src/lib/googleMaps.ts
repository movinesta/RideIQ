import { supabase } from './supabaseClient';

type MapsConfig = {
  // Older contract
  google_maps_api_key?: string;
  // Newer contract
  apiKey?: string;
  // Optional map styling / Map ID
  mapId?: string;
};

let _apiKeyPromise: Promise<string> | null = null;
let _loaderPromise: Promise<void> | null = null;

async function getApiKey(): Promise<string> {
  if (_apiKeyPromise) return _apiKeyPromise;
  _apiKeyPromise = (async () => {
    const { data, error } = await supabase.functions.invoke<MapsConfig>('maps-config');
    if (error) throw new Error(`maps-config failed: ${error.message}`);
    const key = data?.apiKey ?? data?.google_maps_api_key;
    if (!key) throw new Error('maps-config missing apiKey');
    return key;
  })();
  return _apiKeyPromise;
}

function buildUrl(apiKey: string, libraries: string[]) {
  const libs = Array.from(new Set(libraries.filter(Boolean))).join(',');
  const params = new URLSearchParams({
    key: apiKey,
    v: 'weekly',
  });
  if (libs) params.set('libraries', libs);
  return `https://maps.googleapis.com/maps/api/js?${params.toString()}`;
}

export async function loadGoogleMaps(libraries: string[] = ['places', 'drawing']): Promise<void> {
  if (typeof window === 'undefined') return;
  if ((window as any).google?.maps) return;

  if (_loaderPromise) return _loaderPromise;

  _loaderPromise = (async () => {
    const apiKey = await getApiKey();
    const url = buildUrl(apiKey, libraries);

    await new Promise<void>((resolve, reject) => {
      const existing = document.querySelector<HTMLScriptElement>(`script[data-google-maps='true']`);
      if (existing) {
        existing.addEventListener('load', () => resolve());
        existing.addEventListener('error', () => reject(new Error('Failed to load Google Maps script')));
        return;
      }

      const s = document.createElement('script');
      s.src = url;
      s.async = true;
      s.defer = true;
      s.dataset.googleMaps = 'true';
      s.addEventListener('load', () => resolve());
      s.addEventListener('error', () => reject(new Error('Failed to load Google Maps script')));
      document.head.appendChild(s);
    });

    if (!(window as any).google?.maps) {
      throw new Error('Google Maps loaded but window.google.maps is missing');
    }
  })();

  return _loaderPromise;
}

export function hasGoogleMapsLoaded(): boolean {
  return Boolean((window as any).google?.maps);
}
