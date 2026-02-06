import { handleOptions } from '../_shared/cors.ts';
import { requireAdmin } from '../_shared/admin.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext, type RequestContext } from '../_shared/requestContext.ts';
import { createServiceClient } from '../_shared/supabase.ts';

type AnyRow = Record<string, unknown>;

async function safeSelectView(service: any, viewName: string, ctx: RequestContext): Promise<AnyRow[]> {
  const { data, error } = await service.from(viewName).select('*');
  if (error) {
    ctx.warn('ops.dashboard.view_failed', { view: viewName, error: error.message });
    return [];
  }
  return (Array.isArray(data) ? data : []) as AnyRow[];
}

async function safeSelectSingle(service: any, viewName: string, ctx: RequestContext): Promise<AnyRow | null> {
  const rows = await safeSelectView(service, viewName, ctx);
  return rows[0] ?? null;
}

async function safeRpc(service: any, fn: string, ctx: RequestContext): Promise<AnyRow | null> {
  const { data, error } = await service.rpc(fn);
  if (error) {
    ctx.warn('ops.dashboard.rpc_failed', { fn, error: error.message });
    return null;
  }
  const row = Array.isArray(data) ? data[0] : data;
  return (row && typeof row === 'object') ? (row as AnyRow) : null;
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  return await withRequestContext('ops-dashboard', req, async (ctx) => {
    const admin = await requireAdmin(req, ctx);
    if ('res' in admin) return admin.res;

    const service = createServiceClient();

    const [
      webhook,
      payments,
      dispatch,
      safety,
      maps,
      jobs,
      jobWorker,
      db,
      alertState,
      alertEvents,
    ] = await Promise.all([
      safeSelectView(service, 'ops_webhook_metrics_15m', ctx),
      safeSelectView(service, 'ops_payment_metrics_15m', ctx),
      safeSelectSingle(service, 'ops_dispatch_metrics_15m', ctx),
      safeSelectSingle(service, 'ops_safety_metrics_15m', ctx),
      safeSelectSingle(service, 'ops_maps_metrics_15m', ctx),
      safeSelectSingle(service, 'ops_job_queue_summary', ctx),
      safeSelectSingle(service, 'ops_job_worker_metrics_15m', ctx),
      safeRpc(service, 'ops_db_conn_stats', ctx),
      service
        .from('ops_alert_state')
        .select('is_active, active_since, last_message, last_triggered_at, last_resolved_at, last_value, rule:ops_alert_rules(name, kind, severity)')
        .order('updated_at', { ascending: false })
        .then(({ data, error }: any) => {
          if (error) {
            ctx.warn('ops.dashboard.alert_state_failed', { error: error.message });
            return [];
          }
          return Array.isArray(data) ? data : [];
        }),
      service
        .from('ops_alert_events')
        .select('occurred_at, event_type, message, value, rule:ops_alert_rules(name, severity)')
        .order('occurred_at', { ascending: false })
        .limit(50)
        .then(({ data, error }: any) => {
          if (error) {
            ctx.warn('ops.dashboard.alert_events_failed', { error: error.message });
            return [];
          }
          return Array.isArray(data) ? data : [];
        }),
    ]);

    // Guard: if migrations are not applied yet, surface an actionable response.
    if (!webhook.length && !payments.length && !dispatch && !safety && !maps && !jobs) {
      ctx.warn('ops.dashboard.empty', { hint: 'migrations_not_applied_or_no_data' });
    }

    return json(
      {
        ok: true,
        window_minutes: 15,
        generated_at: new Date().toISOString(),
        dashboards: {
          webhook,
          payments,
          dispatch,
          safety,
          maps,
          jobs,
          job_worker: jobWorker,
          db,
        },
        alerts: {
          state: alertState,
          recent_events: alertEvents,
        },
      },
      200,
      ctx.headers,
    );
  }).catch((err) => {
    // withRequestContext should catch; this is only for catastrophic failures.
    return errorJson(String(err?.message ?? err ?? 'Internal error'), 500);
  });
});
