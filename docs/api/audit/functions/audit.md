[**sveltekit-supabase-starter**](../../README.md)

***

# Function: audit()

> **audit**(`supabase`, `entry`): `Promise`\<`void`\>

Write an audit log entry. Uses the service role client to bypass RLS.
The audit_log table has no UPDATE or DELETE policies — append-only by design.

## Parameters

### supabase

A Supabase-like client exposing `from(table)`; expected to be
  a service-role client so the insert bypasses RLS.

#### from

(`table`) => `any`

### entry

[`AuditEntry`](../interfaces/AuditEntry.md)

The audit entry to persist.

## Returns

`Promise`\<`void`\>

Resolves once the write attempt completes.

## Remarks

Failures are logged loudly but never thrown, so a broken audit
  write cannot break the primary operation.
