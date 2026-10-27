[**sveltekit-supabase-starter**](../../README.md)

***

# Function: exportAuditCsv()

> **exportAuditCsv**(`supabase`, `orgId`, `limit`, `offset`): `Promise`\<`string`\>

Export an organization's audit log as CSV.

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
  [clampExportPage](clampExportPage.md) to at least 1 and at most [MAX\_EXPORT\_ROWS](../variables/MAX_EXPORT_ROWS.md)).

### offset

`number` = `0`

Row offset (default 0, floored at 0).

## Returns

`Promise`\<`string`\>

A CSV string with a header row followed by one row per entry,
  ordered newest first. Always includes the header, even for an empty log, so
  a consumer can tell "no entries" from "wrong shape".

## Throws

when the underlying read fails.
