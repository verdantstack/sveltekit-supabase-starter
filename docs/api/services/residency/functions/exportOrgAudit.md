[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: exportOrgAudit()

> **exportOrgAudit**(`supabase`, `input`): `Promise`\<[`AuditExport`](../interfaces/AuditExport.md)\>

Export a tenant's audit trail, subject to its region policy.

## Parameters

### supabase

`SupabaseClient`

The client to read with. The audit export endpoint passes its
  **RLS-scoped** client, so the rows are still filtered by `audit_select` on
  top of the `org_id` filter here.

### input

#### destinationRegion?

`string` \| `null`

Where the file is being delivered; omitted
  means the tenant's own region.

#### format

`"json"` \| `"csv"`

`'csv'` or `'json'`.

#### limit?

`number`

Maximum rows (clamped, see `clampExportPage`).

#### offset?

`number`

Row offset.

#### orgId

`string`

The organization id.

## Returns

`Promise`\<[`AuditExport`](../interfaces/AuditExport.md)\>

The rendered export plus what was done to it.

## Remarks

The policy is read from the **origin** region, not the destination:
a tenant cannot escape a strict home by addressing an export to a permissive
one. Where the policy requires pseudonymised identifiers, `actorUserId` is
replaced on the way out (stable per region and user, so the trail still
correlates) and `pseudonymized` reports it, so the recipient is never misled
about whether the file names people.

Rendering is delegated to `audit.ts:auditRowsToCsv`/`auditRowsToJson` so this
module does not become a second writer of CSV escaping — the one rule whose
failure mode is an extra row in a compliance export, or a formula.

## Throws

`cross_border_blocked` when the destination is
outside the tenant's region and the policy forbids it, `unknown_region` when
the destination is not a region this deployment runs.
