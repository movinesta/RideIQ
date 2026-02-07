-- Enable OpenRouteService for server-side routing/geocoding when Thunderforest is the renderer.
-- This ensures directions/geocoding have a valid provider even when Google/Mapbox are excluded.

UPDATE public.maps_providers
SET enabled = true,
    updated_at = now()
WHERE provider_code = 'ors'
  AND enabled IS DISTINCT FROM true;

UPDATE public.maps_provider_capabilities
SET enabled = true,
    updated_at = now()
WHERE provider_code = 'ors'
  AND capability IN ('directions','geocode','distance_matrix')
  AND enabled IS DISTINCT FROM true;
