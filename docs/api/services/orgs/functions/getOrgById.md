[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: getOrgById()

> **getOrgById**(`supabase`, `orgId`): `Promise`\<[`Organization`](../interfaces/Organization.md) \| `null`\>

Fetch an org by its primary key.

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role, bypasses RLS — the caller is
  responsible for authorization).

### orgId

`string`

The org id to look up.

## Returns

`Promise`\<[`Organization`](../interfaces/Organization.md) \| `null`\>

The [Organization](../interfaces/Organization.md), or `null` when no such org exists.
