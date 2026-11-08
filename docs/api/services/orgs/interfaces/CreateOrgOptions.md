[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: CreateOrgOptions

What the caller may say about a new organization's region.

## Properties

### dpaAccepted?

> `optional` **dpaAccepted**: `boolean`

Whether the creator accepted the region's data-processing agreement in this
request. Ignored by regions that do not require one.

***

### now?

> `optional` **now**: `number`

Injectable clock for tests; defaults to `Date.now()`.

***

### regionCode?

> `optional` **regionCode**: `string` \| `null`

The requested home region. Omitted means `REGION_DEFAULT` (itself validated
against the catalogue — an unknown value throws `bad_default_region` rather
than silently placing the tenant in a jurisdiction nobody chose).
