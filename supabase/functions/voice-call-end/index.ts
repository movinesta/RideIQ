import { getCorsHeaders } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { rateLimitByKey } from '../_shared/rateLimit.ts';
import { z } from 'npm:zod@3.23.8';

const bodySchema = z.object({
  call_id: z.string().uuid(),
  reason: z.string().max(200).optional(),
});

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: getCorsHeaders() });
  if (req.method !== 'POST') return errorJson('Method not allowed', 405);

  try {
    const { user } = await requireUser(req);
    await rateLimitByKey({ key: `voice-call-end:${user.id}`, limit: 60, windowMs: 60_000 });

    const body = bodySchema.parse(await req.json());
    const supabaseAdmin = createServiceClient();

    const { data: call, error: cErr } = await supabaseAdmin
      .from('voice_calls')
      .select('id,status')
      .eq('id', body.call_id)
      .maybeSingle();
    if (cErr) throw cErr;
    if (!call) return errorJson('Call not found', 404, 'NOT_FOUND');

    const { data: part, error: pErr } = await supabaseAdmin
      .from('voice_call_participants')
      .select('call_id,profile_id')
      .eq('call_id', body.call_id)
      .eq('profile_id', user.id)
      .maybeSingle();
    if (pErr) throw pErr;

    if (!part) {
      const { data: prof, error: profErr } = await supabaseAdmin.from('profiles').select('is_admin').eq('id', user.id).maybeSingle();
      if (profErr) throw profErr;
      if (!prof?.is_admin) return errorJson('Not a participant', 403, 'FORBIDDEN');
    }

    const now = new Date().toISOString();
    const nextStatus = call.status === 'ringing' ? 'canceled' : 'ended';

    const { error: upErr } = await supabaseAdmin
      .from('voice_calls')
      .update({
        status: nextStatus,
        ended_at: now,
        metadata: body.reason ? { end_reason: body.reason } : undefined,
      })
      .eq('id', body.call_id);
    if (upErr) throw upErr;

    await supabaseAdmin
      .from('voice_call_participants')
      .update({ left_at: now })
      .eq('call_id', body.call_id)
      .eq('profile_id', user.id);

    return json({ ok: true, call_id: body.call_id, status: nextStatus });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
});
