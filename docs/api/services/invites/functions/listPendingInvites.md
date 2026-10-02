[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: listPendingInvites()

> **listPendingInvites**(`supabase`, `orgId`): `Promise`\<`object`[]\>

List the pending invites for an org (not accepted, not revoked, not expired).

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The org whose invites to list.

## Returns

`Promise`\<`object`[]\>

An array of pending invites with role, optional email, and epoch-millisecond
  timestamps.

## Throws

[InviteError](../classes/InviteError.md) with code `'invalid_token'` when the query fails.
