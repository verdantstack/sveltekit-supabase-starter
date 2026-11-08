[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: getOrgBySlug()

> **getOrgBySlug**(`supabase`, `slug`): `Promise`\<[`Organization`](../interfaces/Organization.md) \| `null`\>

Fetch an org by its unique slug.

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role, bypasses RLS — the caller is
  responsible for authorization).

### slug

`string`

The org slug to look up.

## Returns

`Promise`\<[`Organization`](../interfaces/Organization.md) \| `null`\>

The [Organization](../interfaces/Organization.md), or `null` when no such org exists.
