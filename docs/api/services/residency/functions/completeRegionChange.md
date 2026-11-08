[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: completeRegionChange()

> **completeRegionChange**(`supabase`, `input`): `Promise`\<\{ `from`: `string`; `to`: `string`; \}\>

Apply a requested region change to the tenant's row.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### input

#### actorRole

`"owner"` \| `"admin"` \| `"member"` \| `null` \| `undefined`

Re-derived role in this organization.

#### actorUserId

`string`

The acting user id.

#### moveId

`string`

The open request to apply.

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

#### orgId

`string`

The organization id.

## Returns

`Promise`\<\{ `from`: `string`; `to`: `string`; \}\>

The region pair that was applied.

## Remarks

**Only call this once the tenant's data has been copied to the
destination region.** The function flips the recorded home; it copies nothing.
The two-step shape (request, then apply) exists precisely so that an operator
can be the one who decides when the data move is done and sign their name to
it — `requested_by_user_id` and the completion audit row are that signature.

The target region is re-validated here and not only at request time: a pilot
region can be retired while a request is open, and completing a move into a
region that no longer accepts tenants would strand the tenant in the worst
possible place.

## Throws

`forbidden` when the actor lacks `org.region.move`.

## Throws

`no_pending_move` when the id is not an open request
for this organization, `region_not_accepting` or `dpa_required` when the target
has changed since the request, `not_found` when the organization is gone.

## Throws

when either write fails. The tenant row is written first on
purpose — see the module's design notes on ordering without a transaction.
