import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.92.0?target=deno";

function corsHeaders(origin: string | null) {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
    "Access-Control-Allow-Headers": "authorization,content-type",
    "Access-Control-Max-Age": "86400",
  };
}

serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response("", { status: 204, headers: corsHeaders(origin) });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: corsHeaders(origin) });

  const authHeader = req.headers.get("authorization") || "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const anon = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userRes, error: userErr } = await anon.auth.getUser();
  const user = userRes?.user;
  if (userErr || !user) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const body = await req.json().catch(() => ({}));
  const role = (body.role ?? "driver").toLowerCase();

  // Get or create latest draft submission
  const { data: existing } = await anon
    .from("kyc_submissions")
    .select("id,status,created_at")
    .eq("profile_id", user.id)
    .eq("role_context", role)
    .order("created_at", { ascending: false })
    .limit(1);

  let submissionId = existing?.[0]?.id ?? null;
  let status = existing?.[0]?.status ?? null;

  if (!submissionId || (status && status !== "draft" && status !== "resubmit_required")) {
    const { data: created, error: createErr } = await anon
      .from("kyc_submissions")
      .insert({ profile_id: user.id, role_context: role, status: "draft" })
      .select("id")
      .single();
    if (createErr) {
      return new Response(JSON.stringify({ error: "create_failed", detail: createErr.message }), { status: 400, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
    }
    submissionId = created.id;
  }

  // Validate required docs exist (at least uploaded/pending)
  const { data: requiredTypes, error: typesErr } = await anon
    .from("kyc_document_types")
    .select("id,role_required,is_required,enabled")
    .eq("enabled", true);

  if (typesErr) {
    return new Response(JSON.stringify({ error: "types_fetch_failed" }), { status: 400, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const reqTypeIds = (requiredTypes ?? [])
    .filter((t) => t.is_required && (t.role_required === "both" || t.role_required === role))
    .map((t) => t.id);

  const { data: docs } = await anon
    .from("kyc_documents")
    .select("document_type_id,status")
    .eq("submission_id", submissionId);

  const have = new Set((docs ?? []).map((d) => d.document_type_id));
  const missing = reqTypeIds.filter((id) => !have.has(id));

  if (missing.length > 0) {
    return new Response(JSON.stringify({ error: "missing_documents", missing_document_type_ids: missing }), {
      status: 422,
      headers: { ...corsHeaders(origin), "content-type": "application/json" },
    });
  }

  const { error: updErr } = await anon
    .from("kyc_submissions")
    .update({ status: "submitted", submitted_at: new Date().toISOString(), updated_at: new Date().toISOString() })
    .eq("id", submissionId);

  if (updErr) {
    return new Response(JSON.stringify({ error: "submit_failed", detail: updErr.message }), { status: 400, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  return new Response(JSON.stringify({ ok: true, submission_id: submissionId }), { status: 200, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
});
