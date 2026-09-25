[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: newInviteToken()

> **newInviteToken**(): `string`

Generate a cryptographically random, URL-safe invite token.

32 random bytes are base64-encoded with URL-safe substitutions and no
padding. Only the SHA-256 hash of the token is ever stored (see
[createInvite](createInvite.md)); never log or persist the raw token.

## Returns

`string`

A URL-safe token string.

## Example

```ts
const token = newInviteToken(); // e.g. "yhUQf4mKxV...-DSw2"
```
