[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: DataClassCounts

Row counts per data class, for a tenant.

## Properties

### apiKeys

> **apiKeys**: `number`

API keys, stored hashed.

***

### auditEvents

> **auditEvents**: `number`

Append-only audit events.

***

### files

> **files**: `number`

File metadata rows, one per uploaded object.

***

### invites

> **invites**: `number`

Invite rows — they carry an optional email address.

***

### members

> **members**: `number`

Membership rows — identity data.

***

### webhooks

> **webhooks**: `number`

Outbound webhook subscriptions.
