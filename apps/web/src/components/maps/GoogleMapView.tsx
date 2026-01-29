import * as React from 'react';

type Props = {
  className?: string;
  center: { lat: number; lng: number };
  zoom: number;
  onMapReady?: (map: google.maps.Map) => void;
};

type LoadState = 'loading' | 'ready' | 'unavailable' | 'error';

const GOOGLE_MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY as string | undefined;

let mapsLoadPromise: Promise<void> | null = null;

function ensureGoogleMaps(): Promise<void> {
  if (typeof window === 'undefined') return Promise.resolve();
  if (!GOOGLE_MAPS_API_KEY) return Promise.resolve();
  if (window.google?.maps) return Promise.resolve();
  if (!mapsLoadPromise) {
    mapsLoadPromise = new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.async = true;
      script.defer = true;
      script.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(GOOGLE_MAPS_API_KEY)}`;
      script.onload = () => {
        if (!window.google?.maps) {
          reject(new Error('Google Maps API loaded but no maps namespace found.'));
          return;
        }
        resolve();
      };
      script.onerror = () => reject(new Error('Failed to load Google Maps API'));
      document.head.appendChild(script);
    });
  }
  return mapsLoadPromise;
}

export function GoogleMapView({ className, center, zoom, onMapReady }: Props) {
  const containerRef = React.useRef<HTMLDivElement | null>(null);
  const mapRef = React.useRef<google.maps.Map | null>(null);
  const [loadState, setLoadState] = React.useState<LoadState>('loading');

  React.useEffect(() => {
    let alive = true;
    const container = containerRef.current;
    if (!container) return undefined;
    if (mapRef.current) return undefined;

    if (!GOOGLE_MAPS_API_KEY) {
      setLoadState('unavailable');
      return undefined;
    }

    ensureGoogleMaps()
      .then(() => {
        if (!alive) return;
        if (!window.google?.maps) {
          setLoadState('unavailable');
          return;
        }
        const mapInstance = new google.maps.Map(container, { center, zoom });
        mapRef.current = mapInstance;
        setLoadState('ready');
        onMapReady?.(mapInstance);
      })
      .catch(() => {
        if (!alive) return;
        setLoadState('error');
      });

    return () => {
      alive = false;
    };
  }, [center, zoom, onMapReady]);

  React.useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    map.setCenter(center);
    map.setZoom(zoom);
  }, [center, zoom]);

  const statusMessage =
    loadState === 'unavailable'
      ? 'Google Maps API key missing (set VITE_GOOGLE_MAPS_API_KEY).'
      : loadState === 'error'
      ? 'Unable to load Google Maps.'
      : 'Loading map...';

  return (
    <div className={`relative ${className ?? ''}`}>
      <div ref={containerRef} className="h-full w-full" />
      {loadState !== 'ready' ? (
        <div className="absolute inset-0 flex items-center justify-center text-xs text-gray-500 bg-white/80">
          {statusMessage}
        </div>
      ) : null}
    </div>
  );
}
