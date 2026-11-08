[**sveltekit-supabase-starter**](../../README.md)

***

# Function: sessionCookieOptions()

> **sessionCookieOptions**(`secure`): `object`

Cookie options for the session cookie, in ONE place.

These were previously duplicated at the login action and the invite-accept action. Duplicated
security options drift: hardening one call site and forgetting the other leaves the weaker
path open. Single-sourcing it here makes the guarantees testable
(`tests/csrf-cookie.test.ts`) and impossible to partially apply.

Why these attributes matter for CSRF specifically:
- `httpOnly` keeps the session token out of reach of JavaScript, so a cross-site script cannot
  read it and replay it.
- `sameSite: 'lax'` stops the browser attaching the cookie to cross-site state-changing
  requests. It does NOT stop a same-site subdomain attack, and it does NOT stop a top-level GET
  navigation. See docs/architecture.md for what covers those.
- `secure` prevents the cookie being sent over plaintext HTTP in production.

The complementary protection is SvelteKit's own `csrf.checkOrigin`, which is enabled by default
and is NOT disabled anywhere in this kit.

## Parameters

### secure

`boolean`

## Returns

`object`

### httpOnly

> `readonly` **httpOnly**: `true` = `true`

### path

> `readonly` **path**: `"/"` = `'/'`

### sameSite

> `readonly` **sameSite**: `"lax"` = `'lax'`

### secure

> **secure**: `boolean`
