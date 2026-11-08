[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createOrg()

> **createOrg**(`supabase`, `userId`, `rawName`, `options`): `Promise`\<[`Organization`](../interfaces/Organization.md)\>

Create a new organization and add its creator as the `owner` member.

The slug is derived from the name with a random suffix and retried on
unique-constraint collisions, up to MAX\_SLUG\_ATTEMPTS attempts. The
creator is added as the sole owner and an `org.created` audit entry is
written.

The **region** is decided here and nowhere else: `regions.resolveNewOrgRegion`
refuses a code this deployment does not run, a region that is not accepting
new tenants (`pilot`/`retired`), and a region whose data-processing agreement
the creator has not accepted — all before any row is written, so a refused
creation leaves nothing behind. The value is then written once; afterwards the
only code path that may change it is
`services/residency.ts:completeRegionChange`, against an open, owner-requested
change.

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role, bypasses RLS — authorize in
  the caller before invoking).

### userId

`string`

The id of the creator; becomes the founding `owner`.

### rawName

`string`

The proposed organization name; trimmed and validated to
  2–80 characters.

### options

[`CreateOrgOptions`](../interfaces/CreateOrgOptions.md) = `{}`

## Returns

`Promise`\<[`Organization`](../interfaces/Organization.md)\>

The created [Organization](../interfaces/Organization.md).

## Throws

[OrgError](../classes/OrgError.md) with code `'bad_name'` when the name is empty/out
  of range or a database write fails, or `'slug_taken'` when every slug
  attempt collided.

## Throws

ResidencyError `unknown_region`, `region_not_accepting`,
  `dpa_required`, or `bad_default_region` (an operator misconfiguration, which
  `http.ts` deliberately does not register, so it answers a logged 500).
