# Testing

## Philosophy

Tests exercise the **service layer directly** with an in-memory **fake Supabase client** — no database, no network, no SvelteKit runtime. The fake implements the exact fluent query surface the services use (`.from().select().eq().is().gt().limit().single().order()`, `.insert().select().single()`, `.update()…select().single()`, `.delete()`), stores rows in plain JS maps, and lets tests inspect state and force errors.

This buys:

- **Speed and isolation** — every suite runs in milliseconds, no Supabase project needed.
- **Proof of the business rules** — hierarchy, single-use invites, seat gates — exactly where they live: in the services.
- **Honest boundaries** — RLS policies are *not* exercised by the unit suite; they need a real database.

## Running

```bash
npm install
npm test          # vitest run — whole suite
npm run check     # svelte-check (TypeScript validation)
npm run build     # production build
```

## Suite layout

| File | Coverage |
|------|----------|
| `tests/rbac.test.ts` | Matrix pinning, hierarchy helpers, typed errors |
| `tests/orgs-members.test.ts` | Org CRUD, membership management, role hierarchy, removal/leave/transfer |
| `tests/invites-seats.test.ts` | Invite lifecycle, atomic single-use claim, expiry/revoke, seat limits |
| `tests/billing.test.ts` | Mock adapter contract, seat boundaries, env override |
| `tests/audit.test.ts` | Append-only writer, metadata serialization |
| `tests/smoke.test.ts` | Build sanity, constants, adapter instantiation |
| `tests/helpers/fake-supabase.ts` | In-memory Supabase fake + fixture builders (shared, not a test) |

## Patterns

### Testing a service

Build a fresh fake client per test (`beforeEach`), seed users/orgs/memberships through the fake's tables, then call the service and assert on returned values, thrown error codes, and the fake's state:

```ts
const sb = createFakeSupabase();
seedUser(sb, { id: 'u1', email: 'owner@example.com', name: 'Owner' });
const org = await createOrg(sb as any, 'u1', 'Acme Inc.');
// assert org row + membership row + audit entry exist
```

Rejections are asserted by machine code:

```ts
await expect(setMemberRole(sb as any, { /* … */ })).rejects.toMatchObject({
	code: 'hierarchy_violation'
});
```

### Making the fake fail

`createFakeSupabase({ failNext: /\b(table|action)\b/ })` makes the next call against a matching table throw, so error branches (e.g. `org_insert` failures bubbling as `OrgError`) are covered without mocking libraries.

### Adding a new service action

1. Add the permission to `MATRIX` in `rbac.ts` if needed.
2. Create the service function in `src/lib/server/services/`.
3. Accept the Supabase client + `actorRole` as needed; call `requirePermission()` before any write.
4. Write the audit entry in the same service call.
5. Add tests in `tests/` using the fake client — happy path, every permission/flip rejection, and the audit entry.

## RLS-level testing (beyond the unit suite)

Application-level rules are fully unit-tested; the RLS policies in `supabase/migrations/0001_initial_schema.sql` are defense-in-depth and only run against real Postgres:

```bash
supabase start                          # local stack
supabase db reset                       # apply migrations
supabase test db                        # SQL-level tests (optional)
```

Verify at minimum: an anon/JWT client cannot read another org's rows, and that no UPDATE/DELETE policy exists on `audit_log`. These checks are the difference between "we wrote policies" and "the policies hold."

## Gotchas

- The services type their first parameter as `SupabaseClient`; tests cast the fake (`as any`) at the call site — the fake is intentionally untyped at the boundary.
- `audit()` logs loudly and **does not throw** on failure — assert on the fake's captured log when testing that branch.
- Invite tokens are hashed before storage (`sha256`); the fake stores the hash, so a test asserting "raw token never stored" greps the fake's `invites` rows for the raw token and expects no match.