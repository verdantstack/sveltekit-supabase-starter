[**sveltekit-supabase-starter**](../../README.md)

***

# Function: listAuditEntries()

> **listAuditEntries**(`supabase`, `orgId`, `limit`): `Promise`\<[`AuditRow`](../interfaces/AuditRow.md)[]\>

Read recent audit entries for an organization, newest first.

The companion reader to [audit](audit.md). Used by the shipped audit-log UI
route; callers should pass a service-role client (matching the writer) so
the read is not constrained by RLS on top of the app-level `audit.view`
capability check performed by the route.

## Parameters

### supabase

A Supabase-like client exposing `from(table)`.

#### from

(`table`) => `any`

### orgId

`string`

The organization whose entries to list.

### limit

`number` = `200`

Maximum number of entries (default 200).

## Returns

`Promise`\<[`AuditRow`](../interfaces/AuditRow.md)[]\>

The newest `limit` entries, in descending `seq` order.

## Throws

when the query fails (surfaced to the caller, unlike the
  writer which logs and swallows — a failed read must be visible).
