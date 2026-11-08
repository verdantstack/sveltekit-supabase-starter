[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: cancelRegionChange()

> **cancelRegionChange**(`supabase`, `input`): `Promise`\<`void`\>

Cancel an open region change. The tenant stays where it is.

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

The open request to cancel.

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

#### orgId

`string`

The organization id.

## Returns

`Promise`\<`void`\>

## Remarks

The row is kept rather than deleted: "who asked to move us, and why
did it not happen?" is a question an operator gets asked after the fact.

## Throws

`forbidden` when the actor lacks `org.region.move`.

## Throws

`no_pending_move` when the id is not an open request.

## Throws

when the update fails.
