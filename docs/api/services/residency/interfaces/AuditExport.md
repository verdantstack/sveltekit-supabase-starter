[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: AuditExport

The result of an export that passed the region policy.

## Properties

### body

> **body**: `string`

The rendered document.

***

### contentType

> **contentType**: `string`

`'text/csv; charset=utf-8'` or `'application/json; charset=utf-8'`.

***

### destinationRegion

> **destinationRegion**: `string`

Where the export was addressed.

***

### limit

> **limit**: `number`

The row cap actually used, after [clampExportPage](../../../audit/functions/clampExportPage.md).

***

### offset

> **offset**: `number`

The row offset actually used, after [clampExportPage](../../../audit/functions/clampExportPage.md).

***

### pseudonymized

> **pseudonymized**: `boolean`

Whether identifiers were replaced on the way out.

***

### region

> **region**: `string`

The tenant's own region.

***

### rowCount

> **rowCount**: `number`

How many events the document contains.
