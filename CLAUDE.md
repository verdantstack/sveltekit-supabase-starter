# CLAUDE.md — Claude AI Context

> Context for Claude when working on this codebase.

## What This Is

A production-grade B2B SaaS foundation for SvelteKit + Supabase. Not a tutorial, not a boilerplate — a working implementation of multi-tenancy, RBAC, seat billing, audit logging, and Supabase RLS with 198 tests.

## The Mental Model

Think of this as three layers:

1. **Routes** (thin — yours to wire; this kit ships the service layer) — parse forms, call services, handle errors
2. **Services** (domain logic) — pure functions that accept a Supabase client and do real work
3. **Infrastructure** (supabase, rbac, billing) — pluggable seams, not monoliths

The key insight: **services never import from SvelteKit**. This makes them testable and portable to any framework.

## When Modifying Code

### If you're changing behavior
1. Write the test first (or alongside)
2. Service layer is where logic lives — not in routes
3. Every write must go through `requirePermission()` + `requireRole()`
4. Every write must produce an audit entry in the same call

### If you're changing the schema
1. Edit SQL in `supabase/migrations/`
2. Update RLS policies if the change affects tenant isolation
3. Test both application-level and RLS-level enforcement
4. Run `supabase db diff` to verify changes

### If you're adding a new feature
1. Check `rbac.ts` — does it need a new permission?
2. Create service in `src/lib/server/services/`
3. Wire the route in `src/routes/`
4. Add error types if needed
5. Test the full flow

## Things That Will Bite You

- **RLS vs application code:** Application-level RBAC and RLS are defense-in-depth. Don't rely on one alone.
- **RBAC hierarchy:** `mayActOn(actor, target)` requires `rank(actor) > rank(target)`. An admin cannot touch another admin. This is by design.
- **Last owner:** The code prevents the last owner from leaving or being removed. Don't remove this check.
- **Invite race conditions:** Single-use invites use conditional UPDATE, not read-then-write. Two concurrent clicks = exactly one winner. Don't "fix" this with transactions.
- **Audit is append-only:** There is no UPDATE or DELETE path for audit_log. Don't add one.
- **Service role vs anon key:** Use service role for admin operations, anon key for user-scoped operations with RLS.

## Testing Philosophy

- Tests exercise services directly against an in-memory fake Supabase client (`tests/helpers/fake-supabase.ts`) — no database, no network
- RBAC / org / member / invite / billing / audit suites (198 tests) prove the business rules
- The fake implements the fluent query surface the services use; services type their first param as `SupabaseClient` and tests cast (`as any`) at the call site
- RLS policies are defense-in-depth and need a real instance: `supabase start` (see `docs/testing.md`)

## Code Conventions

- TypeScript strict mode
- Error classes: `AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`
- Timestamps: milliseconds, UTC
- Database: Supabase (PostgreSQL via Supabase client)
- No external services needed for RBAC/billing tests (mock adapters)
