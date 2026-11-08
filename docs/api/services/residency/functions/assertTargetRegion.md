[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: assertTargetRegion()

> **assertTargetRegion**(`region`, `dpaAcceptedAtMs`, `options`): `void`

Assert that a region may take this tenant, and that its terms are accepted.

## Parameters

### region

[`Region`](../../../regions/interfaces/Region.md)

The destination region.

### dpaAcceptedAtMs

When the tenant accepted a DPA, or `null` when it has none.

`number` | `null`

### options

#### dpaAcceptedNow?

`boolean`

Whether the caller is accepting the DPA in this
  very call — the one case where `null` on the row is not a refusal.

## Returns

`void`

## Remarks

Extracted because the same two rules are asked twice — once when a
move is requested and again when it is applied — and the second ask is the one
that matters. Between the two calls a region can be retired and a request can
sit for weeks, so "we checked at request time" is not a check at all. Keeping
one function means the apply step cannot drift from the request step.

## Throws

`region_not_accepting` when the region is `pilot` or
`retired`, `dpa_required` when it requires a DPA the tenant has not accepted.
