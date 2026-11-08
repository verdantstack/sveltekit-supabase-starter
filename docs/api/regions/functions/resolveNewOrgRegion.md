[**sveltekit-supabase-starter**](../../README.md)

***

# Function: resolveNewOrgRegion()

> **resolveNewOrgRegion**(`options`): [`NewOrgRegion`](../interfaces/NewOrgRegion.md)

Decide — and validate — the region a new organization is created in.

## Parameters

### options

#### dpaAccepted?

`boolean`

Whether the creator accepted the region's DPA in
  this request. Ignored by regions that do not require one.

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

#### regionCode?

`string` \| `null`

The requested region; omitted means
  [defaultRegionCode](defaultRegionCode.md).

## Returns

[`NewOrgRegion`](../interfaces/NewOrgRegion.md)

The resolved region plus the DPA timestamp to persist (`null` when
no acceptance is required or it was already given).

## Remarks

This is the single place a tenant's region is chosen. It refuses
three things that would otherwise be discovered later, when moving the data
is expensive: an unknown code, a region that is not accepting tenants, and a
region that requires a data-processing agreement the creator has not accepted.

## Throws

`unknown_region`, `region_not_accepting` or `dpa_required`.
