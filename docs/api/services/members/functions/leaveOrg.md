[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: leaveOrg()

> **leaveOrg**(`supabase`, `input`): `Promise`\<`void`\>

Let a user leave an org they belong to.

The single-owner invariant is enforced: the last owner cannot leave. A
`member.left` audit entry is written.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### input

The operation context — `orgId` and the leaving `userId`.

#### orgId

`string`

#### userId

`string`

## Returns

`Promise`\<`void`\>

Resolves on success.

## Throws

[MemberError](../classes/MemberError.md) with code `'no_membership'` when the user is not
  a member, `'last_owner'` when the user is the final owner, or `'bad_role'`
  when the delete fails.
