[**sveltekit-supabase-starter**](../../README.md)

***

# Function: getMembership()

> **getMembership**(`supabase`, `orgId`, `userId`): `Promise`\<\{ `membershipId`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; \} \| `null`\>

Look up a user's membership in an org and return their role.

## Parameters

### supabase

A Supabase-like client exposing `from(table)`.

#### from

(`table`) => `any`

### orgId

`string`

The organization to look up.

### userId

`string`

The user to look up.

## Returns

`Promise`\<\{ `membershipId`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; \} \| `null`\>

The role and membership row id, or `null` when the user is not a
  member (including when the row's role is not a valid [Role](../type-aliases/Role.md)).
