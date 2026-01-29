import React from 'react';
import { loadGoogleMaps } from '../../lib/googleMaps';

export type LatLng = { lat: number; lng: number };

export type MapMarker = {
  id: string;
  position: LatLng;
  label?: string;
  title?: string;
  /** Optional semantic kind; used for applying default icons (e.g. driver). */
  kind?: 'driver' | 'pickup' | 'dropoff';
};

export type MapCircle = {
  id: string;
  center: LatLng;
  radius_m: number;
};

type MapViewProps = {
  center: LatLng;
  zoom?: number;
  markers?: MapMarker[];
  circles?: MapCircle[];
  className?: string;
  onMapClick?: (pos: LatLng) => void;
};



// --- Default marker icons ---
const DRIVER_BLUE_CAR_SVG = `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11" fill="white" stroke="#1d4ed8" stroke-width="2"/>
  <path fill="#1d4ed8" d="M18.92 5.01C18.72 4.42 18.16 4 17.5 4h-11c-.66 0-1.21.42-1.41 1.01L3 11v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.85 6h10.29l1.04 3H5.81l1.04-3zM19 16H5v-5h14v5zM7.5 14c-.83 0-1.5-.67-1.5-1.5S6.67 11 7.5 11 9 11.67 9 12.5 8.33 14 7.5 14zm9 0c-.83 0-1.5-.67-1.5-1.5S15.67 11 16.5 11 18 11.67 18 12.5 17.33 14 16.5 14z"/>
</svg>`;

function isDriverMarker(m: MapMarker) {
  return m.kind === 'driver' || m.id === 'driver' || m.id.startsWith('driver:');
}

function driverIcon(g: any) {
  // Use an SVG data URL so we don't depend on external assets.
  const url = `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(DRIVER_BLUE_CAR_SVG)}`;
  const sizePx = 36;
  return {
    url,
    scaledSize: new g.maps.Size(sizePx, sizePx),
    anchor: new g.maps.Point(sizePx / 2, sizePx / 2),
  };
}

export function MapView({ center, zoom = 13, markers = [], circles = [], className, onMapClick }: MapViewProps) {
  const containerRef = React.useRef<HTMLDivElement | null>(null);
  const mapRef = React.useRef<any>(null);
  const markersRef = React.useRef<Map<string, any>>(new Map());
  const circlesRef = React.useRef<Map<string, any>>(new Map());
  const clickListenerRef = React.useRef<any>(null);

  // Initialize map once
  React.useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        await loadGoogleMaps();
        if (cancelled) return;

        const g = (window as any).google;
        if (!g?.maps || !containerRef.current) return;

        const map = new g.maps.Map(containerRef.current, {
          center,
          zoom,
          mapTypeControl: false,
          streetViewControl: false,
          fullscreenControl: false,
          clickableIcons: false,
        });

        mapRef.current = map;
      } catch {
        // If Maps fails to load, we intentionally render an empty container.
      }
    })();

    const markers = markersRef.current;
    const circles = circlesRef.current;
    const map = mapRef.current;
    const clickListener = clickListenerRef.current;

    return () => {
      cancelled = true;

      // Best-effort cleanup
      try {
        const g = (window as any).google;
        if (g?.maps?.event && map) {
          g.maps.event.clearInstanceListeners(map);
        }
      } catch {
        // ignore
      }

      mapRef.current = null;
      markers.forEach((m) => m?.setMap?.(null));
      circles.forEach((c) => c?.setMap?.(null));
      markers.clear();
      circles.clear();
      if (clickListener?.remove) clickListener.remove();
      clickListenerRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update view
  React.useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    map.setCenter(center);
    map.setZoom(zoom);
  }, [center, zoom]);

  // Sync markers
  React.useEffect(() => {
    const map = mapRef.current;
    const g = (window as any).google;
    if (!map || !g?.maps) return;

    const current = markersRef.current;
    const nextIds = new Set(markers.map((m) => m.id));

    // Remove stale
    for (const [id, marker] of current.entries()) {
      if (!nextIds.has(id)) {
        marker.setMap(null);
        current.delete(id);
      }
    }

    // Upsert
    for (const m of markers) {
      const existing = current.get(m.id);
      const driver = isDriverMarker(m);
      const nextLabel = driver ? null : typeof m.label === 'string' ? m.label : null;
      const nextIcon = driver ? driverIcon(g) : null;

      if (existing) {
        existing.setPosition(m.position);
        if (typeof m.title === 'string') existing.setTitle(m.title);
        existing.setLabel(nextLabel);
        existing.setIcon(nextIcon);
      } else {
        const marker = new g.maps.Marker({
          map,
          position: m.position,
          title: m.title,
          label: nextLabel ?? undefined,
          icon: nextIcon ?? undefined,
        });
        current.set(m.id, marker);
      }
    }
  }, [markers]);

  // Sync circles
  React.useEffect(() => {
    const map = mapRef.current;
    const g = (window as any).google;
    if (!map || !g?.maps) return;

    const current = circlesRef.current;
    const nextIds = new Set(circles.map((c) => c.id));

    for (const [id, circle] of current.entries()) {
      if (!nextIds.has(id)) {
        circle.setMap(null);
        current.delete(id);
      }
    }

    for (const c of circles) {
      const existing = current.get(c.id);
      if (existing) {
        existing.setCenter(c.center);
        existing.setRadius(c.radius_m);
      } else {
        const circle = new g.maps.Circle({
          map,
          center: c.center,
          radius: c.radius_m,
          clickable: false,
          strokeOpacity: 0.65,
          strokeWeight: 2,
          fillOpacity: 0.08,
        });
        current.set(c.id, circle);
      }
    }
  }, [circles]);

  // Map click
  React.useEffect(() => {
    const map = mapRef.current;
    const g = (window as any).google;
    if (!map || !g?.maps?.event) return;

    // Remove prior listener
    try {
      if (clickListenerRef.current?.remove) clickListenerRef.current.remove();
    } catch {
      // ignore
    }

    clickListenerRef.current = null;

    if (!onMapClick) return;

    clickListenerRef.current = map.addListener('click', (evt: any) => {
      const lat = evt?.latLng?.lat?.();
      const lng = evt?.latLng?.lng?.();
      if (typeof lat === 'number' && typeof lng === 'number') {
        onMapClick({ lat, lng });
      }
    });

    return () => {
      try {
        if (clickListenerRef.current?.remove) clickListenerRef.current.remove();
      } catch {
        // ignore
      }
      clickListenerRef.current = null;
    };
  }, [onMapClick]);

  return <div ref={containerRef} className={className ?? 'w-full h-full'} />;
}
