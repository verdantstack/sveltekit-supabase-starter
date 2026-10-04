[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: AuditEntry

A single audit log entry, expressed in the caller-facing shape before it is
persisted to the `audit_log` table (camelCase here, snake_case on disk).

## Remarks

Append-only by design: there is no update or delete path for audit
  rows anywhere in this starter. `metadata` is free-form and serialized to
  JSON on write; keep it JSON-serializable.

## Properties

### action

> **action**: `string`

***

### actorUserId

> **actorUserId**: `string` \| `null`

***

### metadata?

> `optional` **metadata**: `Record`\<`string`, `unknown`\>

***

### orgId

> **orgId**: `string` \| `null`

***

### targetId?

> `optional` **targetId**: `string`

***

### targetType?

> `optional` **targetType**: `string`
