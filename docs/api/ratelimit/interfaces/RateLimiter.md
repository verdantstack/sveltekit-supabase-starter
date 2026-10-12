[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: RateLimiter

A rate limiter keyed by an arbitrary string (e.g. an IP or user-scoped key). The interface
is deliberately minimal so it can be swapped for a shared-store implementation without
touching callers. Only failed attempts are penalized; success resets the key.

## Methods

### check()

> **check**(`key`): [`Verdict`](Verdict.md)

Read-only check — never records an attempt.

#### Parameters

##### key

`string`

#### Returns

[`Verdict`](Verdict.md)

***

### penalize()

> **penalize**(`key`): [`Verdict`](Verdict.md)

Record a failed attempt. Returns the (possibly newly-blocked) verdict.

#### Parameters

##### key

`string`

#### Returns

[`Verdict`](Verdict.md)

***

### reset()

> **reset**(`key`): `void`

Clear state for a key (call on successful auth).

#### Parameters

##### key

`string`

#### Returns

`void`
