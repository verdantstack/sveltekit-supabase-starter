[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: peekInvite()

> **peekInvite**(`supabase`, `token`): `Promise`\<\{ `state`: `"invalid"`; \} \| \{ `state`: `"expired"`; \} \| \{ `state`: `"revoked"`; \} \| \{ `state`: `"accepted"`; \} \| \{ `expiresAtMs`: `number`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; `state`: `"valid"`; \}\>

Read-only preview for the landing page of an invite link — never mutates.

## Parameters

### supabase

`SupabaseClient`

### token

`string`

## Returns

`Promise`\<\{ `state`: `"invalid"`; \} \| \{ `state`: `"expired"`; \} \| \{ `state`: `"revoked"`; \} \| \{ `state`: `"accepted"`; \} \| \{ `expiresAtMs`: `number`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; `state`: `"valid"`; \}\>
