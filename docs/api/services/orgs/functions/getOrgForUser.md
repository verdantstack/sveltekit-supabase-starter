[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: getOrgForUser()

> **getOrgForUser**(`supabase`, `userId`, `orgId`): `Promise`\<\{ `org`: [`Organization`](../interfaces/Organization.md); `role`: `string`; \} \| `null`\>

Fetch a single org for a user, paired with their role in it.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### userId

`string`

The user whose membership to match.

### orgId

`string`

The org to fetch.

## Returns

`Promise`\<\{ `org`: [`Organization`](../interfaces/Organization.md); `role`: `string`; \} \| `null`\>

The org and the user's `role`, or `null` when the user is not a
  member of that org.
