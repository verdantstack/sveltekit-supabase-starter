[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: countActiveSeats()

> **countActiveSeats**(`supabase`, `orgId`): `Promise`\<`number`\>

Count the memberships (seats) currently used by an organization.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The organization id.

## Returns

`Promise`\<`number`\>

The number of active members; `0` when the client returns a null
  payload without an error (the defensive path the rest of the services keep).

## Throws

with code `adapter_error` when the count query fails —
  an unknown seat count must never be read as "there is room".
