[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: LimiterOptions

Configuration for [createFailedAttemptLimiter](../functions/createFailedAttemptLimiter.md).

## Properties

### maxAttempts

> **maxAttempts**: `number`

Failed attempts allowed within the window before blocking.

***

### maxKeys?

> `optional` **maxKeys**: `number`

Safety valve against unbounded memory from spoofed-key floods:
when tracked keys exceed this, oldest-inserted keys are evicted.

***

### now()?

> `optional` **now**: () => `number`

Injectable clock for tests. Defaults to Date.now.

#### Returns

`number`

***

### windowMs

> **windowMs**: `number`

Sliding window size in milliseconds.
