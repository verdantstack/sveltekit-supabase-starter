# Architecture

## Layering

```mermaid
graph TD
    subgraph ROUTES["🖥️ Routes (you wire these)"]
        R["+page.server.ts<br/>parse form → call service → fail/redirect"]
    end

    subgraph SERVICES["⚙️ Services"]
        S["orgs · members · invites<br/>domain logic · pure functions<br/>Supabase client passed in"]
    end

    subgraph POLICY["🛡️ Policy & Seams"]
        RBAC["rbac.ts<br/>role hierarchy · permissions"]
        BILLING["billing/<br/>BillingAdapter interface"]
    end

    subgraph INFRA["🗄️ Infrastructure"]
        SB["supabase/client.ts<br/>service-role (admin, bypasses RLS)<br/>user-scoped (RLS enforced)"]
    end

    subgraph SUPABASE["☁️ Supabase"]
        AUTH["Supabase Auth<br/>email · OAuth · magic links"]
        DB["PostgreSQL<br/>RLS policies"]
        AUTH -.-> DB
    end

    R -->|"call service"| S
    S -->|"requirePermission()"| RBAC
    S -->|"assertSeatAvailable()"| BILLING
    S -->|"query/mutate"| SB
    SB -->|"service-role"| DB
    SB -->|"user-scoped"| DB
    R -.->|"auth login"| AUTH

    classDef route fill:#e3f2fd,stroke:#1565c0,color:#0d47a1
    classDef service fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20
    classDef policy fill:#fff3e0,stroke:#ef6c00,color:#e65100
    classDef infra fill:#f3e5f5,stroke:#7b1fa2,color:#4a148c
    classDef supa fill:#fce4ec,stroke:#c62828,color:#b71c1c

    class R route
    class S service
    class RBAC,BILLING policy
    class SB infra
    class AUTH,DB supa
```

Rules:

1. **Routes never touch the database directly** — all writes go through a service so audit entries and permission checks can't be skipped.
2. **Services are framework-free** — they import nothing from `@sveltejs/kit`. That's what makes them unit-testable against an in-memory fake Supabase client with no runtime and no database.
3. **Every mutating service call re-derives authority from arguments**: callers pass `actorRole`, fetched fresh inside the same request. No trust in client-submitted role fields.
4. **Errors carry machine codes** (`AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`). Map them to HTTP responses in exactly one place per app (the route layer).

## Concurrency notes

- **Single-use invites** don't rely on read-then-write. Acceptance performs an `UPDATE` whose `WHERE` clause is the concurrency gate (`.eq('id', id).is('accepted_at', null).is('revoked_at', null)`), then reads back the claimed row. Zero rows claimed = someone got there first. Safe under concurrent clicks without explicit transactions.
- **Seat counting** is a `COUNT` over memberships performed inside `acceptInvite` before the single-use claim, so a full org never claims an invite it can't honor.

## Sessions & auth

- Authentication is **Supabase Auth** (email+password, magic links, OAuth). Sessions live in Supabase, not your database.
- Service-side operations use the **service-role client** (`createServerClient`) to bypass RLS for admin writes (audit entries, seat checks).
- User-scoped operations use `createUserClient(accessToken)` so RLS applies to that user's rows.
- Never hand a service-role client to the browser. `PRIVATE_*` env vars are server-only.

## RBAC + RLS (defense in depth)

```mermaid
flowchart TD
    REQ["Request<br/>(user identity)"] --> APP_LAYER

    subgraph APP_LAYER["Application Layer (RBAC)"]
        ROLE["requireRole()<br/>re-read membership from DB"]
        PERM["requirePermission()<br/>check MATRIX + hierarchy"]
        ROLE --> PERM
    end

    APP_LAYER -->|"✅ allowed"| RLS_LAYER

    subgraph RLS_LAYER["Database Layer (Supabase RLS)"]
        POLICY["is_org_member(org_id, auth.uid())<br/>+ membership role check"]
    end

    RLS_LAYER -->|"✅ policy passes"| WRITE["Write to DB"]
    RLS_LAYER -->|"❌ policy blocks"| ERR_RLS["403 — RLS blocked"]
    APP_LAYER -->|"❌ permission denied"| ERR_APP["403 — hierarchy violation"]

    classDef app fill:#e3f2fd,stroke:#1565c0
    classDef rls fill:#f3e5f5,stroke:#7b1fa2
    classDef ok fill:#e8f5e9,stroke:#2e7d32
    classDef err fill:#ffcdd2,stroke:#c62828

    class APP_LAYER app
    class RLS_LAYER rls
    class WRITE ok
    class ERR_APP,ERR_RLS err
```

- **Application code enforces RBAC** on every mutating call (`requirePermission()` + hierarchy checks in `members.ts` / `invites.ts`).
- **RLS enforces tenant isolation** at the database level (`is_org_member`, `get_org_role`, `has_min_role` helpers in the migration): a user can only see organizations they belong to, and only owners/admins can mutate membership and invite rows.
- The two layers verify each other: app-level tests prove the business rules; a locally running Supabase (`supabase start`) proves the policies. See `docs/testing.md`.

## Audit design

`audit_log.org_id`/`actor_user_id` are plain columns (no FK) so history survives member removal and (future) org deletion. Metadata is a JSON string; writers decide what goes in. The raw invite token is never audited. There is **no UPDATE or DELETE policy** on `audit_log` — append-only by construction at both the schema and the application layer.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `PUBLIC_SUPABASE_URL` | Your Supabase project URL (shared with the browser) |
| `PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key (shared with the browser) |
| `PRIVATE_SUPABASE_URL` | Supabase project URL — **server only** |
| `PRIVATE_SUPABASE_ANON_KEY` | Supabase anon key — **server only** (user-scoped clients) |
| `PRIVATE_SUPABASE_SERVICE_ROLE_KEY` | Service-role key — **server only**, bypasses RLS |
| `MOCK_PLAN_SEATS` | Seat limit for `MockBillingAdapter` (default 3) |

## Swapping the billing provider

All payment knowledge sits behind `BillingAdapter` (`docs/billing.md`). Swapping the merchant of record changes one wiring function — no service or route changes.

## Deliberate limits

- `acceptInvite` counts seats via the passed `billing` adapter; the shipped mock enforces `MOCK_PLAN_SEATS`. A real adapter must read seats from a `subscriptions` table updated by webhooks.
- Invite links work for whoever holds them; the optional `email` field is a human note, not enforcement. Email-enforced invites need email delivery, which needs an account (out of scope).
- RLS policies are shipped in the migration but are only fully exercised when you run a real Supabase instance (`supabase start`) — the unit suite tests application-level enforcement with a fake client.