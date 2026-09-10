[**sveltekit-supabase-starter**](../../README.md)

***

# Function: mayActOn()

> **mayActOn**(`actor`, `target`): `boolean`

Whether an actor may act on a target by rank.

Actors may act on targets strictly below their own rank; acting on a peer
or a higher-ranked user is always denied, by design.

## Parameters

### actor

`"owner"` | `"admin"` | `"member"`

### target

`"owner"` | `"admin"` | `"member"`

## Returns

`boolean`

`true` when `RANK[actor] > RANK[target]`.
