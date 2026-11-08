[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: AsyncRateLimiter

Asynchronous rate limiter backed by Supabase.

## Methods

### check()

> **check**(`key`): [`Verdict`](../../ratelimit/interfaces/Verdict.md) \| `Promise`\<[`Verdict`](../../ratelimit/interfaces/Verdict.md)\>

Check whether a key is within the limit.

#### Parameters

##### key

`string`

#### Returns

[`Verdict`](../../ratelimit/interfaces/Verdict.md) \| `Promise`\<[`Verdict`](../../ratelimit/interfaces/Verdict.md)\>

***

### penalize()

> **penalize**(`key`): [`Verdict`](../../ratelimit/interfaces/Verdict.md) \| `Promise`\<[`Verdict`](../../ratelimit/interfaces/Verdict.md)\>

Record an attempt and return the verdict.

#### Parameters

##### key

`string`

#### Returns

[`Verdict`](../../ratelimit/interfaces/Verdict.md) \| `Promise`\<[`Verdict`](../../ratelimit/interfaces/Verdict.md)\>

***

### reset()

> **reset**(`key`): `void` \| `Promise`\<`void`\>

Reset the limit for a key.

#### Parameters

##### key

`string`

#### Returns

`void` \| `Promise`\<`void`\>
