# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-08-29

### Fixed
- **Seat limits now enforced at invite acceptance** — `acceptInvite` previously documented seat enforcement ("join time") but never called the billing adapter. It now counts the org's memberships and runs `billing.assertSeatAvailable(orgId, count)` before the single-use claim, so a full org never burns an invite it cannot honor.
- **`createBillingAdapter` guards invalid `MOCK_PLAN_SEATS`** — a non-numeric value previously produced a `NaN` seat limit that silently allowed unlimited joins; it now falls back to the default (3).

### Added
- **Service-level test suite** — 51 new tests across `tests/orgs-members.test.ts`, `tests/invites-seats.test.ts`, `tests/billing.test.ts`, `tests/audit.test.ts`, backed by an in-memory fake Supabase client (`tests/helpers/fake-supabase.ts`). No database or network needed; suite 24 → **75 tests**.
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

[0.2.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/verdantstack/sveltekit-supabase-starter/releases/tag/v0.1.0
