import React from 'react';
import { loadGoogleMaps } from '../../lib/googleMaps';

export type LatLng = { lat: number; lng: number };

export type MapMarker = {
  id: string;
  position: LatLng;
  label?: string;
  title?: string;
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

function isDriverMarker(id: string) {
  return id === 'driver' || id.startsWith('driver:');
}

function blueCarSvgDataUrl() {
  // Simple blue car icon (inline SVG). Works reliably as a Google Maps Marker icon via data URL.
  const svg = `
  <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
    <defs>
      <filter id="s" x="-20%" y="-20%" width="140%" height="140%">
        <feDropShadow dx="0" dy="2" stdDeviation="2" flood-opacity="0.35"/>
      </filter>
    </defs>
    <g filter="url(#s)">
      <path d="M14 34c0-8 6-14 14-14h8c8 0 14 6 14 14v10c0 2-2 4-4 4h-2a8 8 0 0 0-16 0H24a8 8 0 0 0-16 0h-2c-2 0-4-2-4-4V34c0-2 2-4 4-4h4.5l3.1-6.2A10 10 0 0 1 22.5 18h19a10 10 0 0 1 9 5.8l3.1 6.2H58c2 0 4 2 4 4v10c0 2-2 4-4 4h-2" fill="#1e88e5" stroke="#0d47a1" stroke-width="2" stroke-linejoin="round"/>
      <path d="M18 30h28" stroke="#bbdefb" stroke-width="2" stroke-linecap="round" opacity="0.8"/>
      <circle cx="20" cy="48" r="6" fill="#263238"/>
      <circle cx="20" cy="48" r="3" fill="#90a4ae"/>
      <circle cx="44" cy="48" r="6" fill="#263238"/>
      <circle cx="44" cy="48" r="3" fill="#90a4ae"/>
    </g>
  </svg>
  `.trim();
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`;
}

function driverIcon(g: any) {
  // Size tuned to look like a "pin" without taking over the map.
  const size = new g.maps.Size(34, 34);
  const anchor = new g.maps.Point(17, 17);
  return { url: blueCarSvgDataUrl(), scaledSize: size, anchor };
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

    const m = markersRef.current;
    const c = circlesRef.current;
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
      m.forEach((mm) => mm?.setMap?.(null));
      c.forEach((cc) => cc?.setMap?.(null));
      m.clear();
      c.clear();
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
      const driver = isDriverMarker(m.id);

      if (existing) {
        existing.setPosition(m.position);
        if (typeof m.title === 'string') existing.setTitle(m.title);

        if (driver) {
          existing.setIcon(driverIcon(g));
          existing.setLabel(null);
        } else {
          // Restore default icon if this marker is not a driver marker.
          try {
            existing.setIcon(null);
          } catch {
            // ignore
          }
          if (typeof m.label === 'string') existing.setLabel(m.label);
          else existing.setLabel(null);
        }
      } else {
        const marker = new g.maps.Marker({
          map,
          position: m.position,
          title: m.title,
          label: driver ? undefined : m.label,
          icon: driver ? driverIcon(g) : undefined,
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
