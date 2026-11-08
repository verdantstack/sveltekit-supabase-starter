[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: recordAuditExport()

> **recordAuditExport**(`supabase`, `orgId`, `actorUserId`, `exportResult`): `Promise`\<`void`\>

Write the audit row for an export that went out through
[exportOrgAudit](exportOrgAudit.md).

## Parameters

### supabase

`SupabaseClient`

A service-role client: `audit_insert` is `WITH CHECK (true)`,
  so a user-scoped write would let any authenticated user forge entries.

### orgId

`string`

The organization id.

### actorUserId

`string`

The user who triggered the export.

### exportResult

[`AuditExport`](../interfaces/AuditExport.md)

What [exportOrgAudit](exportOrgAudit.md) returned.

## Returns

`Promise`\<`void`\>

## Remarks

Kept separate from the export itself so the rendering path stays a
read: the route decides when a delivery actually happened *and* records it.
The destination region is recorded with it — an export log that says only
"someone exported" cannot answer the question a residency review asks. The
page is recorded too, because an export of the first 1 000 of 40 000 events
left the tenant just as surely as the full one did.
