[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: revokeInvite()

> **revokeInvite**(`supabase`, `input`): `Promise`\<`void`\>

Revoke a pending invite.

The actor must hold `invites.revoke`. A `invite.revoked` audit entry is
written. Revoking an invite that is already used, already revoked, or not
in the org fails the update gate and is an error.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### input

The operation context — `orgId`, acting user/role, and the
  `inviteId` to revoke.

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

#### actorUserId

`string`

#### inviteId

`string`

#### orgId

`string`

## Returns

`Promise`\<`void`\>

Resolves on success.

## Throws

RbacError with code `'forbidden'` when the actor lacks
  `invites.revoke`.

## Throws

[InviteError](../classes/InviteError.md) with code `'invalid_token'` when the invite is
  not found, already used, or already revoked.
