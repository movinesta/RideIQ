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
      if (existing) {
        existing.setPosition(m.position);
        if (typeof m.title === 'string') existing.setTitle(m.title);
        if (typeof m.label === 'string') existing.setLabel(m.label);
      } else {
        const marker = new g.maps.Marker({
          map,
          position: m.position,
          title: m.title,
          label: m.label,
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
