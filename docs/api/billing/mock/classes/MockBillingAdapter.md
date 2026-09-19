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

> **assertSeatAvailable**(`orgId`, `currentMemberCount`): `Promise`\<`void`\>

Check seat availability and subscription status.

Blocks new seat additions when the subscription is `past_due` or `canceled`.
Otherwise enforces the seat limit.

#### Parameters

##### orgId

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

***

### getSubscriptionState()

> **getSubscriptionState**(`_orgId`): `Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

Report a static `active` subscription for any organization.

#### Parameters

##### \_orgId

`string`

Ignored; every org is on the same mock plan.

#### Returns

`Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

An `active` state with the configured seat count.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getSubscriptionState`](../../adapter/interfaces/BillingAdapter.md#getsubscriptionstate)
