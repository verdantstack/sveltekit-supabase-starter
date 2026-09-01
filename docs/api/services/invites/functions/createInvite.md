[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createInvite()

> **createInvite**(`supabase`, `input`): `Promise`\<\{ `expiresAtMs`: `number`; `id`: `string`; `token`: `string`; \}\>

Create a new invite for an org.

The actor must hold `members.invite` and may only grant a role strictly
below their own rank. Only the SHA-256 hash of the token is persisted; the
raw token is returned to the caller exactly once. An `invite.created` audit
entry is written (without the token).

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role, bypasses RLS — authorize in
  the caller before invoking).

### input

The invite details — `orgId`, actor, optional scoped `email`,
  the `role` to grant, and an optional `ttlDays` override (defaults to
  [INVITE\_TTL\_MS](../variables/INVITE_TTL_MS.md)).

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

#### actorUserId

`string`

#### email?

`string`

#### orgId

`string`

#### role

`string`

#### ttlDays?

`number`

## Returns

`Promise`\<\{ `expiresAtMs`: `number`; `id`: `string`; `token`: `string`; \}\>

The created invite row id, the raw token (returned once, hash-only
  on disk), and the expiry as epoch milliseconds.

## Throws

RbacError with code `'bad_role'` when `role` is invalid, or
  `'hierarchy_violation'` when the actor cannot grant the role, or
  `'forbidden'` when the actor lacks `members.invite`.

## Throws

[InviteError](../classes/InviteError.md) with code `'bad_role'` when the insert fails.
