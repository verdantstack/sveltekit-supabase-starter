[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: setMemberRole()

> **setMemberRole**(`supabase`, `input`): `Promise`\<`void`\>

Change a member's role.

Authority is re-derived inside the call: the actor must hold
`members.role.set`, act on a strictly lower-ranked target, and grant a role
strictly below their own. An `member.role_changed` audit entry is written.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### input

The operation context — `orgId`, the acting user and their role,
  the target user, and the role to grant.

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

#### actorUserId

`string`

#### orgId

`string`

#### role

`string`

#### targetUserId

`string`

## Returns

`Promise`\<`void`\>

Resolves on success.

## Throws

RbacError with code `'bad_role'` when `role` is not a valid
  [Role](../../../rbac/type-aliases/Role.md), or `'forbidden'` when the actor lacks `members.role.set`.

## Throws

[MemberError](../classes/MemberError.md) with code `'hierarchy_violation'` when the actor
  targets themself/peers or grants an invalid rank, `'no_membership'` when
  the target is not a member, or `'bad_role'` when the update fails.
