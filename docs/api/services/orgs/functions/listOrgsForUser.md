[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: listOrgsForUser()

> **listOrgsForUser**(`supabase`, `userId`): `Promise`\<[`Organization`](../interfaces/Organization.md) & `object`[]\>

List every org a user belongs to, along with their role in each.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### userId

`string`

The user whose memberships to list.

## Returns

`Promise`\<[`Organization`](../interfaces/Organization.md) & `object`[]\>

An array of [Organization](../interfaces/Organization.md) rows decorated with the user's
  `role`; empty when the user belongs to no orgs.

## Throws

[OrgError](../classes/OrgError.md) with code `'not_found'` when the query fails.
