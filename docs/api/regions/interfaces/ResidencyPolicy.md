[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: ResidencyPolicy

The data-processing policy a region implies.

## Remarks

Each field is enforced somewhere, and this list is the contract:

| Field | Enforced by |
|---|---|
| `auditRetentionDays` | `services/residency.ts:residencyReport()` — reports whether the tenant's oldest event is past the commitment |
| `inviteRetentionDays` | `residencyReport()` — reported as the operator's pruning obligation |
| `dsarErasureSlaDays` | `residencyReport()` — surfaced to the operator as the deadline a data-subject request runs against |
| `allowCrossBorderExport` | `services/residency.ts:exportOrgAudit()` — throws `cross_border_blocked` for a destination outside the region |
| `allowWebhookEgress` | `services/residency.ts:assertWebhookEgress()`, called by `services/webhooks.ts:createWebhook()` |
| `pseudonymizeActorIds` | `exportOrgAudit()` — replaces `actorUserId` with [pseudonymizeActorId](../functions/pseudonymizeActorId.md)'s stable digest |
| `requiresDpaAcceptance` | `resolveNewOrgRegion()` and `services/residency.ts:completeRegionChange()` |

## Properties

### allowCrossBorderExport

> `readonly` **allowCrossBorderExport**: `boolean`

Whether an audit export may be delivered to a different region.

***

### allowWebhookEgress

> `readonly` **allowWebhookEgress**: `boolean`

Whether outbound webhooks (which carry tenant data off-platform) may be registered.

***

### auditRetentionDays

> `readonly` **auditRetentionDays**: `number`

Days an audit event may be kept before it is past the regional commitment.

***

### dsarErasureSlaDays

> `readonly` **dsarErasureSlaDays**: `number`

Days the operator has to answer a data-subject erasure/access request.
The statute behind the number is named in the region's `note`, not here —
ResidencyPolicy is data, and a legal citation in a field comment
goes stale silently.

***

### inviteRetentionDays

> `readonly` **inviteRetentionDays**: `number`

Days an unaccepted invite may be kept. Invites carry an email address, so
this is the shortest-lived PII in the schema by design.

***

### pseudonymizeActorIds

> `readonly` **pseudonymizeActorIds**: `boolean`

Whether identifiers in an audit export must be replaced by a stable digest.

***

### requiresDpaAcceptance

> `readonly` **requiresDpaAcceptance**: `boolean`

Whether an organization must accept the region's DPA before it can be created here.
