# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-11-08

## [0.4.5] - 2026-11-08

### Added

- **Data residency: a home region per tenant, and a policy per region that the
  code actually enforces.** An organization is created into one of four regions,
  and that region's policy decides what the app refuses to do with its data —
  export across a border, register a webhook, keep an event past a retention
  window. The catalogue is frozen code (`src/lib/server/regions.ts`), not a table:
  a row a tenant could choose, or a migration that could insert one, would let a
  tenant pick a jurisdiction the operator does not run.

  | Code             | Status | DPA required | Cross-border export | Webhook egress | Exports pseudonymised | Audit / invite / DSAR days |
  | ---------------- | ------ | :----------: | :-----------------: | :------------: | :-------------------: | :------------------------: |
  | `us-east-1`      | active |      no      |       allowed       |    allowed     |          no           |       1095 / 30 / 45       |
  | `eu-west-1`      | active |   **yes**    |     **refused**     |  **refused**   |        **yes**        |       730 / 14 / 30        |
  | `ap-southeast-1` | active |   **yes**    |     **refused**     |    allowed     |        **yes**        |       365 / 14 / 30        |
  | `ap-southeast-2` | pilot  |     yes      |       refused       |    refused     |          no           |       2555 / 14 / 30       |

  Every knob is consumed by a call site, which is the only reason to ship it:
  creating a tenant (`region_not_accepting`, `dpa_required`, `unknown_region`),
  registering a webhook (`egress_blocked`, 403), exporting the audit log
  (`cross_border_blocked`, 403, plus pseudonymised actor ids), and changing the
  region (owner-requested, then completed or cancelled, always recorded).

  `ap-southeast-1` is the row that proves this is not "strict vs permissive": it
  requires a DPA and pseudonymises exports, yet permits webhook egress.
  `ap-southeast-2` ships as a pilot so one behaviour is visible: a region that is
  not accepting new tenants still serves the ones already in it, and refuses an
  in-flight move into it at completion time — which is why the target is
  re-validated when the move is applied, not only when it is requested.

- **The tenant's region cannot move silently.** `organizations.region_code` is
  written once, by `createOrg`; afterwards the only writer is
  `completeRegionChange`, against an open request an owner made. `updateOrg` — the
  ordinary rename path — is asserted not to touch it, because that is how a future
  edit would re-home a tenant by accident. The `region_moves` row is kept after
  cancellation rather than deleted: "who asked to move us, and why did it not
  happen?" is a question an operator gets asked afterwards.

- **`supabase/migrations/0003_residency.sql`** adds
  `organizations.region_code` (`TEXT NOT NULL DEFAULT 'us-east-1'`, `CHECK` against
  the catalogue) and `organizations.dpa_accepted_at` (`TIMESTAMPTZ`, nullable), and
  creates `region_moves` with RLS (members read, owners write, no `DELETE` policy)
  and its Data API grants **in the same file**, because from 2026-10-30 a table
  created without them answers every request with `42501`. A partial unique index —
  `UNIQUE (org_id) WHERE status = 'requested'` — makes "at most one open request"
  true under concurrency, not just under the service's read-then-write.

- **RBAC:** `org.region.view` is granted to **every** role (where a member's data is
  processed is a fact about their data, not an administrative detail);
  `org.region.move` is owner-only, because it commits everyone else's data to a
  different legal regime. `PERMISSIONS` is now 13 entries; the two suites that pin
  the list and its length are updated.

- **UI:** a region select and a DPA checkbox on the `/app` create-organization
  form, a "Data residency" link on the org layout for every role, and
  `/app/org/[id]/region` — region, policy, data-class counts, retention posture,
  the pending move, the full change history, and the owner-only request form. The
  page reads through the RLS-scoped client; writes stay on the service role, with
  `actorRole` re-derived on every action.

- **`docs/residency.md`**, including what the feature deliberately does **not** do
  (§9), and a §5 that states plainly where the absence of a transaction is handled
  by ordering instead.

### Changed

- **`http.ts` now maps only registered codes.** It answered `400` to _any_ object
  carrying a `code` and a `message`, so a Postgres privilege error arrived in a
  browser as a 400 whose body was `42501 permission denied for table …` — schema
  detail, framed as the user's mistake. The mapper is now a registry
  (`CODE_STATUS`), and anything unregistered is a logged, generic 500.
  `bad_default_region` is deliberately **not** registered: it means
  `REGION_DEFAULT` names a region this deployment does not run, which the user
  cannot fix. `unknown_region`, `region_not_accepting`, `dpa_required`,
  `same_region`, `move_pending` and `no_pending_move` are 400;
  `egress_blocked` and `cross_border_blocked` are 403; `unauthorized` is 401.

- **The audit export is region-aware.** `/app/org/[id]/audit/export` gained a
  `destination` parameter, refuses a cross-border destination with a real 403, and
  pseudonymises actor ids where the tenant's policy requires it
  (`psn_` + 32 hex of `sha256("residency:<region>:<userId>")`, stable per
  region+user, so two exports still correlate). It also sends
  `x-residency-pseudonymized: true|false`, because a named file and a pseudonymised
  one are both full of ids and a recipient should not have to guess.
  `audit.ts` grew `auditRowsToCsv`/`auditRowsToJson` so the transformed export uses
  the one CSV writer — and therefore the one formula-injection guard.

- **`createWebhook` now consults the tenant's region.** Registration is the moment
  the operator can still say no; delivery time is too late. A tenant that does not
  exist fails closed (`not_found`) rather than being assumed permissive.

### Fixed

- **Account deletion no longer happens in the route.** `/app/delete-account` called
  `supabase.auth.admin.deleteUser(locals.user!.id)` from its page action — rule 1
  broken in the one place where a mistake is unrecoverable, with the most
  destructive operation in the product sitting at the edge of the app. It is now
  `services/account.ts:deleteAccount(supabase, { accessToken })`: the identity is
  resolved **from the session token** by asking Supabase Auth who it belongs to
  (never from anything the request body can set), the deletion writes an
  `account.deleted` audit row, and the route keeps its redirect to `/?deleted=1`.
  A failed delete answers a logged 500 rather than a 400 carrying the vendor's
  message. `tests/account-deletion.test.ts` pins all of it, including a source
  scan that fails if the route ever imports the admin API again.

### Tests

743 tests across 27 suites (`it(` occurrences; one is skipped because it needs
live Supabase credentials). Coverage 99.2% statements / 96.4% branches / 99.5%
functions / 99.7% lines, above the 95% floor enforced by `vitest.config.ts`.
`svelte-check` clean, production build clean.

## [0.4.4] - 2026-10-27

## [0.4.3] - 2026-10-27

### Changed

- Version bump to 0.4.3.

### Added

- Service-layer parity: sessions, password reset, email verification, files,
  webhooks, notifications, API keys, audit retention, impersonation, blog,
  affiliates, usage billing, waitlist, MFA, and OAuth now ship across all three
  kits.
- `/signup` route, delegating to a single shared implementation.

### Fixed

- Supabase grant matrix: tables now grant privileges explicitly instead of
  relying on automatic grants removed 2026-10-30.
- Demo-path segment resolved at runtime, not shipped as a codename.
- Seat-count decision site consolidated to one location.
- Real concurrency guard added to seat-limit enforcement.
- Export parity across kits.

## [0.4.2] - 2026-10-21

### Fixed

- **A fresh install would have returned `42501 permission denied` on every
  table from 2026-10-30.** Supabase is ending the automatic Data API grants for
  tables newly created in the `public` schema — the new default applies to
  **existing** projects as well as new ones on that date — so a table is
  reachable by PostgREST only if an explicit `GRANT` exists. Without one, every
  request for the table fails with
  `42501 permission denied for table <name>`, even though the table exists, its
  RLS policies are correct and the keys are valid. This kit creates its tables
  only from `supabase/migrations/`, which `supabase db push`, `supabase db reset`
  and every preview branch all run, so all three install paths were affected.
  `0001_initial_schema.sql` now grants `organizations`, `memberships`, `invites`
  and `audit_log`, and `0002_users_profile.sql` grants `users`, each in the file
  that creates the table:

  | Role            | Privileges                       |
  | --------------- | -------------------------------- |
  | `anon`          | `SELECT`                         |
  | `authenticated` | `SELECT, INSERT, UPDATE, DELETE` |
  | `service_role`  | `SELECT, INSERT, UPDATE, DELETE` |

  The matrix mirrors Supabase's documented default for new tables, so behaviour
  after the change matches behaviour before it — no application code changed.
  `0002` creates `public.users` with `IF NOT EXISTS`, and `GRANT` is idempotent,
  so the same statements are correct both on a clean install and on a project
  where the table already existed. `service_role` is included deliberately:
  bypassing RLS is not bypassing the privilege system, and this kit's admin
  writes run as `service_role`. `audit_log` remains append-only — that guarantee
  is the absence of an UPDATE/DELETE _policy_, not the absence of a privilege, so
  granting the vendor matrix does not weaken it.

  **Tables created before 2026-10-30 keep the grants they already hold.** This
  affects newly created tables only, which is why the grants belong to the
  migration and not to a one-time dashboard step. Existing installations need no
  action.

  `tests/schema-contract.test.ts` now enforces the grants statically, in the
  same test that checks the queried relations exist: it parses every migration
  and fails naming the file, table, role and missing privilege if a created table
  is not granted in that same file, and fails if a write privilege is ever
  granted to `anon`. Deleting any single `GRANT` line turns the suite red.
  Documented in README.md ("Supabase setup", "Schema verification"), AGENTS.md
  ("Database (Supabase)") and `docs/deployment.md` (§2).

## [0.4.1] - 2026-10-12

## [0.4.0] - 2026-10-12

### Fixed

- **The "single seat-enforcement point" was two.** `billing/service.ts::assertSeatAvailable`
  was introduced as the one place seat limits are enforced, but it delegated the
  decision to `BillingAdapter.assertSeatAvailable`, so the policy still lived in
  two places — and the two had drifted: the adapter compared its constructor's
  `seatLimit` against a _caller-supplied_ member count while the service compared
  `state.planSeats` against the _real_ membership count, and only the service
  treated `status: 'none'` as blocking. `assertSeatAvailable` is removed from the
  `BillingAdapter` interface and from `MockBillingAdapter`; the adapter is now a
  pure reporting seam (`getSubscriptionState`, `getPlan`, `getSeatCount`) and
  `billing/service.ts` owns the whole decision. A reporting seam cannot drift
  from a policy.
  A real merchant-of-record adapter is still consulted — `getSubscriptionState()`
  is where it calls the provider — so a provider outage throws from there and
  propagates unchanged, and because the check runs before the invite claim, a
  failed check still never burns an invite. `tests/billing.test.ts`,
  `tests/billing-edge-cases.test.ts`, `tests/smoke.test.ts` and
  `tests/smoke-extended.test.ts` were converted to assert what the adapter
  _reports_; the seat decisions they used to make are covered in
  `tests/billing-service.test.ts` (2-of-3 allowed, 3-of-3 blocked,
  none/past_due/canceled → `subscription_required`, provider error propagates).
- **Org route actions returned HTTP 200 for RBAC violations.** Every action in
  `src/routes/app/org/[id]/+page.server.ts` mapped a caught domain error through
  a local `toFail(e)` that returned a bare `{ error: e.message }`. A SvelteKit
  form action returning a plain object is **200 OK**, so a member POSTing a
  forged "promote the owner" request — the exact scenario the README claimed
  answers 403 — received `200 OK` with an error string in the body. The write was
  always blocked server-side, but the response said nothing about it: no client,
  proxy, monitoring dashboard or security test could distinguish a denial from a
  success. Added `src/lib/server/http.ts::errorToFail` (`forbidden`,
  `hierarchy_violation`, `no_membership` → 403; `not_found` → 404; other known
  domain errors → 400; unknown → generic 500) and replaced all six call sites.
  `errorToFail` re-throws anything carrying `location`, so SvelteKit's
  `redirect()` is never swallowed — otherwise a successful action whose side
  effects had already committed would be reported as a 500. `tests/http.test.ts`
  pins the mapping; `tests/http-status.test.ts` drives the real route actions and
  asserts `result.status`.
- **`listMembers()` joined a table the schema never created.** It embeds
  `users!inner(id, email, name)`, but `0001_initial_schema.sql` creates only
  `organizations`, `memberships`, `invites` and `audit_log`; real users live in
  `auth.users`. On a clean-room install the embed could not resolve, so
  `listMembers()` threw and **the whole org dashboard failed to load** — the page
  that lists members, seats and invite controls. The test suite never caught it
  because `tests/helpers/fake-supabase.ts` provisions a `users` table the deployed
  schema never had: the fake was more permissive than reality. Added
  `supabase/migrations/0002_users_profile.sql` (additive, idempotent) creating the
  `public.users` profile mirror, syncing it from `auth.users` by trigger, and
  adding the `memberships.user_id → users(id)` foreign key PostgREST needs to
  plan the embed. Added `tests/schema-contract.test.ts`, which cross-checks every
  relation the server queries against the migrations — including the foreign key,
  since a table without a relationship still breaks the embed with a different
  error and a table-existence-only check would pass while the feature stayed
  broken.
- **Unbounded slug-collision retry in `createOrg`.** A unique-constraint collision
  on the org slug recursed into `createOrg` with no attempt budget, so a slug
  space that could not produce a free value turned one request into an endless
  loop. Retries are now capped at 5 and an exhausted budget throws the typed
  `OrgError('slug_taken')` — a code that was declared and documented in the type
  union but previously had no code path that could produce it.
- **`billing/index.ts` re-reads `MOCK_PLAN_SEATS` per call.** A module-level
  singleton would freeze whatever the environment held at import time, silently
  breaking the documented env override.

### Changed

- **Tenant-scoped reads now run through the RLS-enforcing client.** Every call
  site previously used `createServerClient()` (service role, bypasses RLS);
  `createUserClient()` had **zero** call sites and `locals.accessToken`, set in
  `hooks.server.ts`, was never read. The RLS policies shipped but never executed
  at runtime. Listing orgs, loading an org, listing members, listing pending
  invites, the audit page, the audit count and the audit export now use
  `tenant.ts::requireTenantClient(locals.accessToken)`. Writes deliberately stay
  on the service role, for reasons documented in `tenant.ts`: `audit_insert` is
  `WITH CHECK (true)` (a user-scoped write would let any authenticated user forge
  audit rows in any org); `memberships_update`/`memberships_delete` require
  `owner` while `MATRIX` grants `members.role.set`/`members.remove` to `admin`;
  and `peekInvite` runs for signed-out visitors. `tests/tenant-client.test.ts`
  pins the split.
- **Seat enforcement is single-sourced.** Seat counting and the limit decision
  lived inline in `services/invites.ts` alongside the adapter's own guard. Added
  `src/lib/server/billing/service.ts` (`countActiveSeats`, `assertSeatAvailable`)
  plus a `billing/index.ts` barrel; `acceptInvite` now calls the service, which
  also covers the `none` subscription state the mock adapter never reports.
- Docs reconciled with measured behaviour (Rule 7): the README's "real HTTP 403"
  claim now states what is enforced and how it is proven, and the RLS sections
  state the read/write split instead of implying blanket database-level RLS.

### Added

- Audit export hardening: `MAX_EXPORT_ROWS` (10 000) and `clampExportPage()`
  (floors `limit` at 1, caps it at the ceiling, floors `offset` at 0), an `offset`
  parameter on `listAuditEntries`/`exportAuditCsv`/`exportAuditJson`, and a
  spreadsheet-formula guard that prefixes a leading `=`, `+`, `-`, `@`, TAB or CR
  with an apostrophe. The guard runs on the **raw** value, before CSV quoting:
  quoting first leaves the field starting with a double quote, which matches no
  formula trigger, so the canonical `=HYPERLINK("…")` payload — which necessarily
  contains a quote — would pass through un-neutralised. A test pins that exact
  payload and fails if the two steps are swapped.
  In this schema the guard is defence-in-depth rather than a live hole:
  `action`/`targetType`/`targetId` are app-written constants and `actorUserId` is
  a UUID, so no cell can begin with `=` today. It is there for a buyer who adds a
  free-form field.
- Audit-log CSV and JSON export at `GET /app/org/[id]/audit/export` — 401
  unauthenticated, 403 non-privileged, 404 non-member, with `Content-Disposition`,
  `Cache-Control: no-store` and an `audit.exported` entry recording format and
  row count (never the payload).
- `countAudit()`, `exportAuditCsv()` and `exportAuditJson()` in
  `src/lib/server/audit.ts`. CSV escaping round-trips commas, quotes and
  newlines; values are left verbatim rather than prefixed, because prefixing
  mutates them and the export would no longer mirror the database.
- `src/lib/server/billing/service.ts` and `src/lib/server/billing/index.ts`.
- `.range(from, to)` support in the in-memory fake Supabase client, so paging is
  exercised rather than assumed.
- SvelteKit virtual-module stubs (`tests/helpers/stubs/`) and aliases in
  `vitest.config.ts`, so tests can import real route modules and assert real HTTP
  statuses instead of re-implementing route logic.

### Known issues

- **A clean-room install of the previously published source is broken on the org
  dashboard**, because it ships `0001` without the `users` relation that
  `listMembers()` embeds. Applying `0002_users_profile.sql` fixes it. Verified
  against a real Postgres 16: both migrations apply cleanly, `0002` is idempotent
  on re-application, the trigger populates and re-syncs `public.users`, and the
  new RLS policies were exercised with a non-owner role (a user saw themselves
  and same-org peers, not a user in another org; a self-update was allowed while a
  change of `id` was rejected by the `WITH CHECK`). Not verified against a live
  Supabase project: there is no Supabase Auth issuing JWTs in that harness, so
  PostgREST-level embed behaviour is unproven.
- `memberships_update` / `memberships_delete` require `owner` while `MATRIX` grants
  `members.role.set` / `members.remove` to `admin`. Documented rather than
  resolved — resolving it is a product decision, and closing it by weakening a
  policy was out of scope.

## [0.3.4] - 2026-10-04

## [0.3.3] - 2026-10-04

## [0.3.2] - 2026-10-02

### Fixed

- README version claim. The `**Version**` line, the version badge and the
  machine-readable `version:` field all still read `0.3.1`'s predecessor after the
  previous release, so the published proof repo stated a version that did not match
  its own release tag. All three forms now track `package.json`.

## [0.3.1] - 2026-10-02

### Added

- `src/lib/server/mcp/` — an MCP server exposing the service layer to a coding
  agent over stdio. Four read tools: `list_orgs`, `list_members`,
  `list_pending_invites` and `list_audit_log`, all backed by the same services
  the app uses, all taking a `SupabaseClient`.

  - **Read-only by design.** These tools are called by a language model, and a
    model can be steered into calling them by text it has just read — a prompt
    injection hidden in an audit-log string could otherwise reach a mutating
    call. Reads cannot destroy state, so reads are the first surface exposed.
  - **No SDK.** MCP over stdio is JSON-RPC 2.0. Implementing it keeps this
    feature dependency-free and shows the protocol rather than hiding it.
  - **Both protocol shapes.** The 2026-07-28 revision dropped the mandatory
    `initialize` handshake for a stateless core carrying `protocolVersion` in
    `_meta`; older clients still open with `initialize`. The server accepts
    both and names the versions it implements when asked for one it does not.
  - **Tool failures are results, not protocol errors** (`isError: true` with a
    readable message), so a model can correct its call and retry.
  - `npm run mcp` starts it. Credentials come from whatever the app already
    uses — no new environment variables.
  - Lives inside `src/lib/server/`, so it counts toward the coverage
    threshold. The module is at 100% statement, branch, function and line
    coverage; `cli.ts` is excluded with the reason recorded in
    `vitest.config.ts`, and the transport is covered in-process.
  - The stdio transport is serialised deliberately: replies go out in the
    order requests were read, so a client never gets two responses swapped.

- `tests/mcp.test.ts` — protocol, tool and transport coverage. Test count
  359 → 390.

## [0.3.0] - 2026-10-02

### Added

- **Shipped application UI** (`src/routes`): signup, sign-in, organizations, org workspace (members, invites, role changes, ownership transfer, leave), invite-link accept flow, and an audit-log view — all themed, wired to the existing services, and enforcing the RBAC matrix server-side on every action.
- **Session cookie auth** (`src/hooks.server.ts` + `createAnonClient`/`signIn`/`setSessionCookie`/`clearSessionCookie` in `src/lib/server/supabase/client.ts`): the `session` cookie holds the Supabase refresh token; `hooks.server.ts` resolves `locals.user`/`locals.accessToken` per request with automatic rotation; sign-out revokes sessions server-side ("log out everywhere", `destroyAllSessions`).
- **Audit reader** — `listAuditEntries` in `src/lib/server/audit.ts`: companion to the append-only writer, newest-first with a limit (used by the audit-log route). 4 new tests.
- `/api/health` route: liveness + Supabase reachability check for deployments.

### Fixed

- Made `npm run check` green for the first time (kit previously failed svelte-check): orgs join-row typing, `listUserSessions` typing gap on the installed Supabase client, `vite.config.ts` `defineConfig` import, `ThrowingAdapter`/`GenericThrowingAdapter` override signatures in `tests/billing-edge-cases.test.ts` (now 314 tests total, ≥ 95 % coverage maintained).

### Docs

- Screenshot gallery refreshed — every capture re-taken from the themed live demo (org dashboard, landing, RBAC denial GIF, the 314-test run).

## [0.2.5] - 2026-09-13

### Docs

- Suite tables completed to match the shipped 12 test files: `AGENTS.md`, `docs/testing.md`, and README status now list every suite (added `auth`, `billing-edge-cases`, `rbac-boundary`, `service-integration`, `edge-cases`, `smoke-extended`) with per-file coverage notes (310 tests total).

## [0.2.4] - 2026-09-10

### Tests

- 310 tests (was 208): +102 new tests covering e2e billing flows (seat upgrades/downgrades, adapter failures, boundary conditions), RBAC boundary cases (cross-org isolation, rank escalation, hierarchy enforcement), full multi-step service-integration flows, and auth edge cases.

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

[0.5.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.4.5...v0.5.0
[0.4.4]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.4.3...v0.4.4
[0.4.2]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.3.4...v0.4.0
[0.3.4]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.3.3...v0.3.3
[0.3.2]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.3.1...v0.3.3
[0.3.1]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.3.0...v0.3.0
[0.3.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.5...v0.3.0
[0.2.5]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.2...v0.2.3
[0.2.1]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/verdantstack/sveltekit-supabase-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/verdantstack/sveltekit-supabase-starter/releases/tag/v0.1.0
