[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: assertSeatAvailable()

> **assertSeatAvailable**(`supabase`, `orgId`, `billing`): `Promise`\<\{ `planSeats`: `number`; `seatsUsed`: `number`; \}\>

The one place seat limits are enforced: joining (invite acceptance).

This function is the **whole** seat policy. `BillingAdapter` is a pure
reporting seam — it answers "what is this org's subscription state?" and has
no decision method of its own. That split is deliberate: an earlier version
had a seat check in both places, and they drifted (the adapter compared its
constructor's `seatLimit` against a caller-supplied count, this one compares
`state.planSeats` against the real membership count, and only this one treats
`status: 'none'` as blocking). One decision cannot disagree with itself.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The organization id.

### billing

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

The billing adapter describing the plan.

## Returns

`Promise`\<\{ `planSeats`: `number`; `seatsUsed`: `number`; \}\>

The seats used and the plan's paid seat count.

## Remarks

Invite creation is deliberately NOT limited — inviting beyond seats
is allowed, and the limit surfaces at accept time with an actionable error.
That ordering matters: a full org must not burn an invite it cannot honour.

## Throws

with code `subscription_required` when the org has no
  active subscription (`none`), or when it is `past_due` or `canceled`; and
  with code `seat_limit` when no seats are free.
