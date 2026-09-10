[**sveltekit-supabase-starter**](../../README.md)

***

# Function: listSessions()

> **listSessions**(`supabase`, `userId`): `Promise`\<`object`[]\>

List all active sessions for a user via Supabase Auth.

## Parameters

### supabase

`SupabaseClient`

A Supabase client with admin privileges.

### userId

`string`

The user id to list sessions for.

## Returns

`Promise`\<`object`[]\>

An array of session metadata; empty when the user has no sessions.
