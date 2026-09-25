[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: signIn()

> **signIn**(`email`, `password`): `Promise`\<\{ `refreshToken`: `string`; `userId`: `string`; \}\>

Sign in with email + password via Supabase Auth.

## Parameters

### email

`string`

The user's email address (normalized lower-case by the caller).

### password

`string`

The user's password.

## Returns

`Promise`\<\{ `refreshToken`: `string`; `userId`: `string`; \}\>

The signed-in user's id and the refresh token to store in the
  [session cookie](../../../auth/variables/SESSION_COOKIE.md).

## Throws

with code `invalid_credentials` when the credentials are
  rejected by Supabase Auth.
