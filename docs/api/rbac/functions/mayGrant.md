[**sveltekit-supabase-starter**](../../README.md)

***

# Function: mayGrant()

> **mayGrant**(`actor`, `granted`): `boolean`

Whether an actor may grant a role to someone else.

The granted role must be strictly below the actor's rank; no self or equal
grants are permitted.

## Parameters

### actor

`"owner"` | `"admin"` | `"member"`

### granted

`"owner"` | `"admin"` | `"member"`

## Returns

`boolean`

`true` when `RANK[actor] > RANK[granted]`.
