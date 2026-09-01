[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createOrg()

> **createOrg**(`supabase`, `userId`, `rawName`): `Promise`\<[`Organization`](../interfaces/Organization.md)\>

Create a new organization and add its creator as the `owner` member.

The slug is derived from the name with a random suffix and retried on
unique-constraint collisions. The creator is added as the sole owner and an
`org.created` audit entry is written.

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role, bypasses RLS — authorize in
  the caller before invoking).

### userId

`string`

The id of the creator; becomes the founding `owner`.

### rawName

`string`

The proposed organization name; trimmed and validated to
  2–80 characters.

## Returns

`Promise`\<[`Organization`](../interfaces/Organization.md)\>

The created [Organization](../interfaces/Organization.md).

## Throws

[OrgError](../classes/OrgError.md) with code `'bad_name'` when the name is empty/out
  of range or a database write fails.
