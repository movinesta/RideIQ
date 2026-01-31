/**
 * Zod validation schemas for Edge Function inputs.
 * Using Zod to REJECT invalid inputs with clear errors, rather than silently
 * sanitizing them (which can hide bugs and security issues).
 */
import { z } from 'npm:zod@3.23.8';

// --- Shared refinements ---

/** Validates latitude is within -90 to 90 */
export const latitudeSchema = z.number().finite().min(-90).max(90);

/** Validates longitude is within -180 to 180 */
export const longitudeSchema = z.number().finite().min(-180).max(180);

/** Non-empty trimmed string with max length. Returns trimmed value. */
export function trimmedString(maxLen: number) {
    return z
        .string()
        .transform((s) => s.trim())
        .pipe(z.string().min(1, 'String cannot be empty').max(maxLen, `String exceeds ${maxLen} characters`));
}

/** Optional trimmed string (null if empty/whitespace). */
export function optionalTrimmedString(maxLen: number) {
    return z
        .string()
        .optional()
        .nullable()
        .transform((s) => {
            if (s == null) return null;
            const trimmed = s.trim();
            return trimmed.length > 0 ? trimmed : null;
        })
        .pipe(z.string().max(maxLen).nullable());
}

// --- ride-intent-create schema ---

const ALLOWED_SOURCES = ['whatsapp', 'callcenter'] as const;

export const rideIntentCreateSchema = z.object({
    pickup_lat: latitudeSchema,
    pickup_lng: longitudeSchema,
    dropoff_lat: latitudeSchema,
    dropoff_lng: longitudeSchema,
    pickup_address: optionalTrimmedString(240),
    dropoff_address: optionalTrimmedString(240),
    product_code: z
        .string()
        .optional()
        .default('standard')
        .transform((s) => s.toLowerCase().slice(0, 32)),
    scheduled_at: z
        .string()
        .optional()
        .nullable()
        .transform((s) => {
            if (!s) return null;
            const d = new Date(s.trim());
            return Number.isNaN(d.getTime()) ? null : d.toISOString();
        }),
    source: z
        .string()
        .optional()
        .default('whatsapp')
        .transform((s) => {
            const lower = s.toLowerCase().trim() as (typeof ALLOWED_SOURCES)[number];
            return ALLOWED_SOURCES.includes(lower) ? lower : 'whatsapp';
        }),
    preferences: z.record(z.unknown()).optional().default({}),
});

export type RideIntentCreateInput = z.infer<typeof rideIntentCreateSchema>;

// --- admin-users-grant schema ---

export const adminUsersGrantSchema = z.object({
    user_id: z.string().uuid('user_id must be a valid UUID'),
    note: optionalTrimmedString(400),
});

export type AdminUsersGrantInput = z.infer<typeof adminUsersGrantSchema>;
