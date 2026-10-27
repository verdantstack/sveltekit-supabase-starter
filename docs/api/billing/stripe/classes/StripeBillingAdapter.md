[**sveltekit-supabase-starter**](../../../README.md)

***

# Class: StripeBillingAdapter

Billing adapter backed by Stripe Checkout.

## Implements

- [`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

## Constructors

### Constructor

> **new StripeBillingAdapter**(`secretKey?`, `priceId?`): `StripeBillingAdapter`

Create a Stripe adapter.

#### Parameters

##### secretKey?

`string`

Stripe secret key (falls back to `STRIPE_SECRET_KEY`).

##### priceId?

`string`

Stripe price id (falls back to `STRIPE_PRICE_ID`).

#### Returns

`StripeBillingAdapter`

## Properties

### name

> `readonly` **name**: `"stripe"` = `'stripe'`

## Methods

### getPlan()

> **getPlan**(`_orgId`): `Promise`\<\{ `planId`: `string`; `seatLimit`: `number`; \}\>

Get the plan details for an org.

#### Parameters

##### \_orgId

`string`

Organization id (unused in stub).

#### Returns

`Promise`\<\{ `planId`: `string`; `seatLimit`: `number`; \}\>

Plan details.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getPlan`](../../adapter/interfaces/BillingAdapter.md#getplan)

***

### getSeatCount()

> **getSeatCount**(`_orgId`): `Promise`\<`number`\>

Get the current seat count for an org (stub returns 0).

#### Parameters

##### \_orgId

`string`

Organization id (unused in stub).

#### Returns

`Promise`\<`number`\>

Seat count.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getSeatCount`](../../adapter/interfaces/BillingAdapter.md#getseatcount)

***

### getSubscriptionState()

> **getSubscriptionState**(`_orgId`): `Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

Get subscription state for an organization.

#### Parameters

##### \_orgId

`string`

Organization id (unused in stub).

#### Returns

`Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

Subscription state (stub returns `none`).

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getSubscriptionState`](../../adapter/interfaces/BillingAdapter.md#getsubscriptionstate)
