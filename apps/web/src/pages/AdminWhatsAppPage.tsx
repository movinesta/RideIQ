import React from 'react';
import { useQuery } from '@tanstack/react-query';
import AdminNav from '../components/AdminNav';
import { supabase } from '../lib/supabaseClient';
import { getIsAdmin } from '../lib/admin';
import { errorText } from '../lib/errors';
import { invokeEdge } from '../lib/edgeInvoke';

type Thread = {
  id: string;
  wa_id: string;
  phone_e164: string | null;
  stage: string;
  pickup_lat: number | null;
  pickup_lng: number | null;
  dropoff_lat: number | null;
  dropoff_lng: number | null;
  pickup_address: string | null;
  dropoff_address: string | null;
  last_inbound_at: string | null;
  last_outbound_at: string | null;
  last_message_at: string | null;
  created_at: string;

  // Operator workflow (Session 24)
  op_status?: string;
  assigned_admin_id?: string | null;
  assigned_at?: string | null;
  needs_followup?: boolean;
  followup_reason?: string | null;
  followup_at?: string | null;
  last_failed_outbound_at?: string | null;

  // From whatsapp_threads_admin views
  csw_open?: boolean;
  csw_expires_at?: string | null;
  csw_seconds_left?: number | null;
  sla_seconds_since_last_inbound?: number | null;
  sla_seconds_since_last_message?: number | null;
};

type Msg = {
  id: string;
  thread_id: string;
  wa_message_id: string | null;
  provider_message_id?: string | null;
  direction: 'in' | 'out';
  msg_type: string;
  body: string | null;
  template_name?: string | null;
  template_lang?: string | null;
  created_at: string;
  wa_status?: string | null;
  delivered_at?: string | null;
  read_at?: string | null;
  failed_at?: string | null;
};



type Note = {
  id: string;
  thread_id: string;
  author_id: string;
  body: string;
  created_at: string;
};

function mapsLink(lat: number, lng: number) {
  return `https://www.google.com/maps?q=${encodeURIComponent(`${lat},${lng}`)}`;
}

function formatSeconds(s: number) {
  const sec = Math.max(0, Math.floor(s));
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const r = sec % 60;
  if (h > 0) return `${h}h ${m}m`;
  if (m > 0) return `${m}m ${r}s`;
  return `${r}s`;
}

export default function AdminWhatsAppPage() {
  const [selected, setSelected] = React.useState<string | null>(null);

  const [compose, setCompose] = React.useState('');
  const [busySend, setBusySend] = React.useState(false);

  const [link, setLink] = React.useState<string | null>(null);
  const [busyToken, setBusyToken] = React.useState(false);
  const [busySendLink, setBusySendLink] = React.useState(false);

  const [toast, setToast] = React.useState<string | null>(null);

  const [noteBody, setNoteBody] = React.useState('');
  const [busyNote, setBusyNote] = React.useState(false);
  const [busyAssign, setBusyAssign] = React.useState(false);
  const [busyResolve, setBusyResolve] = React.useState(false);
  const [busyMenu, setBusyMenu] = React.useState(false);

  const [templateMode, setTemplateMode] = React.useState(false);
  const [templateName, setTemplateName] = React.useState('');
  const [templateLang, setTemplateLang] = React.useState('en_US');

  const [bookingTemplateName, setBookingTemplateName] = React.useState('');
  const [bookingTemplateLang, setBookingTemplateLang] = React.useState('en_US');

  const adminQ = useQuery({
    queryKey: ['admin_whatsapp_is_admin'],
    queryFn: getIsAdmin,
  });

  const threadsQ = useQuery({
    enabled: !!adminQ.data,
    queryKey: ['admin_whatsapp_threads'],
    queryFn: async () => {
      // Prefer newest view (Session 24) then fallback.
      const tryV2 = await supabase.from('whatsapp_threads_admin_v2').select('*').order('last_message_at', { ascending: false }).limit(160);
      if (!tryV2.error) return (tryV2.data ?? []) as Thread[];

      const tryV1 = await supabase.from('whatsapp_threads_admin_v1').select('*').order('last_message_at', { ascending: false }).limit(160);
      if (!tryV1.error) return (tryV1.data ?? []) as Thread[];

      const { data, error } = await supabase.from('whatsapp_threads').select('*').order('last_message_at', { ascending: false }).limit(120);
      if (error) throw error;
      return (data ?? []) as Thread[];
    },
  });

  const msgsQ = useQuery({
    enabled: !!adminQ.data && !!selected,
    queryKey: ['admin_whatsapp_msgs', selected],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('whatsapp_messages')
        .select('*')
        .eq('thread_id', selected!)
        .order('created_at', { ascending: true })
        .limit(600);
      if (error) throw error;
      return (data ?? []) as Msg[];
    },
  });

  const notesQ = useQuery({
    enabled: !!adminQ.data && !!selected,
    queryKey: ['admin_whatsapp_notes', selected],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('whatsapp_thread_notes')
        .select('id,thread_id,author_id,body,created_at')
        .eq('thread_id', selected!)
        .order('created_at', { ascending: true })
        .limit(200);
      if (error) throw error;
      return (data ?? []) as Note[];
    },
  });

  React.useEffect(() => {
    if (!selected && threadsQ.data?.length) setSelected(threadsQ.data[0].id);
  }, [selected, threadsQ.data]);

  const threads = threadsQ.data ?? [];
  const selectedThread = threads.find((t) => t.id === selected) ?? null;
  const msgs = msgsQ.data ?? [];
  const notes = notesQ.data ?? [];

  async function currentUserId(): Promise<string | null> {
    const { data } = await supabase.auth.getUser();
    return data.user?.id ?? null;
  }

  async function assignToMe() {
    if (!selectedThread) return;
    setBusyAssign(true);
    try {
      const me = await currentUserId();
      if (!me) throw new Error('Not signed in');
      const { error } = await supabase
        .from('whatsapp_threads')
        .update({ assigned_admin_id: me, assigned_at: new Date().toISOString(), op_status: 'waiting_operator' })
        .eq('id', selectedThread.id);
      if (error) throw error;
      await threadsQ.refetch();
      setToast('Assigned to you.');
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusyAssign(false);
    }
  }

  async function markResolved() {
    if (!selectedThread) return;
    setBusyResolve(true);
    try {
      const { error } = await supabase
        .from('whatsapp_threads')
        .update({ op_status: 'resolved', needs_followup: false, followup_reason: null, followup_at: null })
        .eq('id', selectedThread.id);
      if (error) throw error;
      await threadsQ.refetch();
      setToast('Marked resolved.');
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusyResolve(false);
    }
  }

  async function clearFollowup() {
    if (!selectedThread) return;
    try {
      const { error } = await supabase
        .from('whatsapp_threads')
        .update({ needs_followup: false, followup_reason: null, followup_at: null })
        .eq('id', selectedThread.id);
      if (error) throw error;
      await threadsQ.refetch();
      setToast('Cleared follow-up.');
    } catch (e) {
      setToast(errorText(e));
    }
  }

  async function addNote() {
    if (!selectedThread) return;
    const body = noteBody.trim();
    if (!body) return;
    setBusyNote(true);
    try {
      const me = await currentUserId();
      if (!me) throw new Error('Not signed in');
      const { error } = await supabase
        .from('whatsapp_thread_notes')
        .insert({ thread_id: selectedThread.id, author_id: me, body });
      if (error) throw error;
      setNoteBody('');
      await notesQ.refetch();
      setToast('Note added.');
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusyNote(false);
    }
  }

  async function sendMenu() {
    if (!selectedThread) return;
    setBusyMenu(true);
    try {
      const out = await invokeEdge('whatsapp-send', { thread_id: selectedThread.id, action: 'send_menu' });
      if (out?.code === 'TEMPLATE_REQUIRED') {
        setToast('CSW closed — menu requires CSW open. Use template to re-engage.');
      } else {
        setToast('Menu sent.');
      }
      await msgsQ.refetch();
      await threadsQ.refetch();
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusyMenu(false);
    }
  }


  const csw = React.useMemo(() => {
    if (!selectedThread?.last_inbound_at) return { open: false, secondsLeft: null as number | null, expiresAt: null as string | null };
    if (typeof selectedThread.csw_open === 'boolean') {
      return {
        open: selectedThread.csw_open,
        secondsLeft: typeof selectedThread.csw_seconds_left === 'number' ? selectedThread.csw_seconds_left : null,
        expiresAt: selectedThread.csw_expires_at ?? null,
      };
    }
    const t = new Date(selectedThread.last_inbound_at).getTime();
    if (!Number.isFinite(t)) return { open: false, secondsLeft: null, expiresAt: null };
    const expires = t + 24 * 60 * 60 * 1000;
    const open = Date.now() <= expires;
    const secondsLeft = Math.max(0, Math.floor((expires - Date.now()) / 1000));
    return { open, secondsLeft, expiresAt: new Date(expires).toISOString() };
  }, [selectedThread]);

  async function createLink() {
    if (!selected) return;
    setBusyToken(true);
    setLink(null);
    setToast(null);
    try {
      const { data, error } = await supabase.rpc('whatsapp_booking_token_create_v1', {
        p_thread_id: selected,
        p_expires_minutes: 30,
      });
      if (error) throw error;
      const token = typeof data === 'string' ? data : String(data);
      const origin = window.location.origin.replace(/\/$/, '');
      const l = `${origin}/booking/${encodeURIComponent(token)}`;
      setLink(l);
      setToast('Link generated');
      await navigator.clipboard?.writeText(l).catch(() => {});
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusyToken(false);
    }
  }

  async function sendBookingLink() {
    if (!selected) return;
    setBusySendLink(true);
    setToast(null);
    setLink(null);
    try {
      const payload: any = {
        thread_id: selected,
        action: 'send_booking_link',
        expires_minutes: 30,
      };
      const bn = bookingTemplateName.trim();
      if (bn) payload.template = { name: bn, language: bookingTemplateLang.trim() || 'en_US' };

      const { data: res } = await invokeEdge<any>('whatsapp-send', payload);
      const l = (res as any)?.link;
      if (typeof l === 'string' && l) {
        setLink(l);
        await navigator.clipboard?.writeText(l).catch(() => {});
      }
      await msgsQ.refetch();
      await threadsQ.refetch();
      setToast((res as any)?.csw_open ? 'Link sent (CSW)' : 'Link sent (template)');
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusySendLink(false);
    }
  }

  async function sendMessage() {
    if (!selected) return;
    const msg = compose.trim();
    if (!msg) return;

    setBusySend(true);
    setToast(null);
    try {
      if (templateMode) {
        const name = templateName.trim();
        if (!name) throw new Error('Template name is required');
        // Default: 1 body parameter with the compose text.
        await invokeEdge('whatsapp-send', {
          thread_id: selected,
          template: {
            name,
            language: templateLang.trim() || 'en_US',
            components: [{ type: 'body', parameters: [{ type: 'text', text: msg }] }],
          },
        });
      } else {
        await invokeEdge('whatsapp-send', { thread_id: selected, message: msg });
      }
      setCompose('');
      await msgsQ.refetch();
      await threadsQ.refetch();
      setToast('Sent');
    } catch (e) {
      setToast(errorText(e));
    } finally {
      setBusySend(false);
    }
  }

  if (adminQ.isLoading) {
    return (
      <div className="p-6">
        <AdminNav />
        <div className="mt-6 text-sm text-gray-500">Loading…</div>
      </div>
    );
  }

  if (!adminQ.data) {
    return (
      <div className="p-6">
        <AdminNav />
        <div className="mt-6 rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-800">Not authorized.</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <AdminNav />

      <div className="mt-6 grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Threads */}
        <div className="rounded-2xl border border-gray-200 bg-white shadow-sm">
          <div className="p-4 border-b border-gray-100">
            <div className="text-sm font-semibold">WhatsApp Threads</div>
            <div className="text-xs text-gray-500 mt-1">Operator inbox for WhatsApp Cloud API</div>
          </div>
          <div className="max-h-[70vh] overflow-auto">
            {threadsQ.isLoading ? (
              <div className="p-4 text-sm text-gray-500">Loading…</div>
            ) : threadsQ.isError ? (
              <div className="p-4 text-sm text-red-700">{errorText(threadsQ.error)}</div>
            ) : threads.length === 0 ? (
              <div className="p-4 text-sm text-gray-500">No threads yet.</div>
            ) : (
              <div className="divide-y divide-gray-100">
                {threads.map((t) => {
                  const selectedStyle = t.id === selected ? 'bg-gray-50' : 'bg-white';
                  const open =
                    typeof t.csw_open === 'boolean'
                      ? t.csw_open
                      : t.last_inbound_at
                        ? Date.now() <= new Date(t.last_inbound_at).getTime() + 24 * 60 * 60 * 1000
                        : false;
                  const secondsLeft =
                    typeof t.csw_seconds_left === 'number'
                      ? t.csw_seconds_left
                      : t.last_inbound_at
                        ? Math.max(0, Math.floor((new Date(t.last_inbound_at).getTime() + 24 * 60 * 60 * 1000 - Date.now()) / 1000))
                        : 0;

                  return (
                    <button
                      key={t.id}
                      onClick={() => setSelected(t.id)}
                      className={`w-full text-left p-3 hover:bg-gray-50 ${selectedStyle}`}
                    >
                      <div className="flex items-center justify-between gap-2">
                        <div className="text-sm font-medium truncate">{t.phone_e164 ?? t.wa_id}</div>
                        <div className="flex items-center gap-2">
                          <span className={`text-[11px] px-2 py-0.5 rounded-full border ${open ? 'border-green-200 bg-green-50 text-green-800' : 'border-amber-200 bg-amber-50 text-amber-800'}`}>
                            {open ? `CSW ${formatSeconds(secondsLeft)}` : 'Template'}
                          </span>
                          {t.needs_followup ? (
                            <span className="text-[11px] px-2 py-0.5 rounded-full border border-red-200 bg-red-50 text-red-800">
                              Follow-up
                            </span>
                          ) : null}
                          <span className="text-[11px] px-2 py-0.5 rounded-full border border-gray-200 bg-gray-50 text-gray-700">
                            {t.op_status ?? 'open'}
                          </span>
                          <span className="text-[11px] px-2 py-0.5 rounded-full border border-gray-200 bg-gray-50 text-gray-700">
                            {t.stage}
                          </span>
                        </div>
                      </div>
                      <div className="text-xs text-gray-500 mt-1">
                        Last: {t.last_message_at ? new Date(t.last_message_at).toLocaleString() : '—'}{typeof t.sla_seconds_since_last_inbound === 'number' ? ` • SLA(in): ${formatSeconds(t.sla_seconds_since_last_inbound)}` : ''}
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* Conversation */}
        <div className="lg:col-span-2 rounded-2xl border border-gray-200 bg-white shadow-sm">
          <div className="p-4 border-b border-gray-100">
            <div className="flex items-start justify-between gap-3">
              <div>
                <div className="text-sm font-semibold">Conversation</div>
                <div className="text-xs text-gray-500 mt-1">
                  {selectedThread ? `${selectedThread.phone_e164 ?? selectedThread.wa_id} • stage: ${selectedThread.stage}` : 'Select a thread'}
                </div>
              </div>

              {selectedThread && (
                <div className="flex flex-col items-end gap-2">
                  <div className="text-[11px] text-gray-600">
                    CSW: {csw.open ? 'OPEN' : 'CLOSED'}
                    {csw.secondsLeft != null && csw.open ? ` • ${formatSeconds(csw.secondsLeft)} left` : ''}
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={assignToMe}
                      disabled={busyAssign}
                      className="text-[11px] px-2 py-1 rounded-full border border-gray-200 bg-white hover:bg-gray-50 disabled:opacity-60"
                    >
                      {busyAssign ? 'Assigning…' : 'Assign to me'}
                    </button>
                    <button
                      onClick={sendMenu}
                      disabled={busyMenu}
                      className="text-[11px] px-2 py-1 rounded-full border border-gray-200 bg-white hover:bg-gray-50 disabled:opacity-60"
                    >
                      {busyMenu ? 'Sending…' : 'Send menu'}
                    </button>
                    <button
                      onClick={markResolved}
                      disabled={busyResolve}
                      className="text-[11px] px-2 py-1 rounded-full border border-green-200 bg-green-50 text-green-800 hover:bg-green-100 disabled:opacity-60"
                    >
                      {busyResolve ? 'Saving…' : 'Resolve'}
                    </button>
                    {selectedThread.needs_followup ? (
                      <button
                        onClick={clearFollowup}
                        className="text-[11px] px-2 py-1 rounded-full border border-red-200 bg-red-50 text-red-800 hover:bg-red-100"
                      >
                        Clear follow-up
                      </button>
                    ) : null}
                  </div>

                  <div className="flex gap-2">
                    <button
                      onClick={createLink}
                      disabled={!selected || busyToken}
                      className="px-3 py-2 text-xs rounded-xl border border-gray-200 hover:bg-gray-50 disabled:opacity-50"
                    >
                      {busyToken ? 'Generating…' : 'Generate link'}
                    </button>
                    <button
                      onClick={sendBookingLink}
                      disabled={!selected || busySendLink}
                      className="px-3 py-2 text-xs rounded-xl border border-blue-200 bg-blue-50 text-blue-900 hover:bg-blue-100 disabled:opacity-50"
                    >
                      {busySendLink ? 'Sending…' : 'Send booking link'}
                    </button>
                  </div>
                </div>
              )}
            </div>

            {selectedThread && (
              <div className="mt-3 grid grid-cols-1 md:grid-cols-2 gap-2">
                <div className="rounded-xl border border-gray-100 bg-gray-50 p-3 text-xs">
                  <div className="font-medium text-gray-800">Pickup</div>
                  <div className="mt-1 text-gray-600">
                    {selectedThread.pickup_lat != null && selectedThread.pickup_lng != null ? (
                      <a className="underline" target="_blank" rel="noreferrer" href={mapsLink(selectedThread.pickup_lat, selectedThread.pickup_lng)}>
                        {selectedThread.pickup_lat.toFixed(5)}, {selectedThread.pickup_lng.toFixed(5)}
                      </a>
                    ) : (
                      '—'
                    )}
                    {selectedThread.pickup_address ? <div className="mt-1">{selectedThread.pickup_address}</div> : null}
                  </div>
                </div>
                <div className="rounded-xl border border-gray-100 bg-gray-50 p-3 text-xs">
                  <div className="font-medium text-gray-800">Drop-off</div>
                  <div className="mt-1 text-gray-600">
                    {selectedThread.dropoff_lat != null && selectedThread.dropoff_lng != null ? (
                      <a className="underline" target="_blank" rel="noreferrer" href={mapsLink(selectedThread.dropoff_lat, selectedThread.dropoff_lng)}>
                        {selectedThread.dropoff_lat.toFixed(5)}, {selectedThread.dropoff_lng.toFixed(5)}
                      </a>
                    ) : (
                      '—'
                    )}
                    {selectedThread.dropoff_address ? <div className="mt-1">{selectedThread.dropoff_address}</div> : null}
                  </div>
                </div>
              </div>
            )}

            {link && (
              <div className="mt-3 rounded-xl border border-green-200 bg-green-50 p-3 text-xs text-green-900 break-all">
                <div className="font-medium">Booking link</div>
                <div className="mt-1">{link}</div>
                <div className="mt-2 flex gap-2">
                  <button
                    onClick={() => navigator.clipboard?.writeText(link)}
                    className="px-3 py-2 text-xs rounded-xl border border-green-200 bg-white hover:bg-green-100"
                  >
                    Copy
                  </button>
                  <a
                    href={link}
                    target="_blank"
                    rel="noreferrer"
                    className="px-3 py-2 text-xs rounded-xl border border-green-200 bg-white hover:bg-green-100"
                  >
                    Open
                  </a>
                </div>
              </div>
            )}

            {toast && (
              <div className="mt-3 rounded-xl border border-gray-200 bg-gray-50 p-3 text-xs text-gray-700">{toast}</div>
            )}
          </div>

          <div className="max-h-[55vh] overflow-auto p-4 space-y-2">
            {msgsQ.isLoading ? (
              <div className="text-sm text-gray-500">Loading…</div>
            ) : msgsQ.isError ? (
              <div className="text-sm text-red-700">{errorText(msgsQ.error)}</div>
            ) : msgs.length === 0 ? (
              <div className="text-sm text-gray-500">No messages.</div>
            ) : (
              msgs.map((m) => {
                const mine = m.direction === 'out';
                return (
                  <div key={m.id} className={`flex ${mine ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[85%] rounded-2xl border px-3 py-2 text-sm ${mine ? 'bg-blue-50 border-blue-100' : 'bg-white border-gray-200'}`}>
                      <div className="text-[11px] text-gray-500 flex items-center justify-between gap-2">
                        <span>{mine ? 'OUT' : 'IN'} • {m.msg_type}{m.msg_type === 'template' && m.template_name ? ` • ${m.template_name}` : ''}{mine && m.wa_status ? ` • ${m.wa_status}` : ''}</span>
                        <span>{new Date(m.created_at).toLocaleString()}</span>
                      </div>
                      {m.body ? <div className="mt-1 whitespace-pre-wrap">{m.body}</div> : <div className="mt-1 text-gray-500 italic">(no text)</div>}
                    </div>
                  </div>
                );
              })
            )}
          </div>

          {selectedThread && (

            <div className="p-4 border-t border-gray-100 bg-gray-50">
              <div className="text-sm font-semibold">Internal notes</div>
              <div className="mt-2 rounded-xl border border-gray-200 bg-white p-3 max-h-40 overflow-auto">
                {notesQ.isLoading ? (
                  <div className="text-sm text-gray-500">Loading notes…</div>
                ) : notesQ.isError ? (
                  <div className="text-sm text-red-700">{errorText(notesQ.error)}</div>
                ) : notes.length === 0 ? (
                  <div className="text-sm text-gray-500">No notes yet.</div>
                ) : (
                  <div className="space-y-2">
                    {notes.map((n) => (
                      <div key={n.id} className="text-xs">
                        <div className="text-gray-700 whitespace-pre-wrap">{n.body}</div>
                        <div className="text-[11px] text-gray-500 mt-1">{new Date(n.created_at).toLocaleString()}</div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="mt-3 flex items-start gap-2">
                <textarea
                  value={noteBody}
                  onChange={(e) => setNoteBody(e.target.value)}
                  rows={2}
                  className="flex-1 rounded-xl border border-gray-200 bg-white p-2 text-sm outline-none focus:ring-2 focus:ring-gray-200"
                  placeholder="Add internal note (visible to admins only)…"
                />
                <button
                  onClick={addNote}
                  disabled={busyNote}
                  className="px-3 py-2 rounded-xl border border-gray-200 bg-white hover:bg-gray-50 text-sm disabled:opacity-60"
                >
                  {busyNote ? 'Saving…' : 'Add'}
                </button>
              </div>
            </div>

            <div className="p-4 border-t border-gray-100">
              <div className="flex items-center justify-between gap-2">
                <label className="flex items-center gap-2 text-xs text-gray-700">
                  <input type="checkbox" checked={templateMode} onChange={(e) => setTemplateMode(e.target.checked)} />
                  Send as template
                </label>
                {!csw.open && !templateMode ? (
                  <div className="text-[11px] text-amber-800 bg-amber-50 border border-amber-200 px-2 py-1 rounded-full">
                    CSW closed — template required
                  </div>
                ) : null}
              </div>

              {templateMode ? (
                <div className="mt-2 grid grid-cols-1 md:grid-cols-3 gap-2">
                  <input
                    value={templateName}
                    onChange={(e) => setTemplateName(e.target.value)}
                    placeholder="Template name (Meta-approved)"
                    className="px-3 py-2 rounded-xl border border-gray-200 text-sm"
                  />
                  <input
                    value={templateLang}
                    onChange={(e) => setTemplateLang(e.target.value)}
                    placeholder="Language (e.g. en_US)"
                    className="px-3 py-2 rounded-xl border border-gray-200 text-sm"
                  />
                  <div className="text-xs text-gray-500 flex items-center">Uses one BODY variable: your message</div>
                </div>
              ) : null}

              <div className="mt-3">
                <textarea
                  value={compose}
                  onChange={(e) => setCompose(e.target.value)}
                  placeholder={templateMode ? 'Template BODY variable text…' : 'Type a reply…'}
                  className="w-full min-h-[90px] rounded-xl border border-gray-200 p-3 text-sm"
                />
              </div>

              <div className="mt-2 flex items-center justify-between gap-2">
                <div className="text-[11px] text-gray-500">
                  Booking template (optional):{' '}
                  <input
                    value={bookingTemplateName}
                    onChange={(e) => setBookingTemplateName(e.target.value)}
                    placeholder="WHATSAPP_BOOKING_TEMPLATE_NAME override"
                    className="ml-2 px-2 py-1 rounded-lg border border-gray-200 text-[11px] w-[220px]"
                  />
                  <input
                    value={bookingTemplateLang}
                    onChange={(e) => setBookingTemplateLang(e.target.value)}
                    placeholder="en_US"
                    className="ml-2 px-2 py-1 rounded-lg border border-gray-200 text-[11px] w-[90px]"
                  />
                </div>
                <button
                  onClick={sendMessage}
                  disabled={busySend}
                  className="px-4 py-2 rounded-xl bg-black text-white text-sm disabled:opacity-50"
                >
                  {busySend ? 'Sending…' : templateMode ? 'Send template' : 'Send'}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
