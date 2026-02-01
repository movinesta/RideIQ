import { withRequestContext } from '../_shared/requestContext.ts';
import { fareEngine } from '../_shared/fareEngine.ts';

/**
 * Stable entrypoint for the pricing system.
 *
 * Today this uses a deterministic, route-based baseline engine.
 * Later this can be extended to call ML components while preserving:
 * - request validation
 * - zone resolution
 * - audit logging
 */
Deno.serve((req) =>
  withRequestContext('fare-engine', req, async (ctx) => {
    return fareEngine(req, ctx, 'fare-engine-v1');
  }),
);
