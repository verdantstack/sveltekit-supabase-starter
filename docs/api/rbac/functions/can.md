[**sveltekit-supabase-starter**](../../README.md)

***

# Function: can()

> **can**(`role`, `permission`): `boolean`

Whether a role holds a given [Permission](../type-aliases/Permission.md) per the capability matrix.

## Parameters

### role

`"owner"` | `"admin"` | `"member"`

### permission

`"org.view"` | `"org.update"` | `"org.delete"` | `"members.view"` | `"members.invite"` | `"members.remove"` | `"members.role.set"` | `"invites.revoke"` | `"audit.view"` | `"billing.manage"` | `"ownership.transfer"`

## Returns

`boolean`

`true` when the role is granted the permission, else `false`.

## Remarks

This is a static lookup — it does not consult membership or tenant
  state. Pair it with [mayActOn](mayActOn.md)/[mayGrant](mayGrant.md) for full authority
  checks, or with [requirePermission](requirePermission.md) for a throwing guard.
