[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: Organization

A persisted organization row.

`created_at` is an ISO-8601 timestamp string as returned by Supabase.

`region_code` and `dpa_accepted_at` are optional on the type because not every
reader selects them (`listOrgsForUser` embeds a fixed column list), but they
are `NOT NULL` / nullable-assigned in the schema respectively — see
`supabase/migrations/0003_residency.sql`.

## Properties

### created\_at

> **created\_at**: `string`

***

### dpa\_accepted\_at?

> `optional` **dpa\_accepted\_at**: `string` \| `null`

When the region's data-processing agreement was accepted, or `null`.

***

### id

> **id**: `string`

***

### name

> **name**: `string`

***

### region\_code?

> `optional` **region\_code**: `string`

The tenant's home region. Written once, at creation.

***

### slug

> **slug**: `string`
