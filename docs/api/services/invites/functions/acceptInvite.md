[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: acceptInvite()

> **acceptInvite**(`supabase`, `input`): `Promise`\<\{ `orgId`: `string`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; \}\>

Atomic single-use claim: the UPDATE's WHERE clause is the concurrency gate,
so two people hitting the same link cannot both get in.

## Parameters

### supabase

`SupabaseClient`

### input

#### billing

[`BillingAdapter`](../../../billing/adapter/interfaces/BillingAdapter.md)

#### token

`string`

#### userId

`string`

## Returns

`Promise`\<\{ `orgId`: `string`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; \}\>
