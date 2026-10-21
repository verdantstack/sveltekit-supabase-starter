[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createServerClient()

> **createServerClient**(): `SupabaseClient`

Create a Supabase client for privileged server-side admin operations.

The client is built with the service-role key and **bypasses RLS**, so it
can read and write across tenants. Use it only for trusted server-side work
(services/audit), never for data scoped to a caller's request.

## Returns

`SupabaseClient`

A SupabaseClient with an unauthenticated, non-persisting
  session and service-role privileges.

## Remarks

Sessions are neither refreshed nor persisted here; RLS is bypassed,
  so tenant isolation must be enforced by application code.
