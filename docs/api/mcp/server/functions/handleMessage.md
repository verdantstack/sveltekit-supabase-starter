[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: handleMessage()

> **handleMessage**(`supabase`, `raw`): `Promise`\<`unknown`\>

Handle one JSON-RPC message and return the reply, or null for a notification.
Exported so the tests can drive the protocol without spawning a process.

## Parameters

### supabase

`SupabaseClient`

### raw

`string`

## Returns

`Promise`\<`unknown`\>
