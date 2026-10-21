[**sveltekit-supabase-starter**](../../README.md)

***

# Function: exportAuditJson()

> **exportAuditJson**(`supabase`, `orgId`, `limit`, `offset`): `Promise`\<`Record`\<`string`, `unknown`\>[]\>

Export an organization's audit log as JSON.

## Parameters

### supabase

A Supabase-like client exposing `from(table)`.

#### from

(`table`) => `any`

### orgId

`string`

The organization whose entries to export.

### limit

`number` = `1000`

Maximum rows to export (default `1000`, clamped by
  [clampExportPage](clampExportPage.md)).

### offset

`number` = `0`

Row offset (default 0, floored at 0).

## Returns

`Promise`\<`Record`\<`string`, `unknown`\>[]\>

Audit entries with `metadata` parsed back into an object (or `null`
  when it was absent), ordered newest first.

## Throws

when the underlying read fails, or when a stored
  `metadata_json` column is not valid JSON. A malformed row is surfaced rather
  than dropped: silently omitting entries from a compliance export is worse
  than failing loudly.
