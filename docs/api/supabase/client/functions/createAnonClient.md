[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createAnonClient()

> **createAnonClient**(): `SupabaseClient`

Create an anonymous Supabase client for public auth flows.

Used by `hooks.server.ts` (session refresh), the sign-in / sign-up routes,
and the invite accept flow. Built with the public anon key, so it can talk
to Supabase Auth but has no table privileges beyond RLS.

## Returns

`SupabaseClient`

A SupabaseClient with an unauthenticated, non-persisting
  session and anon-key privileges.
