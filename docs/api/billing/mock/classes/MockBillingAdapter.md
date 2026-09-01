[**sveltekit-supabase-starter**](../../../README.md)

***

# Class: MockBillingAdapter

In-memory [BillingAdapter](../../adapter/interfaces/BillingAdapter.md) for development and testing.

Enforces a fixed, deterministic seat limit rather than talking to a payment
provider. `getSeatCount` returns `0` because usage is not tracked here — the
caller supplies the current member count to [assertSeatAvailable](#assertseatavailable).

## Remarks

Replace with a real merchant-of-record adapter for production.

## Implements

- [`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

## Constructors

### Constructor

> **new MockBillingAdapter**(`seatLimit`): `MockBillingAdapter`

#### Parameters

##### seatLimit

`number` = `DEFAULT_PLAN_SEATS`

#### Returns

`MockBillingAdapter`

## Methods

### assertSeatAvailable()

> **assertSeatAvailable**(`_orgId`, `currentMemberCount`): `Promise`\<`void`\>

Check if an org has available seats for a new member.
Resolves if the org is under its seat limit; rejects with a
[BillingError](../../adapter/classes/BillingError.md) if the org is at capacity or has no plan.

#### Parameters

##### \_orgId

`string`

##### currentMemberCount

`number`

#### Returns

`Promise`\<`void`\>

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`assertSeatAvailable`](../../adapter/interfaces/BillingAdapter.md#assertseatavailable)

***

### getPlan()

> **getPlan**(`_orgId`): `Promise`\<\{ `planId`: `string`; `seatLimit`: `number`; \}\>

Get the plan details for an org.

#### Parameters

##### \_orgId

`string`

#### Returns

`Promise`\<\{ `planId`: `string`; `seatLimit`: `number`; \}\>

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getPlan`](../../adapter/interfaces/BillingAdapter.md#getplan)

***

### getSeatCount()

> **getSeatCount**(`_orgId`): `Promise`\<`number`\>

Get the current seat count for an org.

#### Parameters

##### \_orgId

`string`

#### Returns

`Promise`\<`number`\>

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getSeatCount`](../../adapter/interfaces/BillingAdapter.md#getseatcount)
