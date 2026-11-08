[**sveltekit-supabase-starter**](../../README.md)

***

# Type Alias: PasswordStrengthResult

> **PasswordStrengthResult** = `object`

Result of a password strength check, returned by [checkPasswordStrength](../functions/checkPasswordStrength.md).

## Properties

### ok

> **ok**: `boolean`

`true` when the password meets all requirements.

***

### reasons

> **reasons**: `string`[]

Human-readable list of unmet requirements. Empty when `ok` is `true`.
