# Maps usage inventory

This repo currently uses **Google Maps JavaScript API** (browser) for map rendering in the web app.

## Where Maps is used

### Public pages
- `apps/web/src/pages/ShareTripPage.tsx` → `MapView` (pickup/dropoff markers; optional driver marker)

### Admin pages
- `apps/web/src/components/maps/AdminDriversPreviewMap.tsx` (driver markers + radius circle + optional bbox rectangle)
- `apps/web/src/components/maps/AdminServiceAreaMap.tsx` (editable service area rectangle)
- `apps/web/src/components/maps/AdminServiceAreaGeoJsonMap.tsx` (GeoJSON overlay via Data layer)

## Required Maps APIs / SDKs (allowlist)

### Client key (browser)
- **Maps JavaScript API** (required)

No usage of:
- Places (JS or Web Service)
- Routes/Directions API
- Geocoding API
- Elevation API
- Distance Matrix API
- Drawing library
- Geometry library

> Note: Maps overlays used (`Marker`, `Circle`, `Rectangle`, `Data` layer) are provided by the base Maps JS API and do not require extra JS libraries.

### Server key (if/when server-side features are added)
Not currently used in this repo. If you add backend features that call Google Maps Web Services (Directions/Geocoding/Places), use a **separate server key** and restrict it as described in `docs/maps/key-restrictions.md`.
