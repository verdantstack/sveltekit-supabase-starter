[**sveltekit-supabase-starter**](../../README.md)

***

# Function: countAudit()

> **countAudit**(`supabase`, `orgId`): `Promise`\<`number`\>

Count total audit entries for an organization, ignoring any page limit.

The companion counter to [listAuditEntries](listAuditEntries.md): the UI needs "showing N of
M" to tell an operator whether the list they are reading is the whole story
or a truncated tail.

## Parameters

### supabase

A Supabase-like client exposing `from(table)`.

#### from

(`table`) => `any`

### orgId

`string`

The organization whose entries to count.

## Returns

`Promise`\<`number`\>

The total number of audit entries; `0` when the client returns a null
  payload without an error.

## Throws

when the count query fails — an unknown count must be visible,
  not silently rendered as an empty log.
