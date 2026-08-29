# AGENTS.md — AI Agent Context for SvelteKit + Supabase Starter

> This file tells AI coding agents everything they need to work effectively in this codebase.

## Project Overview

A production-grade B2B SaaS foundation for SvelteKit + Supabase with multi-tenancy wired end-to-end. Implements organizations, invitations, role-based access control, seat-based billing, an append-only audit log, and Supabase RLS for tenant isolation.

**Status:** v0.1 — Core features implemented, tests passing, production-ready foundation.

## Quick Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:5173)
npm test             # Run vitest suite
npm run check        # Run svelte-check (TypeScript validation)
npm run build        # Production build
```

## Architecture

```
routes (+page.server.ts)      → thin: parse form → call service → fail/redirect
        ↓
services (orgs/members/invites)  → domain logic, pure functions
        ↓
rbac.ts / billing/            → policy + payment seams
        ↓
supabase/client.ts            → Supabase client (service role for admin, user-scoped for RLS)
```

### Critical Rules

1. **Routes NEVER touch the database directly** — all writes go through services
2. **Services are framework-free** — import nothing from `@sveltejs/kit`
3. **Every mutating service call re-derives authority** — callers pass `actorRole`, fetched fresh inside the same request
4. **Errors carry machine codes** — `AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`
5. **RLS provides defense-in-depth** — application code enforces RBAC, RLS enforces tenant isolation

## Key Files

| File | Purpose |
|------|---------|
| `src/lib/server/rbac.ts` | Roles, permission matrix (`MATRIX`), hierarchy helpers (`mayActOn`, `mayGrant`) |
| `src/lib/server/audit.ts` | Append-only audit log |
| `src/lib/server/supabase/client.ts` | Supabase client setup (service role + user-scoped) |
| `src/lib/server/billing/adapter.ts` | `BillingAdapter` interface |
| `src/lib/server/billing/mock.ts` | Mock billing implementation |
| `src/lib/server/services/` | Domain logic: orgs, members, invites (pure functions) |
| `supabase/migrations/` | SQL migrations with RLS policies |
| `tests/` | Vitest suites |

## RBAC Model

**Roles:** `owner` (rank 2) > `admin` (rank 1) > `member` (rank 0)

**Hierarchy rules (enforced everywhere):**
1. Act downward only — `rank(actor) > rank(target)`
2. Grant strictly below yourself — `rank(actor) > rank(granted)`
3. No self-modification
4. Single-owner invariant — last owner cannot leave or be removed

**Capability matrix** (in `rbac.ts` `MATRIX`):
- `owner`: all permissions
- `admin`: org.view, members.view, members.invite, members.remove*, members.role.set*, invites.revoke, audit.view
- `member`: org.view, members.view

*subject to hierarchy rules

## Database (Supabase)

- **Driver:** Supabase JS client
- **ORM:** None (raw SQL migrations + Supabase client)
- **RLS:** Enabled — tenant isolation at database level
- **Migrations:** Applied via Supabase CLI or dashboard

### Key Schema Tables
- `organizations` — name, slug, created_at
- `memberships` — org_id, user_id, role (unique on org_id + user_id)
- `invites` — org_id, token_hash, role, expiry, accepted/revoked timestamps
- `audit_log` — org_id, actor_user_id, action, metadata (append-only, no UPDATE/DELETE)

## Testing

- **Framework:** Vitest
- **Runtime:** service-level tests run against an in-memory fake Supabase client — no database needed (`tests/helpers/fake-supabase.ts`)
- **RLS-level checks:** `supabase start` (see `docs/testing.md`)
- **Run:** `npm test` (75 tests)

### Test Files
| File | Coverage |
|------|----------|
| `tests/rbac.test.ts` | Matrix pinning, hierarchy rules |
| `tests/orgs-members.test.ts` | Org CRUD, membership management, role hierarchy, transfer invariants |
| `tests/invites-seats.test.ts` | Invite lifecycle, atomic single-use claim, expiry/revoke, seat limits |
| `tests/billing.test.ts` | Mock adapter contract, seat boundaries, env override |
| `tests/audit.test.ts` | Append-only audit writer, metadata serialization |
| `tests/smoke.test.ts` | Build verification, constants, adapter instantiation |

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `PUBLIC_SUPABASE_URL` | Your Supabase project URL |
| `PUBLIC_SUPABASE_ANON_KEY` | Your Supabase anonymous key |
| `PRIVATE_SUPABASE_SERVICE_ROLE_KEY` | Your Supabase service role key (server only) |
| `MOCK_PLAN_SEATS` | Seat limit for MockBilling (default: 3) |

## Code Style

- TypeScript strict mode
- Server-side enforcement everywhere
- Errors use typed error classes (not strings)
- Timestamps in milliseconds, UTC only
- Services are framework-free

## Common Patterns

### Adding a new service action
1. Add the permission to `MATRIX` in `rbac.ts` if needed
2. Create the service function in `src/lib/server/services/`
3. Accept Supabase client as needed, `actorRole` as needed
4. Call `requirePermission()` before any write
5. Write audit log entry in the same service call
6. Add tests in `tests/`

### Adding a new route
1. Create `+page.server.ts` in the route directory
2. Parse form data / URL params
3. Call service functions (never touch DB directly)
4. Handle errors via error responses
5. Return redirects or data

### Modifying the schema
1. Edit SQL in `supabase/migrations/`
2. Update RLS policies if needed
3. Test both application-level and RLS-level enforcement

## Build & CI

- **CI:** GitHub Actions (install → test → check → build)
- **Build:** `npm run build` (adapter-auto)
- **Supabase required** for full testing (RLS policies need a running database)
