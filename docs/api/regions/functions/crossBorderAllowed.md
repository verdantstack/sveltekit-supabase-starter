[**sveltekit-supabase-starter**](../../README.md)

***

# Function: crossBorderAllowed()

> **crossBorderAllowed**(`from`, `to`): `boolean`

Whether data may leave `from` for `to`.

## Parameters

### from

[`Region`](../interfaces/Region.md)

The tenant's region.

### to

[`Region`](../interfaces/Region.md)

The destination region.

## Returns

`boolean`

`true` when the transfer is permitted.

## Remarks

Same-region is always allowed: an export addressed to the region the
tenant already lives in has not crossed a border. The restriction is on the
*destination*, read from the origin's policy — a tenant cannot escape its own
policy by naming a permissive destination.
