[**sveltekit-supabase-starter**](../../README.md)

***

# Function: clampExportPage()

> **clampExportPage**(`limit`, `offset`): `object`

Clamp caller-supplied pagination for an export.

## Parameters

### limit

`number`

The requested row cap.

### offset

`number`

The requested row offset.

## Returns

`object`

The bounded `{ limit, offset }` pair.

### limit

> **limit**: `number`

### offset

> **offset**: `number`

## Remarks

`limit` is floored at 1 so a zero/negative value still yields the header
  row rather than an empty download, and capped at [MAX\_EXPORT\_ROWS](../variables/MAX_EXPORT_ROWS.md).
  `offset` is floored at 0 — a negative offset is an error, not a silently
  ignored value, and the caller meant "from the start".
