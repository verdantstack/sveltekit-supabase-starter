[**sveltekit-supabase-starter**](../../README.md)

***

# Function: auditRowsToJson()

> **auditRowsToJson**(`rows`): `Record`\<`string`, `unknown`\>[]

Render already-read audit rows as JSON-ready objects.

## Parameters

### rows

[`AuditRow`](../interfaces/AuditRow.md)[]

The rows to render, in the order they should appear.

## Returns

`Record`\<`string`, `unknown`\>[]

One plain object per row, `metadata` decoded (or `null`).

## Remarks

The companion to [auditRowsToCsv](auditRowsToCsv.md), split out for the same
  reason: [exportAuditJson](exportAuditJson.md) is the untransformed caller, and the
  residency export is the transformed one. `metadata` is parsed back into an
  object here rather than left as a string so a consumer never has to
  JSON.parse a field twice.

## Throws

when a stored `metadata_json` is not valid JSON — a
  malformed row is surfaced rather than dropped.
