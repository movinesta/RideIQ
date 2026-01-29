import { getCorsHeaders } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { rateLimitByKey } from '../_shared/rateLimit.ts';
import { z } from 'npm:zod@3.23.8';
import { buildAgoraRtcToken, createDailyMeetingToken } from '../_shared/voiceProviders.ts';
import { envTrim } from '../_shared/config.ts';

const bodySchema = z.object({ call_id: z.string().uuid() });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: getCorsHeaders() });
  if (req.method !== 'POST') return errorJson('Method not allowed', 405);

  try {
    const { user } = await requireUser(req);
    await rateLimitByKey({ key: `voice-call-join:${user.id}`, limit: 30, windowMs: 60_000 });

    const body = bodySchema.parse(await req.json());
    const supabaseAdmin = createServiceClient();

    const { data: call, error: cErr } = await supabaseAdmin
      .from('voice_calls')
      .select('id,provider,status,agora_channel,daily_room_name,daily_room_url,created_by')
      .eq('id', body.call_id)
      .maybeSingle();
    if (cErr) throw cErr;
    if (!call) return errorJson('Call not found', 404, 'NOT_FOUND');

    // Participant check
    const { data: mePart, error: pErr } = await supabaseAdmin
      .from('voice_call_participants')
      .select('call_id,profile_id')
      .eq('call_id', call.id)
      .eq('profile_id', user.id)
      .maybeSingle();
    if (pErr) throw pErr;

    if (!mePart) {
      // allow admin
      const { data: prof, error: profErr } = await supabaseAdmin.from('profiles').select('is_admin').eq('id', user.id).maybeSingle();
      if (profErr) throw profErr;
      if (!prof?.is_admin) return errorJson('Not a participant', 403, 'FORBIDDEN');
    }

    let join: any;
    if (call.provider === 'agora') {
      if (!call.agora_channel) return errorJson('Call missing agora_channel', 500, 'CONFIG');
      join = await buildAgoraRtcToken({ channel: call.agora_channel, userAccount: user.id });
    } else {
      if (!call.daily_room_name || !call.daily_room_url) return errorJson('Call missing Daily room info', 500, 'CONFIG');

      if (envTrim('DAILY_API_KEY')) {
        const t = await createDailyMeetingToken({
          roomName: call.daily_room_name,
          userId: user.id,
          isOwner: user.id === call.created_by,
        });
        join = { ...t, roomUrl: call.daily_room_url };
      } else {
        return errorJson('Missing DAILY_API_KEY (required for Daily meeting tokens)', 500, 'CONFIG');
      }
    }

    return json({ call_id: call.id, join });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
});
