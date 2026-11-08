[**sveltekit-supabase-starter**](../../README.md)

***

# Variable: REGION\_CODES

> `const` **REGION\_CODES**: readonly \[`"us-east-1"`, `"eu-west-1"`, `"ap-southeast-1"`, `"ap-southeast-2"`\]

Every region this build can place a tenant in.

## Remarks

The single source of the `RegionCode` union. Adding a code here
without a matching entry in the catalogue (`CATALOGUE`, below) is caught by
`tests/residency.test.ts` rather than by a tenant landing in `undefined`.
