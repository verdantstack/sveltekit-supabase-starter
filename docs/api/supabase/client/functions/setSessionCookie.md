[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: setSessionCookie()

> **setSessionCookie**(`cookies`, `refreshToken`, `secure`): `void`

Write the app's session cookie (Supabase refresh token).

## Parameters

### cookies

`Cookies`

The SvelteKit cookies API from the current event.

### refreshToken

`string`

The Supabase refresh token to persist.

### secure

`boolean`

Whether to set the cookie as Secure-only (production).

## Returns

`void`
