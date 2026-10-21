[**sveltekit-supabase-starter**](../../README.md)

***

# Function: requireTenantClient()

> **requireTenantClient**(`accessToken`): `SupabaseClient`

Build the RLS-scoped client for a tenant-scoped read.

## Parameters

### accessToken

The caller's Supabase access token, from
  `event.locals.accessToken` (set by `hooks.server.ts` when the session
  cookie is exchanged for a fresh session).

`string` | `null` | `undefined`

## Returns

`SupabaseClient`

A SupabaseClient whose queries are constrained by RLS.

## Throws

when no access token is available. Falling back to a
  service-role client here would silently disable the isolation this function
  exists to provide, so it fails loudly instead. Every route that calls this
  is already behind an auth guard, so reaching this throw means the session
  and the access token have gone out of sync — a bug worth surfacing, not a
  user error to paper over.
