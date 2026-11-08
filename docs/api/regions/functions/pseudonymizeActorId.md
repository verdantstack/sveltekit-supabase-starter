[**sveltekit-supabase-starter**](../../README.md)

***

# Function: pseudonymizeActorId()

> **pseudonymizeActorId**(`regionCode`, `userId`): `string`

Replace a user id with a stable, region-scoped pseudonym.

## Parameters

### regionCode

`string`

The region the export belongs to.

### userId

`string`

The raw user id.

## Returns

`string`

`psn_` followed by 32 hex characters of `sha256`.

## Remarks

Stable on purpose: an auditor comparing two exports of the same
tenant must be able to follow one actor across them, or the export stops
being an audit trail. The region is part of the digest so the same person
pseudonymises differently in different regions and the value cannot be joined
across a border by an outsider holding both files.

The `psn_` prefix matters: it makes a pseudonymised export unmistakably
pseudonymised, so nobody downstream mistakes it for a real identifier list.
