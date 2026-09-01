[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: BillingAdapter

Pluggable contract for seat-based billing.

Implementations decide whether an org may add members (seat limits) and what
plan/limits an org has. Swap in a real merchant-of-record adapter for
production; createBillingAdapter wires one by environment.

## Methods

### assertSeatAvailable()

> **assertSeatAvailable**(`orgId`, `currentMemberCount`): `Promise`\<`void`\>

Check if an org has available seats for a new member.
Resolves if the org is under its seat limit; rejects with a
[BillingError](../classes/BillingError.md) if the org is at capacity or has no plan.

#### Parameters

##### orgId

`string`

##### currentMemberCount

`number`

#### Returns

`Promise`\<`void`\>

***

### getPlan()

> **getPlan**(`orgId`): `Promise`\<\{ `planId`: `string`; `seatLimit`: `number`; \}\>

Get the plan details for an org.

#### Parameters

##### orgId

`string`

#### Returns

`Promise`\<\{ `planId`: `string`; `seatLimit`: `number`; \}\>

***

### getSeatCount()

> **getSeatCount**(`orgId`): `Promise`\<`number`\>

Get the current seat count for an org.

#### Parameters

##### orgId

`string`

#### Returns

`Promise`\<`number`\>
