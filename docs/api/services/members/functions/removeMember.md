[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: removeMember()

> **removeMember**(`supabase`, `input`): `Promise`\<`void`\>

Remove a member from an org.

Actor must hold `members.remove` and be strictly above the target. A
`member.removed` audit entry is written. Actors cannot remove themselves —
use [leaveOrg](leaveOrg.md).

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### input

The operation context — `orgId`, acting user/role, target user.

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

#### actorUserId

`string`

#### orgId

`string`

#### targetUserId

`string`

## Returns

`Promise`\<`void`\>

Resolves on success.

## Throws

RbacError with code `'forbidden'` when the actor lacks
  `members.remove`.

## Throws

[MemberError](../classes/MemberError.md) with code `'self_remove'` when the actor targets
  themself, `'no_membership'` when the target is not a member,
  `'hierarchy_violation'` when the actor cannot act on the target, or
  `'bad_role'` when the delete fails.
