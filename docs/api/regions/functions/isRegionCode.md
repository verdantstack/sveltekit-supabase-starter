[**sveltekit-supabase-starter**](../../README.md)

***

# Function: isRegionCode()

> **isRegionCode**(`value`): value is "us-east-1" \| "eu-west-1" \| "ap-southeast-1" \| "ap-southeast-2"

Narrow a raw string to a `RegionCode` without throwing.

## Parameters

### value

`string`

The candidate code, typically from a form field.

## Returns

value is "us-east-1" \| "eu-west-1" \| "ap-southeast-1" \| "ap-southeast-2"

`true` when the code is in the catalogue, narrowing `value`.
