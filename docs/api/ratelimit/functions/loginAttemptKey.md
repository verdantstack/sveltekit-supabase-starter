[**sveltekit-supabase-starter**](../../README.md)

***

# Function: loginAttemptKey()

> **loginAttemptKey**(`ip`, `email`): `string`

Build a rate-limit key scoped per IP/login pair. The email is trimmed and lowercased so
two spellings of the same address share a key.

## Parameters

### ip

`string`

The client IP.

### email

`string`

The submitted login email.

## Returns

`string`

A key identifying a single login source.
