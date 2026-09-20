[**sveltekit-supabase-starter**](../../README.md)

***

# Function: checkPasswordStrength()

> **checkPasswordStrength**(`password`): [`PasswordStrengthResult`](../type-aliases/PasswordStrengthResult.md)

Check password strength against complexity requirements.

## Parameters

### password

`string`

The plaintext password to evaluate.

## Returns

[`PasswordStrengthResult`](../type-aliases/PasswordStrengthResult.md)

A result with `ok: true` when all requirements are met, or `ok: false`
with human-readable `reasons` listing what's missing.
