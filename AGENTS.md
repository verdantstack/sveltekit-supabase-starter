# AGENTS.md — AI Agent Context for SvelteKit + Supabase Starter

> This file tells AI coding agents everything they need to work effectively in this codebase.

## Project Overview

A B2B SaaS foundation for SvelteKit + Supabase with multi-tenancy wired end-to-end. Implements organizations, invitations, role-based access control, seat-based billing, an append-only audit log, and Supabase RLS enforcing tenant isolation on every tenant-scoped read.

**Status:** v0.4.5 — 742 tests passing. ≥ 95% coverage enforced (measured 2026-11-08 on this tree: 99.23% statements / 96.39% branches / 99.48% functions / 99.71% lines).

## Quick Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:5173)
npm test             # Run vitest suite (743 tests)
npm run test:coverage  # Run with coverage enforcement — MUST pass before any commit/release
npm run check        # Run svelte-check (TypeScript validation)
npm run build        # Production build
```

## Architecture

```
your +page.server.ts routes   → thin: parse form → call service → fail/redirect
        (reference UI ships in src/routes — signup/login, orgs, members, invites, audit)
        ↓
services (orgs/members/invites)  → domain logic, pure functions
        ↓
rbac.ts / ratelimit.ts / billing/ → policy + seam + payment seams
        ↓
supabase/client.ts            → Supabase client (service role for admin, user-scoped for RLS)
tenant.ts                    → which client a call gets: RLS-scoped reads vs service-role writes
```

### Critical Rules

1. **Routes NEVER touch the database directly** — all writes go through services
2. **Services are framework-free** — import nothing from `@sveltejs/kit`
3. **Every mutating service call re-derives authority** — callers pass `actorRole`, fetched fresh inside the same request
4. **Errors carry machine codes** — `AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`
5. **RLS backs up every tenant-scoped read** — application code enforces RBAC; RLS independently filters tenant data at the database
6. **Never decide twice** — the billing seam reports, `billing/service.ts` decides. A second seat check is a second, drifting rule
7. **Pick the client deliberately** — `tenant.ts::requireTenantClient` for tenant-scoped reads (RLS enforced); `createServerClient()` for writes. The reasons writes use the service role are documented in `tenant.ts` — read them before moving one
8. **A tenant's region is written once** — `services/orgs.ts:createOrg` sets `organizations.region_code` from `regions.resolveNewOrgRegion`, and `services/residency.ts:completeRegionChange` is the **only** code path that changes it afterwards, against an open, owner-requested change. Do not add a second writer, and do not let an ordinary update carry it: a silent re-homing is the exact failure the column exists to make impossible
9. **A residency policy field is only real if something enforces it** — every field in `ResidencyPolicy` is mapped to an enforcement point in `regions.ts`'s own JSDoc and in [`docs/residency.md`](docs/residency.md) §2. Adding a knob without a call site is a marketing claim, and this kit does not ship those
10. **A code that reaches `errorToFail` must be registered** — `http.ts` maps only codes in `CODE_STATUS`; anything else is a logged, generic 500. Registering a code says "a signed-in user can read this and act on it", so an operator misconfiguration (`bad_default_region`) stays unregistered on purpose

## Key Files

| File                                   | Purpose                                                                                                                                                                         |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/lib/server/rbac.ts`               | Roles, permission matrix (`MATRIX`), hierarchy helpers (`mayActOn`, `mayGrant`)                                                                                                 |
| `src/lib/server/regions.ts`            | Region catalogue (frozen code) + the data-processing policy each region implies; `resolveNewOrgRegion()`, `assertTargetRegion()`, `pseudonymizeActorId()`                       |
| `src/lib/server/services/residency.ts` | Data residency: `getOrgResidency()`, `requestRegionChange()`/`completeRegionChange()`/`cancelRegionChange()`, `assertWebhookEgress()`, `exportOrgAudit()`, `residencyReport()`  |
| `src/lib/server/services/account.ts`   | Closing your own account: `deleteAccount()` — the caller is derived from the session token, and the deletion is audited                                                         |
| `src/lib/server/audit.ts`              | Append-only audit log, counter, and paged/capped/formula-guarded CSV+JSON export                                                                                                |
| `src/lib/server/ratelimit.ts`          | `RateLimiter` seam + sliding-window failed-attempt limiter                                                                                                                      |
| `src/lib/server/supabase/client.ts`    | Supabase client setup (service role + user-scoped)                                                                                                                              |
| `src/lib/server/http.ts`               | Domain error → HTTP status mapper (`errorToFail`); registered codes only, else a logged 500; re-throws `redirect()`                                                             |
| `src/lib/server/tenant.ts`             | Which Supabase client a call gets: RLS-scoped reads vs service-role writes                                                                                                      |
| `src/lib/server/billing/service.ts`    | Single seat-enforcement point (`countActiveSeats`, `assertSeatAvailable`)                                                                                                       |
| `src/lib/server/billing/adapter.ts`    | `BillingAdapter` interface — **reporting only**, no seat decision                                                                                                               |
| `src/lib/server/billing/mock.ts`       | Mock billing implementation                                                                                                                                                     |
| `src/lib/server/services/`             | Domain logic: orgs, members, invites, files, webhooks, notifications, api-keys, audit-retention, impersonation, blog, affiliates, usage-billing, waitlist, mfa (pure functions) |
| `src/lib/server/ai/`                   | AI SDK integration (chat endpoint)                                                                                                                                              |
| `src/lib/server/billing/stripe.ts`     | Stripe billing adapter                                                                                                                                                          |
| `src/lib/server/audit.ts`              | Append-only audit log, counter, paged/capped/formula-guarded CSV+JSON export                                                                                                    |
| `src/routes/app/settings/`             | User profile & settings                                                                                                                                                         |
| `src/routes/app/files/`                | File upload/storage                                                                                                                                                             |
| `src/routes/app/webhooks/`             | Webhook management                                                                                                                                                              |
| `src/routes/app/notifications/`        | In-app notifications                                                                                                                                                            |
| `src/routes/app/api-keys/`             | API keys                                                                                                                                                                        |
| `src/routes/app/audit-retention/`      | Audit retention / SIEM export                                                                                                                                                   |
| `src/routes/app/org/[id]/region/`      | Data residency page: region + policy, data-class counts, retention posture, pending move, history, owner-only request form                                                      |
| `src/routes/app/admin/`                | Admin dashboard                                                                                                                                                                 |
| `src/routes/app/impersonate/`          | User impersonation                                                                                                                                                              |
| `src/routes/app/mfa/`                  | MFA / 2FA (TOTP)                                                                                                                                                                |
| `src/routes/blog/`                     | Blog / content system                                                                                                                                                           |
| `src/routes/landing/`                  | Landing pages                                                                                                                                                                   |
| `src/routes/waitlist/`                 | Waitlist                                                                                                                                                                        |
| `src/routes/api-docs/`                 | OpenAPI docs                                                                                                                                                                    |
| `src/lib/i18n/`                        | i18n (4 locales: en/es/fr/de)                                                                                                                                                   |
| `e2e/`                                 | Playwright E2E tests                                                                                                                                                            |
| `supabase/migrations/`                 | SQL migrations with RLS policies; `0003_residency.sql` adds `region_code`, `dpa_accepted_at` and `region_moves`                                                                 |
| `tests/`                               | Vitest suites                                                                                                                                                                   |
| `Dockerfile`                           | Multi-stage Docker build (Node 24 Alpine)                                                                                                                                       |
| `docker-compose.yml`                   | Docker Compose with Supabase credentials                                                                                                                                        |
| `docs/deployment.md`                   | Deployment guide (Docker, VPS, Cloudflare, Vercel, Fly)                                                                                                                         |
| `docs/ai-billing.md`                   | Usage-based billing adapter pattern (AI tokens, metered pricing)                                                                                                                |

## RBAC Model

**Roles:** `owner` (rank 2) > `admin` (rank 1) > `member` (rank 0)

**Hierarchy rules (enforced everywhere):**

1. Act downward only — `rank(actor) > rank(target)`
2. Grant strictly below yourself — `rank(actor) > rank(granted)`
3. No self-modification
4. Single-owner invariant — last owner cannot leave or be removed

**Capability matrix** (in `rbac.ts` `MATRIX`):

- `owner`: all permissions
- `admin`: org.view, members.view, members.invite, members.remove*, members.role.set*, invites.revoke, audit.view, org.region.view
- `member`: org.view, members.view, org.region.view

*subject to hierarchy rules

`org.region.view` is deliberately granted to **every** role: which jurisdiction a
member's data is processed in is a fact about that member's data, not an
administrative detail. `org.region.move` is owner-only — it commits the whole
tenant, including everyone else's data, to a different legal regime.

## Database (Supabase)

- **Driver:** Supabase JS client
- **ORM:** None (raw SQL migrations + Supabase client)
- **RLS:** Enabled — tenant isolation at database level
- **Migrations:** Applied via Supabase CLI or dashboard
- **Data API grants:** Every migration grants its own tables — see below

### Data API grants (required, do not remove)

From **2026-10-30** Supabase stops automatically granting Data API access to
tables newly created in the `public` schema — for **existing** projects too. A
table created after that date is reachable only if an explicit `GRANT` exists;
without it, PostgREST answers every request with
`42501 permission denied for table <name>`, even though the table exists, its RLS
policies are correct and the keys are right.

The grants therefore live in the **same migration file that creates each table**,
not in a follow-up migration. Same-file is the requirement, not a style choice:
`supabase db push`, `supabase db reset` and preview branches each create the
tables from these files, and a separate grant migration leaves an install that can
stop between the two and ship an unreachable table.

| Role            | Privileges granted on every tenant table |
| --------------- | ---------------------------------------- |
| `anon`          | `SELECT`                                 |
| `authenticated` | `SELECT, INSERT, UPDATE, DELETE`         |
| `service_role`  | `SELECT, INSERT, UPDATE, DELETE`         |

This mirrors Supabase's documented default for new tables, so behaviour after the
change matches behaviour before it. Tables created before the effective date keep
the grants they already hold.

Two things that are easy to get wrong when editing a migration:

1. **`service_role` needs real privileges.** It bypasses RLS, but bypassing RLS
   is not bypassing the privilege system. Every admin write in this kit (org
   create, invites, role changes, removals, ownership transfer and their audit
   entry) runs as `service_role` and fails with 42501 without the grant.
2. **Withholding UPDATE/DELETE from `audit_log` would not make it append-only.**
   The append-only guarantee is the absence of an UPDATE/DELETE _policy_; no
   non-bypassing role can satisfy that regardless of privilege. So the full
   vendor matrix is granted and the guarantee is unchanged.

`tests/schema-contract.test.ts` enforces all of it statically: it parses every
migration and fails naming the file, table, role and missing privilege. It also
fails if a write privilege is ever granted to `anon`. Adding a table therefore
means adding its grants in the same file, or the suite goes red — which is the
point.

### Key Schema Tables

- `organizations` — name, slug, created_at, `region_code` (written once at creation; see rule 8), `dpa_accepted_at`
- `region_moves` — recorded requests to re-home a tenant: `from_region`, `to_region`, `status` (`requested`/`completed`/`cancelled`), requester, justification, timestamps. RLS: members read, owners write, no DELETE policy; partial unique index keeps one open request per tenant
- `memberships` — org_id, user_id, role (unique on org_id + user_id)
- `invites` — org_id, token_hash, role, expiry, accepted/revoked timestamps
- `audit_log` — org_id, actor_user_id, action, metadata (append-only, no UPDATE/DELETE)
- `users` — PostgREST-embeddable profile mirror of `auth.users`, kept in sync by trigger (migration `0002`)

> **Apply every migration, in order.** `0001_initial_schema.sql` alone leaves
> the org dashboard broken: `listMembers()` embeds `users!inner(...)`, and `0001`
> creates no `users` relation. `0002_users_profile.sql` adds it, plus the foreign
> key PostgREST needs to plan the embed. `0003_residency.sql` adds the residency
> columns and `region_moves`; without it, creating an organization fails with
> `PGRST204` (no `region_code` column) rather than silently skipping the region.

## Testing

- **Framework:** Vitest
- **Runtime:** service-level tests run against an in-memory fake Supabase client — no database needed (`tests/helpers/fake-supabase.ts`)
- **RLS-level checks:** `supabase start` (see `docs/testing.md`)
- **Run:** `npm test` (743 tests)
- **Coverage threshold:** ≥ 95% statements/branches/functions/lines (enforced in `vitest.config.ts`). Measured 2026-11-08: **99.23% statements / 96.39% branches / 99.48% functions / 99.71% lines**. Branches sit closest to the floor
- **Coverage command:** `npm run test:coverage` (fails if < 95%; run before every commit)

### Test Files

| File                                | Coverage                                                                                                                                                                                                   |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tests/rbac.test.ts`                | Matrix pinning, hierarchy rules                                                                                                                                                                            |
| `tests/orgs-members.test.ts`        | Org CRUD, membership management, role hierarchy, transfer invariants                                                                                                                                       |
| `tests/invites-seats.test.ts`       | Invite lifecycle, atomic single-use claim, expiry/revoke, seat limits                                                                                                                                      |
| `tests/billing.test.ts`             | Mock adapter contract, seat boundaries, env override                                                                                                                                                       |
| `tests/auth.test.ts`                | Auth helpers, password validation, session management                                                                                                                                                      |
| `tests/ratelimit.test.ts`           | Sliding-window semantics, eviction, env-driven configuration                                                                                                                                               |
| `tests/billing-edge-cases.test.ts`  | Seat upgrades/downgrades, adapter failures, boundary conditions                                                                                                                                            |
| `tests/rbac-boundary.test.ts`       | Cross-org isolation, rank escalation, hierarchy enforcement                                                                                                                                                |
| `tests/service-integration.test.ts` | Full multi-step flows through the service layer                                                                                                                                                            |
| `tests/audit.test.ts`               | Append-only audit writer, metadata serialization                                                                                                                                                           |
| `tests/smoke.test.ts`               | Build verification, constants, adapter instantiation                                                                                                                                                       |
| `tests/edge-cases.test.ts`          | Cross-cutting edge cases — unicode slugs, error hierarchy, audit edges, multi-module flows                                                                                                                 |
| `tests/smoke-extended.test.ts`      | Extended smoke — constant pinning, type verification, module-export sanity                                                                                                                                 |
| `tests/http.test.ts`                | Domain error → HTTP status mapping, redirect propagation                                                                                                                                                   |
| `tests/http-status.test.ts`         | **Real route actions** — the HTTP status a browser POST actually receives                                                                                                                                  |
| `tests/billing-service.test.ts`     | Seat-enforcement contract: boundary, subscription states, provider errors                                                                                                                                  |
| `tests/audit-export.test.ts`        | `countAudit`, CSV/JSON export, CSV escaping round-trip                                                                                                                                                     |
| `tests/audit-export-route.test.ts`  | Audit export endpoint gating, headers, export audit entry                                                                                                                                                  |
| `tests/schema-contract.test.ts`     | Queried relations exist **and are related**; every created table has its Data API grants                                                                                                                   |
| `tests/tenant-client.test.ts`       | Read/write client split — keeps RLS actually enforced                                                                                                                                                      |
| `tests/defects.test.ts`             | Regression tests for defects found by review                                                                                                                                                               |
| `tests/residency.test.ts`           | Region catalogue invariants, region-at-creation, DPA capture, move state machine, webhook-egress and cross-border-export refusals, pseudonymisation stability, retention report, error-code → HTTP mapping |
| `tests/account-deletion.test.ts`    | Account closing: session-token identity (a forged form id is ignored), audit row, 401/500 mapping, and a source scan that fails if the route imports the admin API again                                   |

## Environment Variables

| Variable                            | Purpose                                                                                                                                                                                                                                  |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PUBLIC_SUPABASE_URL`               | Your Supabase project URL                                                                                                                                                                                                                |
| `PUBLIC_SUPABASE_ANON_KEY`          | Your Supabase anonymous key                                                                                                                                                                                                              |
| `PRIVATE_SUPABASE_URL`              | Your Supabase project URL (server only)                                                                                                                                                                                                  |
| `PRIVATE_SUPABASE_ANON_KEY`         | Your Supabase anon key (server only; user-scoped clients)                                                                                                                                                                                |
| `PRIVATE_SUPABASE_SERVICE_ROLE_KEY` | Your Supabase service role key (server only)                                                                                                                                                                                             |
| `MOCK_PLAN_SEATS`                   | Seat limit for MockBilling (default: 3)                                                                                                                                                                                                  |
| `AUTH_FAILED_ATTEMPTS`              | Failed attempts allowed per window (default: 5)                                                                                                                                                                                          |
| `AUTH_WINDOW_MS`                    | Sliding window for failed auth attempts (default: 900000)                                                                                                                                                                                |
| `REGION_DEFAULT`                    | Region a new organization lands in when the caller names none (default: `us-east-1`). Validated against the catalogue — an unknown value throws `bad_default_region` rather than silently placing tenants in a jurisdiction nobody chose |

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

### Wiring a new route in your app

1. Create `+page.server.ts` in the route directory
2. Parse form data / URL params
3. Call service functions (never touch DB directly)
4. Pick the client: `requireTenantClient(locals.accessToken)` for tenant-scoped
   **reads**, `createServerClient()` for **writes**
5. Map caught errors with `errorToFail(e)` from `$lib/server/http` — never return
   a bare `{ error }` object, which SvelteKit serves as **HTTP 200**
6. Return redirects or data

### Modifying the schema

1. Edit SQL in `supabase/migrations/`
2. Update RLS policies if needed
3. **Add the Data API grants for any new table, in that same file** — see
   "Data API grants" above. `tests/schema-contract.test.ts` fails without them,
   and the install would return 42501 from 2026-10-30 onward
4. Test both application-level and RLS-level enforcement

## Build & CI

- **Quality gates:** clean-room install of the built artifact (the clean-room artifact gate, release Step 0b — unzip to an empty dir, install with no cache, run the suite) + `npm test` + ≥95% line/branch/function/statement coverage enforced by `vitest.config.ts`. **No CI service is included** — `.github/workflows/` is stripped from the public proof layer by design.
- **Build:** `npm run build` (adapter-auto)
- **Supabase required** for full testing (RLS policies need a running database)
