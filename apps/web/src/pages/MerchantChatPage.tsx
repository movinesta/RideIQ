import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Link, useLocation, useParams } from 'react-router-dom';
import { useInfiniteQuery, useQuery, useQueryClient } from '@tanstack/react-query';
import type { RealtimeChannel } from '@supabase/supabase-js';
import { supabase } from '../lib/supabaseClient';
import { fetchPublicProfiles, listChatMessagesKeyset, merchantChatMarkRead, sendChatMessage, type ChatMessageCursor } from '../lib/merchant';

const PAGE_SIZE = 50;

export default function MerchantChatPage() {
  const { threadId } = useParams();
  const id = threadId as string;

  const qc = useQueryClient();
  const [text, setText] = useState('');
  const bottomRef = useRef<HTMLDivElement | null>(null);
  const markReadTimer = useRef<number | null>(null);

  const msgsQ = useInfiniteQuery({
    queryKey: ['merchant-chat-messages', id],
    queryFn: ({ pageParam }) => listChatMessagesKeyset(id, (pageParam as ChatMessageCursor | null) ?? null, PAGE_SIZE),
    initialPageParam: null,
    getNextPageParam: (last) => last.nextCursor ?? undefined,
    enabled: Boolean(id),
  });

  const messages = useMemo(() => {
    const pages = msgsQ.data?.pages ?? [];
    // pages[0] is newest chunk (DESC). We want global ASC for rendering.
    return pages
      .slice()
      .reverse()
      .flatMap((p) => (p.rows ?? []).slice().reverse());
  }, [msgsQ.data?.pages]);

  const profilesQ = useQuery({
    queryKey: ['merchant-chat-profiles', id, messages.map((m: any) => m.sender_id).join(',')],
    queryFn: async () => {
      const ids = Array.from(new Set(messages.map((m: any) => m.sender_id)));
      return fetchPublicProfiles(ids);
    },
    enabled: Boolean(id) && messages.length > 0,
  });

  const profileMap = useMemo(() => {
    const m = new Map<string, any>();
    for (const p of profilesQ.data ?? []) m.set(p.id, p);
    return m;
  }, [profilesQ.data]);

  const markRead = React.useCallback(() => {
    if (!id) return;
    if (markReadTimer.current) window.clearTimeout(markReadTimer.current);
    markReadTimer.current = window.setTimeout(() => {
      void merchantChatMarkRead(id).catch(() => null);
    }, 250);
  }, [id]);

  useEffect(() => {
    // Mark as read on open
    markRead();
    return () => {
      if (markReadTimer.current) window.clearTimeout(markReadTimer.current);
    };
  }, [markRead]);

  useEffect(() => {
    let ch: RealtimeChannel | null = null;

    async function sub() {
      if (!id) return;
      ch = supabase
        .channel(`merchant-chat:${id}`)
        .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'merchant_chat_messages', filter: `thread_id=eq.${id}` }, (payload) => {
          const next = (payload as any).new;

          qc.setQueryData(['merchant-chat-messages', id], (prev: any) => {
            if (!prev) return prev;
            const pages = Array.isArray(prev.pages) ? prev.pages.slice() : [];
            if (pages.length === 0) return prev;
            const first = { ...pages[0] };
            const rows = Array.isArray(first.rows) ? first.rows.slice() : [];
            if (rows.some((m: any) => m.id === next.id)) return prev;
            // DESC chunk: newest at index 0
            first.rows = [next, ...rows];
            pages[0] = first;
            return { ...prev, pages };
          });

          qc.invalidateQueries({ queryKey: ['merchant-chat-profiles', id] });

          if (document.visibilityState === 'visible') {
            markRead();
          }
        })
        .subscribe();
    }

    sub();

    return () => {
      if (ch) supabase.removeChannel(ch);
    };
  }, [id, qc, markRead]);

  useEffect(() => {
    // Scroll to bottom on new messages (but not when loading older pages)
    if (!msgsQ.isFetchingNextPage) bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length, msgsQ.isFetchingNextPage]);

  async function onSend() {
    const body = text.trim();
    if (!body) return;
    setText('');
    await sendChatMessage(id, body);
    markRead();
  }

  return (
    <div className="max-w-3xl mx-auto p-4 space-y-3">
      <div className="flex items-center justify-between gap-2">
        <h1 className="text-xl font-semibold">Chat</h1>
        {msgsQ.hasNextPage ? (
          <button className="border rounded px-3 py-2 hover:bg-gray-50 disabled:opacity-50" disabled={msgsQ.isFetchingNextPage} onClick={() => void msgsQ.fetchNextPage()}>
            {msgsQ.isFetchingNextPage ? 'Loading…' : 'Load earlier'}
          </button>
        ) : null}
      </div>

      {msgsQ.isLoading ? <div className="text-sm text-gray-500">Loading…</div> : null}
      {msgsQ.error ? <div className="text-sm text-red-600">Failed to load messages.</div> : null}

      <div className="border rounded p-3 space-y-2 min-h-[50vh] max-h-[60vh] overflow-auto">
        {messages.map((m: any) => {
          const sender = profileMap.get(m.sender_id);
          return (
            <div key={m.id} className="border rounded p-2">
              <div className="text-xs text-gray-500 flex items-center justify-between">
                <span>{sender?.display_name ?? m.sender_id}</span>
                <span>{new Date(m.created_at).toLocaleString()}</span>
              </div>
              <div className="mt-1 whitespace-pre-wrap">{m.body}</div>
            </div>
          );
        })}
        {messages.length === 0 && !msgsQ.isLoading ? <div className="text-sm text-gray-500">No messages yet.</div> : null}
        <div ref={bottomRef} />
      </div>

      <div className="border rounded p-3 flex gap-2">
        <input className="border rounded px-3 py-2 flex-1" value={text} onChange={(e) => setText(e.target.value)} placeholder="Type a message…" />
        <button className="border rounded px-3 py-2 hover:bg-gray-50 disabled:opacity-50" disabled={!text.trim()} onClick={() => void onSend()}>
          Send
        </button>
      </div>
    </div>
  );
}
