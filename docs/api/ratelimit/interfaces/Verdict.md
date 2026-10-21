[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: Verdict

Outcome of a rate-limit check or penalty. `ok` is `false` while blocked, with
`retryAfterMs` giving the remaining wait.

## Properties

### ok

> **ok**: `boolean`

***

### retryAfterMs

> **retryAfterMs**: `number`

When blocked: milliseconds until the window frees up. 0 otherwise.
