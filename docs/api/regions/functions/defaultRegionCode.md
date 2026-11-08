[**sveltekit-supabase-starter**](../../README.md)

***

# Function: defaultRegionCode()

> **defaultRegionCode**(): `"us-east-1"` \| `"eu-west-1"` \| `"ap-southeast-1"` \| `"ap-southeast-2"`

The region a new organization lands in when the caller does not name one.

## Returns

`"us-east-1"` \| `"eu-west-1"` \| `"ap-southeast-1"` \| `"ap-southeast-2"`

The configured default region code.

## Remarks

Reads `REGION_DEFAULT`. The variable is validated, not trusted: a
typo would otherwise place every new tenant in a jurisdiction nobody chose,
and the only evidence would be a column value nobody looks at.

## Throws

with code `bad_default_region` when `REGION_DEFAULT`
is set to a code outside the catalogue.
