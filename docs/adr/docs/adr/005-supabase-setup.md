# ADR-004: Supabase Project Setup

**Status**: Accepted  
**Date**: 2026-03-24

## Context

Need a backend for a WhatsApp clone: auth, database, storage, realtime. Must be free to start, scalable, and secure by
default.

## Decision

Use Supabase with:

- Phone OTP auth (Twilio for SMS)
- `profiles` table with username requirement post-OTP
- RLS enabled on all tables — no exceptions
- Two storage buckets: avatars (auth-read, owner-write), chat-media (to be locked down per-conversation)
- Anon key only on the Flutter client — never service_role key

## Consequences

+ Auth, DB, storage, realtime in one platform
+ RLS enforced at DB level — Flutter bugs can't leak data
+ Free tier sufficient for development and early users

- SMS costs real money at scale — revisit provider at growth
- chat-media bucket policies deferred to chat feature