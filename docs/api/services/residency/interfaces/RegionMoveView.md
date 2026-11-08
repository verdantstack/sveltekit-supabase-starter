[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: RegionMoveView

A recorded region change, as read back for display.

## Properties

### cancelledAtMs

> **cancelledAtMs**: `number` \| `null`

When it was cancelled, or `null`.

***

### completedAtMs

> **completedAtMs**: `number` \| `null`

When it was applied, or `null` while it is still pending.

***

### fromRegion

> **fromRegion**: `string`

The region the tenant was in when the move was requested.

***

### id

> **id**: `string`

The move's id.

***

### justification

> **justification**: `string` \| `null`

The operator-facing reason recorded with the request, or `null`.

***

### requestedAtMs

> **requestedAtMs**: `number`

When it was requested.

***

### requestedByUserId

> **requestedByUserId**: `string`

Who asked for it.

***

### status

> **status**: `string`

`'requested' | 'completed' | 'cancelled'`.

***

### toRegion

> **toRegion**: `string`

The region that was requested.
