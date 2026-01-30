begin;

create extension if not exists pgtap with schema extensions;

select plan(6);

-- Setup test user
insert into auth.users (id, email) values
  ('44444444-4444-4444-4444-444444444444', 'rider_whatsapp@test.com');

-- Create minimal thread
insert into public.whatsapp_threads (id, wa_id, stage, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, last_message_at)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  '9647TESTWAID',
  'ready',
  33.3123, 44.3611,
  33.3050, 44.3900,
  now()
);

-- Insert booking token
insert into public.whatsapp_booking_tokens (
  id, thread_id, token, token_hash, expires_at,
  pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
  pickup_address, dropoff_address
) values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
  'hash',
  now() + interval '30 minutes',
  33.3123, 44.3611,
  33.3050, 44.3900,
  'pickup', 'dropoff'
);

-- View works (public RPC)
select results_eq(
  $$select count(*)::int from public.whatsapp_booking_token_view_v1('deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef')$$,
  $$values (1)$$,
  'view returns active token'
);

-- Consume as authenticated user
set local request.jwt.claim.sub = '44444444-4444-4444-4444-444444444444';

select ok(
  (select public.whatsapp_booking_token_consume_v1('deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef') is not null),
  'consume returns ride_intent id'
);

select results_eq(
  $$select count(*)::int from public.ride_intents where rider_id = '44444444-4444-4444-4444-444444444444' and source = 'whatsapp'$$,
  $$values (1)$$,
  'ride_intent created'
);

select results_eq(
  $$select count(*)::int from public.whatsapp_booking_tokens where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb' and used_at is not null and used_by='44444444-4444-4444-4444-444444444444'$$,
  $$values (1)$$,
  'token marked used'
);

-- Second consume should fail
select throws_ok(
  $$select public.whatsapp_booking_token_consume_v1('deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef')$$,
  '22023',
  'token_used',
  'cannot consume twice'
);

select * from finish();

rollback;
