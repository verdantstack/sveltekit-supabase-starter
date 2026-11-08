[**sveltekit-supabase-starter**](../../README.md)

***

# Function: createUser()

> **createUser**(`supabase`, `input`): `Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \}\>

Create a new user account via Supabase Auth.

Validates email format and password strength, then calls the Supabase admin
API. Only Postgres unique constraint violations (error code `23505`) are
caught and reported as `email_taken`; all other errors are re-thrown.

## Parameters

### supabase

`SupabaseClient`

A Supabase client with admin privileges.

### input

The raw sign-up payload.

#### email

`string`

The user's email address.

#### name

`string`

The user's display name; falls back to the email local-part when empty.

#### password

`string`

The user's password, checked against complexity requirements.

## Returns

`Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \}\>

The created user's id, normalized email, and name.

## Throws

with code `invalid_email`, `weak_password`, or `email_taken`
when validation fails or the email is already registered.
