[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: transferOwnership()

> **transferOwnership**(`supabase`, `input`): `Promise`\<`void`\>

Transfer ownership: target becomes owner, actor steps down to admin.
Single-owner invariant: organization must have exactly one owner.

## Parameters

### supabase

`SupabaseClient`

### input

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

#### actorUserId

`string`

#### orgId

`string`

#### targetUserId

`string`

## Returns

`Promise`\<`void`\>
