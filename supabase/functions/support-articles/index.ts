import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient } from "../_shared/supabase.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return json({ ok: true }, 204);
  if (req.method !== "GET") return errorJson("Method not allowed", 405);

  const anon = createAnonClient(req);

  const { data: sections, error: sErr } = await anon
    .from("support_sections")
    .select("id,key,title,sort_order")
    .eq("enabled", true)
    .order("sort_order", { ascending: true });

  if (sErr) return errorJson(sErr.message, 400, "DB_ERROR");

  const { data: articles, error: aErr } = await anon
    .from("support_articles")
    .select("id,section_id,slug,title,summary,tags,updated_at")
    .eq("enabled", true)
    .order("updated_at", { ascending: false })
    .limit(200);

  if (aErr) return errorJson(aErr.message, 400, "DB_ERROR");

  return json({ ok: true, sections: sections ?? [], articles: articles ?? [] });
});
