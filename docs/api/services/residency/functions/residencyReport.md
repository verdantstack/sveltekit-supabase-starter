[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: residencyReport()

> **residencyReport**(`supabase`, `orgId`, `options`): `Promise`\<[`ResidencyReport`](../interfaces/ResidencyReport.md)\>

Build the tenant's residency report.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The organization id.

### options

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

## Returns

`Promise`\<[`ResidencyReport`](../interfaces/ResidencyReport.md)\>

The residency posture, data-class counts and retention posture.

## Remarks

Read-only, and deliberately so: the two retention numbers are
*reported* rather than enforced, because the audit log is append-only by
design and this kit has no business deleting a compliance trail on a timer.
The operator's pruning job reads these figures and decides.

## Throws

`not_found`/`unknown_region` as [getOrgResidency](getOrgResidency.md) does.

## Throws

when a count fails — an unknown data-class census must not
render as "this tenant holds no data".
