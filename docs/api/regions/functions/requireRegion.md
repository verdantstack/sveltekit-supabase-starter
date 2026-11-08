[**sveltekit-supabase-starter**](../../README.md)

***

# Function: requireRegion()

> **requireRegion**(`code`): [`Region`](../interfaces/Region.md)

Look up a region by code, or throw.

## Parameters

### code

`string`

The candidate code.

## Returns

[`Region`](../interfaces/Region.md)

The region.

## Throws

with code `unknown_region` when it is not in the
catalogue. Never falls back to a default — see the module's security notes.
