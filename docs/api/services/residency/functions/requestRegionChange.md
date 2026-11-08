[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: requestRegionChange()

> **requestRegionChange**(`supabase`, `input`): `Promise`\<\{ `from`: `string`; `fromRegion`: `string`; `moveId`: `string`; `to`: `string`; `toRegion`: `string`; \}\>

Ask for a tenant to be re-homed in another region.

## Parameters

### supabase

`SupabaseClient`

A Supabase client (service role — the write is a tenant
  mutation, and the caller has already re-derived `actorRole`).

### input

#### actorRole

`"owner"` \| `"admin"` \| `"member"` \| `null` \| `undefined`

The actor's role in *this* organization, re-derived by
  the caller on every request.

#### actorUserId

`string`

The acting user id (from the session, never the form).

#### dpaAccepted?

`boolean`

Whether the owner is accepting the *destination*
  region's data-processing agreement as part of this request. A tenant homed
  in a permissive region has no DPA on record, so without this a move into a
  region that requires one could never be requested at all — the acceptance
  has to be capturable at the moment the move is asked for, by the person with
  the authority to commit the tenant (`org.region.move`, owner-only).

#### justification?

`string` \| `null`

Free-text reason, shown to the operator.

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

#### orgId

`string`

The organization id.

#### toRegion

`string`

The requested destination region code.

## Returns

`Promise`\<\{ `from`: `string`; `fromRegion`: `string`; `moveId`: `string`; `to`: `string`; `toRegion`: `string`; \}\>

The new move's id and the region pair.

## Remarks

Nothing moves when this is called: it records the request, which is
what makes the eventual change attributable. Three refusals happen here rather
than at completion, because a request that can never be honoured should not
look like progress: a target that is not accepting tenants, a target whose DPA
the tenant has not accepted, and a second concurrent request.

## Throws

`forbidden` when the actor lacks `org.region.move`.

## Throws

`unknown_region`, `region_not_accepting`,
`dpa_required`, `same_region` or `move_pending`.

## Throws

when the request row itself could not be written — a request
  nobody can find later would block every future one (`move_pending`) with no
  record of who created it, so this is surfaced rather than swallowed.
