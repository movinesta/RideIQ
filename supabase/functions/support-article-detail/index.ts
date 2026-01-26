import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient } from "../_shared/supabase.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return json({ ok: true }, 204);
  if (req.method !== "GET") return errorJson("Method not allowed", 405);

  const url = new URL(req.url);
  const slug = (url.searchParams.get("slug") ?? "").trim();
  if (!slug) return errorJson("Missing slug", 400, "INVALID_PAYLOAD");

  const anon = createAnonClient(req);
  const { data, error } = await anon
    .from("support_articles")
    .select("id,section_id,slug,title,summary,body_md,tags,updated_at")
    .eq("enabled", true)
    .eq("slug", slug)
    .maybeSingle();

  if (error) return errorJson(error.message, 400, "DB_ERROR");
  if (!data) return errorJson("Not found", 404, "NOT_FOUND");

  return json({ ok: true, article: data });
});
