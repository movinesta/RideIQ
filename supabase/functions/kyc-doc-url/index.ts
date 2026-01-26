import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { logAppEvent } from '../_shared/log.ts';

type AttachDocument = {
  action: 'attach_document';
  submission_id: string;
  document_type_key?: string; // preferred
  doc_type?: string; // legacy
  object_key?: string; // preferred
  storage_object_key?: string; // legacy
  bucket?: string; // optional (default: kyc-documents)
  mime_type?: string | null;
  metadata?: Record<string, unknown>;
};

type CreateSignedUrl = {
  action: 'create_signed_url';
  bucket?: string;
  object_key: string;
  expires_in?: number;
};

type CreateSignedUploadUrl = {
  action: 'create_signed_upload_url';
  bucket?: string;
  object_key?: string; // if omitted, server generates one under kyc/<uid>/<submission>/<type>-<uuid>
  submission_id?: string;
  document_type_key?: string;
  mime_type?: string;
};

type Body = AttachDocument | CreateSignedUrl | CreateSignedUploadUrl;

function ensureUserScopedObjectKey(objectKey: string, userId: string) {
  // Enforce: kyc/<userId>/...
  const safe = objectKey.replace(/^\/+/, '');
  if (!safe.startsWith(`kyc/${userId}/`)) {
    throw new Error('object_key must be under kyc/<userId>/');
  }
  return safe;
}

function randomId() {
  return crypto.randomUUID();
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'POST') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');

  const { user, error } = await requireUser(req);
  if (!user) return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');

  const body = (await req.json().catch(() => ({}))) as Partial<Body>;
  if (!body || typeof body !== 'object' || !('action' in body)) {
    return errorJson('Invalid body', 400, 'INVALID_BODY');
  }

  const anon = createAnonClient(req);
  const svc = createServiceClient();

  // ===== attach_document =====
  if (body.action === 'attach_document') {
    const b = body as AttachDocument;
    if (!b.submission_id) return errorJson('Missing submission_id', 400, 'INVALID_BODY');

    const bucket = (b.bucket ?? 'kyc-documents').trim();
    const key = (b.object_key ?? b.storage_object_key ?? '').trim();
    if (!key) return errorJson('Missing object_key', 400, 'INVALID_BODY');

    let objectKey: string;
    try {
      objectKey = ensureUserScopedObjectKey(key, user.id);
    } catch (e) {
      return errorJson((e as Error).message, 400, 'INVALID_OBJECT_KEY');
    }

    // Ensure submission belongs to the user (supports both legacy + new columns)
    const { data: sub, error: subErr } = await anon
      .from('kyc_submissions')
      .select('id, user_id, profile_id')
      .eq('id', b.submission_id)
      .maybeSingle();

    if (subErr) return errorJson(subErr.message, 500, 'SUBMISSION_LOOKUP_FAILED');
    const ownerId = (sub as any)?.profile_id ?? (sub as any)?.user_id ?? null;
    if (!sub || ownerId !== user.id) return errorJson('Forbidden', 403, 'FORBIDDEN');

    // Resolve document type id (optional)
    const docKey = (b.document_type_key ?? b.doc_type ?? '').trim();
    let docTypeId: string | null = null;
    if (docKey) {
      const { data: dt, error: dtErr } = await anon
        .from('kyc_document_types')
        .select('id')
        .eq('key', docKey)
        .maybeSingle();
      if (dtErr) return errorJson(dtErr.message, 400, 'DOC_TYPE_LOOKUP_FAILED');
      docTypeId = dt?.id ?? null;
    }

    const insertRow: Record<string, unknown> = {
      submission_id: b.submission_id,
      profile_id: user.id,
      user_id: user.id, // legacy
      document_type_id: docTypeId,
      doc_type: docKey || null, // legacy
      object_key: objectKey,
      storage_bucket: bucket,
      storage_object_key: objectKey,
      mime_type: b.mime_type ?? null,
      metadata: b.metadata ?? {},
      status: 'pending',
    };

    const { data: doc, error: insErr } = await svc
      .from('kyc_documents')
      .insert(insertRow)
      .select('id, submission_id, document_type_id, doc_type, object_key, mime_type, status, created_at')
      .single();

    if (insErr || !doc) return errorJson(insErr?.message ?? 'Attach document failed', 500, 'ATTACH_DOCUMENT_FAILED');

    logAppEvent({ name: 'kyc_attach_document', user_id: user.id, ok: true });
    return json({ ok: true, document: doc }, 200);
  }

  // ===== create_signed_upload_url =====
  if (body.action === 'create_signed_upload_url') {
    const b = body as CreateSignedUploadUrl;
    const bucket = (b.bucket ?? 'kyc-documents').trim();

    let objectKey = (b.object_key ?? '').trim();
    if (!objectKey) {
      // Generate deterministic-ish path for organization: kyc/<uid>/<submission>/<type>-<uuid>
      const submissionId = (b.submission_id ?? 'draft').trim() || 'draft';
      const typeKey = (b.document_type_key ?? 'doc').trim() || 'doc';
      objectKey = `kyc/${user.id}/${submissionId}/${typeKey}-${randomId()}`;
    }

    try {
      objectKey = ensureUserScopedObjectKey(objectKey, user.id);
    } catch (e) {
      return errorJson((e as Error).message, 400, 'INVALID_OBJECT_KEY');
    }

    // Creates a signed upload URL + token (valid ~2 hours)
    const { data, error: sErr } = await svc.storage.from(bucket).createSignedUploadUrl(objectKey);
    if (sErr || !data) return errorJson(sErr?.message ?? 'Create signed upload URL failed', 500, 'SIGNED_UPLOAD_URL_FAILED');

    logAppEvent({ name: 'kyc_signed_upload_url', user_id: user.id, ok: true });
    return json({ ok: true, bucket, object_key: objectKey, signed_url: data.signedUrl, token: data.token }, 200);
  }

  // ===== create_signed_url =====
  if (body.action === 'create_signed_url') {
    const b = body as CreateSignedUrl;
    if (!b.object_key) return errorJson('Missing object_key', 400, 'INVALID_BODY');

    let objectKey: string;
    try {
      objectKey = ensureUserScopedObjectKey(b.object_key, user.id);
    } catch (e) {
      return errorJson((e as Error).message, 400, 'INVALID_OBJECT_KEY');
    }

    const bucket = (b.bucket ?? 'kyc-documents').trim();
    const expiresIn = Math.min(60 * 60, Math.max(60, Number(b.expires_in ?? 15 * 60)));

    const { data, error: sErr } = await svc.storage.from(bucket).createSignedUrl(objectKey, expiresIn);
    if (sErr || !data) return errorJson(sErr?.message ?? 'Create signed URL failed', 500, 'SIGNED_URL_FAILED');

    logAppEvent({ name: 'kyc_signed_url', user_id: user.id, ok: true });
    return json({ ok: true, signed_url: data.signedUrl, expires_in: expiresIn }, 200);
  }

  return errorJson('Unknown action', 400, 'UNKNOWN_ACTION');
});
