[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: listMembers()

> **listMembers**(`supabase`, `orgId`): `Promise`\<[`MemberRow`](../interfaces/MemberRow.md)[]\>

List all members of an org.

Order is not guaranteed; sort client-side if presentation requires it.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The org whose members to list.

## Returns

`Promise`\<[`MemberRow`](../interfaces/MemberRow.md)[]\>

An array of [MemberRow](../interfaces/MemberRow.md); empty when the org has no members.

## Throws

[MemberError](../classes/MemberError.md) with code `'no_membership'` when the query fails.
