[**sveltekit-supabase-starter**](../../README.md)

***

# Function: auditRowsToCsv()

> **auditRowsToCsv**(`rows`): `string`

Render already-read audit rows as CSV.

## Parameters

### rows

[`AuditRow`](../interfaces/AuditRow.md)[]

The rows to render, in the order they should appear.

## Returns

`string`

A CSV document: header first, then one line per row.

## Remarks

Split out from [exportAuditCsv](exportAuditCsv.md) so a caller can transform rows
  on the way out and still get the same escaping. `services/residency.ts`
  needs exactly that: a region whose policy requires pseudonymised
  identifiers replaces `actorUserId` before rendering, and re-implementing
  RFC 4180 escaping there would mean a second writer of the one rule that
  keeps an exported row from becoming two rows — or a formula.
