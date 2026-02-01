import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { logAppEvent } from '../_shared/log.ts';

type CreateTicket = {
  action: 'create_ticket';
  category_code?: string | null;
  subject: string;
  message: string;
  ride_id?: string | null;
};

type AddMessage = {
  action: 'add_message';
  ticket_id: string;
  message: string;
};

type Body = CreateTicket | AddMessage;

function retryAfterSeconds(resetAtIso: string) {
  const ms = new Date(resetAtIso).getTime() - Date.now();
  return Math.max(1, Math.ceil(ms / 1000));
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'POST') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');

  const { user, error: authError } = await requireUser(req);
  if (!user) return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED');

  // Rate limit: support center is a frequent spam target
  const ip = getClientIp(req);
  const rl = await consumeRateLimit({ key: `support:${user.id}:${ip ?? 'noip'}`, windowSeconds: 60, limit: 40 });
  if (!rl.allowed) {
    return json(
      { error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining },
      429,
      { 'Retry-After': String(retryAfterSeconds(rl.resetAt)) },
    );
  }

  const body = (await req.json().catch(() => null)) as Body | null;
  if (!body?.action) return errorJson('Invalid body', 400, 'INVALID_BODY');

  const supabase = createAnonClient(req);

  if (body.action === 'create_ticket') {
    if (!body.subject?.trim() || !body.message?.trim()) {
      return errorJson('Missing subject or message', 400, 'INVALID_BODY');
    }

    const { data: ticket, error: ticketErr } = await supabase
      .from('support_tickets')
      .insert({
        created_by: user.id,
        category_code: body.category_code ?? null,
        subject: body.subject.trim(),
        ride_id: body.ride_id ?? null,
      })
      .select('*')
      .single();

    if (ticketErr || !ticket) return errorJson(ticketErr?.message ?? 'Create ticket failed', 500, 'CREATE_TICKET_FAILED');

    const { error: msgErr } = await supabase.from('support_messages').insert({
      ticket_id: ticket.id,
      sender_id: user.id,
      message: body.message.trim(),
    });
    if (msgErr) return errorJson(msgErr.message, 500, 'CREATE_MESSAGE_FAILED');

    await logAppEvent({
      event_type: 'support_ticket_created',
      level: 'info',
      actor_id: user.id,
      actor_type: 'system',
      payload: { ticket_id: ticket.id, category_code: ticket.category_code ?? null },
    });

    return json({ ok: true, ticket_id: ticket.id }, 200);
  }

  // add_message
  if (!body.ticket_id || !body.message?.trim()) return errorJson('Missing ticket_id or message', 400, 'INVALID_BODY');

  // Ensure the ticket exists and the caller is the owner (RLS also enforces, but we want clearer errors)
  const { data: ticket, error: tErr } = await supabase
    .from('support_tickets')
    .select('id, created_by')
    .eq('id', body.ticket_id)
    .maybeSingle();

  if (tErr) return errorJson(tErr.message, 500, 'TICKET_LOOKUP_FAILED');
  if (!ticket) return errorJson('Ticket not found', 404, 'NOT_FOUND');

  const { error: msgErr } = await supabase.from('support_messages').insert({
    ticket_id: body.ticket_id,
    sender_id: user.id,
    message: body.message.trim(),
  });
  if (msgErr) return errorJson(msgErr.message, 500, 'ADD_MESSAGE_FAILED');

  await logAppEvent({
    event_type: 'support_message_sent',
    level: 'info',
    actor_id: user.id,
    actor_type: 'system',
    payload: { ticket_id: body.ticket_id },
  });

  return json({ ok: true }, 200);
});
