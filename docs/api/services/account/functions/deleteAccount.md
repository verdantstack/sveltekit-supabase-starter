[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: deleteAccount()

> **deleteAccount**(`supabase`, `input`): `Promise`\<\{ `email`: `string`; `userId`: `string`; \}\>

Delete the account that owns `accessToken`, and record it.

## Parameters

### supabase

`SupabaseClient`

A Supabase **service-role** client. The user is resolved from
  the token inside this function; the admin delete needs the service role
  because a user may not delete themselves through the Data API.

### input

#### accessToken

`string` \| `null` \| `undefined`

The caller's Supabase access token, from
  `event.locals.accessToken`. Never a user id.

## Returns

`Promise`\<\{ `email`: `string`; `userId`: `string`; \}\>

The deleted user's id and email (the route does not need to read
  them anywhere else; a caller that wants to confirm *who* went needs both).

## Throws

[AccountError](../classes/AccountError.md) `unauthorized` when no token was supplied or the
  token does not resolve to a live user; `delete_failed` when the delete itself
  was refused.
