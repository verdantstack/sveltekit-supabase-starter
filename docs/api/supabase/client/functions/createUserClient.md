[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createUserClient()

> **createUserClient**(`accessToken`): `SupabaseClient`

Create a Supabase client scoped to a specific user.

The client is built with the anon key and injects the user's JWT as a
bearer token, so it **respects RLS** policies for that user and is confined
to what their policies allow.

## Parameters

### accessToken

`string`

The user's JWT access token.

## Returns

`SupabaseClient`

A SupabaseClient authenticated as the given user with RLS
  enforced; the session is not auto-refreshed or persisted.
