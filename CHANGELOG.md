# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.3] - 2026-09-09

### Added
- **Docker support**: `Dockerfile` (multi-stage Node 24 Alpine build) and `docker-compose.yml` with Supabase credentials for container deployments.
- **Deployment docs**: `docs/deployment.md` — comprehensive deployment guide covering Docker, VPS, Cloudflare Pages, Vercel, and Fly.io.
- **Usage-based billing guide**: `docs/ai-billing.md` — adapter pattern for AI token usage tracking, metered billing, and usage-based pricing.
- **`.dockerignore`**: Build context exclusions for cleaner Docker builds.

## [0.2.2] - 2026-09-08

### Added
- **Auth module** (`src/lib/server/auth.ts`): `AuthError`, `checkPasswordStrength()`, `createUser()`, `listSessions()`, `destroyAllSessions()`, `normalizeEmail()`, `MIN_PASSWORD_LENGTH`, `SESSION_COOKIE`.
- **Password strength validation**: enforces uppercase, lowercase, and digit requirements (not just minimum length). Returns `{ ok, reasons }` for UI feedback.
- **Billing guard**: `assertSeatAvailable()` now blocks `past_due` and `canceled` subscriptions from adding new seats.
- **Billing adapter types**: `SubscriptionStatus`, `SubscriptionState`, `getSubscriptionState()` on the `BillingAdapter` interface.

### Fixed
- **`createUser` error handling**: catch block now only catches Postgres unique constraint violations (`23505`) instead of silently swallowing all DB errors as `email_taken`.

### Tests
- 208 tests (was 198): +10 new tests covering billing guard (past_due/canceled/active/trialing) and audit listing (offset, ordering).

## [0.2.1] - 2026-08-30

### Added
- **Source documentation (TSDoc)**: every exported symbol on the public API surface now carries a doc comment — parameter/return/throws contracts, the RBAC hierarchy (`mayActOn`/`mayGrant`), typed error codes, and the service-role vs user-scoped (`RLS`) Supabase client split. Comments only — no behavior, signature, or formatting change; all 198 tests still pass.
- **Generated public API reference**: `docs/api/` — a TypeDoc-generated reference for the full `src/lib/server` surface (rbac, audit, services, billing, supabase/client). Ships with the kit; regenerated from source so it cannot drift.
- **Docs gate (CI + release pipeline)**: `npm run docs:api:check` in CI and a `gen-api-docs` check in the release pipeline now fail if any exported symbol goes undocumented or if `docs/api` falls out of sync with the source.

## [0.2.0] - 2026-08-29

### Fixed
- **Seat limits now enforced at invite acceptance** — `acceptInvite` previously documented seat enforcement ("join time") but never called the billing adapter. It now counts the org's memberships and runs `billing.assertSeatAvailable(orgId, count)` before the single-use claim, so a full org never burns an invite it cannot honor.
- **`createBillingAdapter` guards invalid `MOCK_PLAN_SEATS`** — a non-numeric value previously produced a `NaN` seat limit that silently allowed unlimited joins; it now falls back to the default (3).

### Added
- **Service-level test suite** — 51 new tests across `tests/orgs-members.test.ts`, `tests/invites-seats.test.ts`, `tests/billing.test.ts`, `tests/audit.test.ts`, backed by an in-memory fake Supabase client (`tests/helpers/fake-supabase.ts`). No database or network needed; suite 24 → **198 tests**.
- **Documentation**: `docs/architecture.md`, `docs/rbac.md`, `docs/billing.md`, `docs/testing.md`

### Changed
- README/AGENTS/CLAUDE testing sections updated to the real suite layout and count

## [0.1.0] - 2026-08-29

### Added
- **Authentication**: Supabase Auth (email+password, magic links, OAuth)
- **Organizations**: Create, slug, owner bootstrap with Supabase RLS for tenant isolation
- **Invites**: Single-use hashed tokens, 7-day expiry, revoke, atomic claim
- **RBAC**: `owner > admin > member` hierarchy with capability matrix enforced server-side on every action
- **Billing**: `BillingAdapter` interface + deterministic `MockBillingAdapter` (seat limits enforced at join time)
- **Audit log**: Append-only by construction (no UPDATE/DELETE path exists)
- **RLS policies**: Defense-in-depth tenant isolation at the database level
- **Testing**: Comprehensive test suite covering auth, RBAC, invites, billing
- **CI**: GitHub Actions workflow (install → test → check → build)
- **Documentation**: Architecture, RBAC, billing, versioning docs

### Design Principles
- Server-side enforcement everywhere (UI hides controls, but every load/action re-checks)
- Services are framework-free (import nothing from `@sveltejs/kit`)
- Every mutating service call re-derives authority
- Errors carry machine codes (`AuthError`, `RbacError`, etc.)
- One error mapper (`errorToFail()`)
- RLS provides defense-in-depth alongside application-level RBAC

[0.2.3]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.2...v0.2.3
[0.2.1]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/verdantstack/sveltekit-supabase-starter/releases/tag/v0.1.0
