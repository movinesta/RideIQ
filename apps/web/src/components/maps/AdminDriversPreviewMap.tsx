import * as React from 'react';
import { GoogleMapView } from './GoogleMapView';

export type NearbyDriverPoint = {
  driver_id: string;
  lat: number;
  lng: number;
  dist_m?: number;
  updated_at?: string;
};

type Props = {
  center: { lat: number; lng: number };
  radius_m: number;
  bbox?: { minLat: number; minLng: number; maxLat: number; maxLng: number } | null;
  drivers: NearbyDriverPoint[];
  onCenterChange?: (c: { lat: number; lng: number }) => void;
};

export function AdminDriversPreviewMap({ center, radius_m, bbox, drivers, onCenterChange }: Props) {
  const mapRef = React.useRef<google.maps.Map | null>(null);
  const circleRef = React.useRef<google.maps.Circle | null>(null);
  const rectRef = React.useRef<google.maps.Rectangle | null>(null);
  const markersRef = React.useRef<google.maps.Marker[]>([]);

  const clearMarkers = React.useCallback(() => {
    for (const m of markersRef.current) m.setMap(null);
    markersRef.current = [];
  }, []);

  const ensureOverlays = React.useCallback(
    (map: google.maps.Map) => {
      if (!circleRef.current) {
        circleRef.current = new google.maps.Circle({
          map,
          center,
          radius: radius_m,
          clickable: false,
          fillOpacity: 0.06,
          strokeOpacity: 0.55,
          strokeWeight: 2,
        });
      }

      if (bbox && !rectRef.current) {
        rectRef.current = new google.maps.Rectangle({
          map,
          clickable: false,
          fillOpacity: 0.02,
          strokeOpacity: 0.5,
          strokeWeight: 2,
        });
      }
    },
    [bbox, center, radius_m],
  );

  const updateOverlays = React.useCallback(
    (map: google.maps.Map) => {
      ensureOverlays(map);
      if (circleRef.current) {
        circleRef.current.setCenter(center);
        circleRef.current.setRadius(radius_m);
      }
      if (rectRef.current) {
        if (bbox) {
          rectRef.current.setBounds({
            south: bbox.minLat,
            west: bbox.minLng,
            north: bbox.maxLat,
            east: bbox.maxLng,
          });
          rectRef.current.setMap(map);
        } else {
          rectRef.current.setMap(null);
        }
      }
    },
    [bbox, center, radius_m, ensureOverlays],
  );

  const renderDrivers = React.useCallback(
    (map: google.maps.Map) => {
      clearMarkers();
      markersRef.current = drivers.map((d) => {
        const m = new google.maps.Marker({
          map,
          position: { lat: d.lat, lng: d.lng },
          title: d.driver_id,
        });
        return m;
      });
    },
    [drivers, clearMarkers],
  );

  React.useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    updateOverlays(map);
    renderDrivers(map);
  }, [center, radius_m, bbox, drivers, updateOverlays, renderDrivers]);

  React.useEffect(() => {
    return () => {
      clearMarkers();
      circleRef.current?.setMap(null);
      rectRef.current?.setMap(null);
    };
  }, [clearMarkers]);

  return (
    <GoogleMapView
      className="w-full h-full"
      center={center}
      zoom={13}
      onMapReady={(map) => {
        mapRef.current = map;
        updateOverlays(map);
        renderDrivers(map);

        if (onCenterChange) {
          map.addListener('click', (ev: google.maps.MapMouseEvent) => {
            if (!ev.latLng) return;
            onCenterChange({ lat: ev.latLng.lat(), lng: ev.latLng.lng() });
          });
        }
      }}
    />
  );
}
