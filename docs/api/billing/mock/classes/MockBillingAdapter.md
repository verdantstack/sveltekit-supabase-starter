[**sveltekit-supabase-starter**](../../../README.md)

***

# Class: MockBillingAdapter

In-memory [BillingAdapter](../../adapter/interfaces/BillingAdapter.md) for development and testing.

Reports a fixed, deterministic plan rather than talking to a payment provider.
`getSeatCount` returns `0` because usage is not tracked here — the seat policy
in `billing/service.ts` counts memberships itself.

## Remarks

This adapter makes no entitlement decision. It answers "what is the
  state?" and `billing/service.ts::assertSeatAvailable` answers "may this org
  add a member?". Splitting it that way is what keeps the rule in one place.

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
