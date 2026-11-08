[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: listRegionChanges()

> **listRegionChanges**(`supabase`, `orgId`): `Promise`\<[`RegionMoveView`](../interfaces/RegionMoveView.md)[]\>

Every region change recorded for a tenant, newest first.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The organization id.

## Returns

`Promise`\<[`RegionMoveView`](../interfaces/RegionMoveView.md)[]\>

The move history; empty when the tenant has never asked to move.

## Throws

when the read fails — an unknown history must be visible, not
rendered as "this tenant never asked to move".
