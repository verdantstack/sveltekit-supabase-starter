[**sveltekit-supabase-starter**](../../README.md)

***

# Function: signupAttemptKey()

> **signupAttemptKey**(`ip`): `string`

Build a rate-limit key scoped per IP for signup attempts.

## Parameters

### ip

`string`

The client IP.

## Returns

`string`

A key identifying all signup attempts from a single source.
