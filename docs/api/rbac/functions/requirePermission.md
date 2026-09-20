[**sveltekit-supabase-starter**](../../README.md)

***

# Function: requirePermission()

> **requirePermission**(`role`, `permission`): `void`

Guard that throws unless the role holds the given permission.

## Parameters

### role

The role to check; `null`/`undefined` represents an unauthenticated
  or non-member caller and is always rejected.

`"owner"` | `"admin"` | `"member"` | `null` | `undefined`

### permission

The permission to require.

`"org.view"` | `"org.update"` | `"org.delete"` | `"members.view"` | `"members.invite"` | `"members.remove"` | `"members.role.set"` | `"invites.revoke"` | `"audit.view"` | `"billing.manage"` | `"ownership.transfer"`

## Returns

`void`

## Throws

[RbacError](../classes/RbacError.md) with code `'forbidden'` when the role is absent or
  does not hold the permission.
