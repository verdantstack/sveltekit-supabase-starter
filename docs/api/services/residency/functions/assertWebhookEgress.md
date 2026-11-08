[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: assertWebhookEgress()

> **assertWebhookEgress**(`supabase`, `orgId`): `Promise`\<[`Region`](../../../regions/interfaces/Region.md)\>

Refuse outbound webhook delivery where the tenant's region forbids it.

## Parameters

### supabase

`SupabaseClient`

A Supabase client.

### orgId

`string`

The organization id.

## Returns

`Promise`\<[`Region`](../../../regions/interfaces/Region.md)\>

The tenant's region, so the caller can name it in its error.

## Remarks

A webhook is the largest uncontrolled egress this kit has: the
payload leaves for an arbitrary third-party URL that the region's policy has
never seen. Where the policy disallows it, the refusal belongs at registration
time — the moment the operator can still say no — not at delivery time, when
the URL is already trusted and the event is already rendered.

## Throws

`egress_blocked` when the policy forbids webhook
egress, or `not_found`/`unknown_region` as [getOrgResidency](getOrgResidency.md) does.
