[**sveltekit-supabase-starter**](../../README.md)

***

# Function: createFailedAttemptLimiter()

> **createFailedAttemptLimiter**(`options`): [`RateLimiter`](../interfaces/RateLimiter.md)

Create a sliding-window failed-attempt limiter.

## Parameters

### options

[`LimiterOptions`](../interfaces/LimiterOptions.md)

Window size, attempt cap, and optional clock/max-key overrides. See
  [LimiterOptions](../interfaces/LimiterOptions.md).

## Returns

[`RateLimiter`](../interfaces/RateLimiter.md)

A concrete [RateLimiter](../interfaces/RateLimiter.md) instance. The returned implementation is
  in-memory and per-process; for multi-instance deployments implement the interface
  against a shared store instead.

## Example

```ts
const limiter = createFailedAttemptLimiter({ windowMs: 15 * 60 * 1000, maxAttempts: 5 });
if (!limiter.check(ip).ok) return fail(429, { error: 'Too many attempts.' });
```
