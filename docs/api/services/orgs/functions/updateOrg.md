[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: updateOrg()

> **updateOrg**(`supabase`, `orgId`, `userId`, `rawName`): `Promise`\<`void`\>

Fetch an org by its primary key.

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role, bypasses RLS — the caller is
  responsible for authorization).

### orgId

`string`

The org id to look up.

### userId

`string`

### rawName

`string`

## Returns

`Promise`\<`void`\>

The [Organization](../interfaces/Organization.md), or `null` when no such org exists.
