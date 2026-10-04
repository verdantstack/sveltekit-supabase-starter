[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: serve()

> **serve**(`supabase`, `io`): `Promise`\<`number`\>

Serve newline-delimited JSON-RPC on a pair of streams until `input` ends.
Resolves with the number of replies written.

Two details that matter in practice:
 - stdout is the protocol channel, so nothing else may be written to it.
 - handling is serialised through a promise chain: a tool call awaits the
   database, and two replies going out of order would break the client's
   id -> response pairing.

## Parameters

### supabase

`SupabaseClient`

### io

[`StdioIo`](../interfaces/StdioIo.md)

## Returns

`Promise`\<`number`\>
