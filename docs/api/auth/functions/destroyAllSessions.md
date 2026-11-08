[**sveltekit-supabase-starter**](../../README.md)

***

# Function: destroyAllSessions()

> **destroyAllSessions**(`supabase`, `userId`, `exceptSessionId?`): `Promise`\<`void`\>

Destroy all sessions for a user except the current one (optional).
Useful for "log out everywhere" security feature.

## Parameters

### supabase

`SupabaseClient`

A Supabase client with admin privileges.

### userId

`string`

The user whose sessions to destroy.

### exceptSessionId?

`string`

Optional current session id to preserve.

## Returns

`Promise`\<`void`\>
