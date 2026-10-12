[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: BillingAdapter

Pluggable contract for seat-based billing.

Implementations **report facts**; they do not decide. The seat decision lives
in exactly one place — `billing/service.ts::assertSeatAvailable` — which reads
[BillingAdapter.getSubscriptionState](#getsubscriptionstate) and applies the policy.

## Remarks

There is deliberately no `assertSeatAvailable` on this interface. An
earlier version had one, and having it in both places is how the two drifted:
the adapter compared its constructor's `seatLimit` while the service compared
`state.planSeats`, and only the service treated `status: 'none'` as a block. A
seam that reports and a service that decides cannot disagree.

A real merchant-of-record implementation is still consulted — its provider
call is what [BillingAdapter.getSubscriptionState](#getsubscriptionstate) does — so a provider
outage surfaces as a throw from that method and propagates unchanged.

Swap in a real adapter for production; createBillingAdapter wires one
by environment.

## Methods

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

***

### getSubscriptionState()

> **getSubscriptionState**(`orgId`): `Promise`\<[`SubscriptionState`](../type-aliases/SubscriptionState.md)\>

Fetch the current subscription state for an organization.

This is the single input the seat policy reads, so for a real adapter it is
where the provider is consulted.

#### Parameters

##### orgId

`string`

The organization id.

#### Returns

`Promise`\<[`SubscriptionState`](../type-aliases/SubscriptionState.md)\>

The current subscription state, including the paid seat count.

#### Throws

with code `adapter_error` when the provider is
  unreachable — a caller must never read a failure as "there is room".
