[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: ResidencyReport

A tenant's residency posture: where it lives, what that commits the operator
to, and whether the tenant is currently inside those commitments.

## Extends

- [`OrgResidency`](OrgResidency.md)

## Properties

### dataClasses

> **dataClasses**: [`DataClassCounts`](DataClassCounts.md)

Row counts per data class.

***

### dpaAcceptedAtMs

> **dpaAcceptedAtMs**: `number` \| `null`

When the tenant accepted the region's DPA, or `null` when it needs none.

#### Inherited from

[`OrgResidency`](OrgResidency.md).[`dpaAcceptedAtMs`](OrgResidency.md#dpaacceptedatms)

***

### egress

> **egress**: `object`

Which outbound paths the region permits, for the UI to explain itself.

#### allowCrossBorderExport

> **allowCrossBorderExport**: `boolean`

#### allowWebhookEgress

> **allowWebhookEgress**: `boolean`

#### pseudonymizeActorIds

> **pseudonymizeActorIds**: `boolean`

***

### erasure

> **erasure**: `object`

The erasure deadline the operator's policy sets for a data-subject request.

#### dsarErasureSlaDays

> **dsarErasureSlaDays**: `number`

***

### notice

> **notice**: `string`

The notice that must travel with the policy values.

***

### orgId

> **orgId**: `string`

The organization id.

#### Inherited from

[`OrgResidency`](OrgResidency.md).[`orgId`](OrgResidency.md#orgid)

***

### orgName

> **orgName**: `string`

The organization's name, for the audit metadata and the page heading.

#### Inherited from

[`OrgResidency`](OrgResidency.md).[`orgName`](OrgResidency.md#orgname)

***

### pendingMove

> **pendingMove**: [`RegionMoveView`](RegionMoveView.md) \| `null`

The open change request, if there is one.

#### Inherited from

[`OrgResidency`](OrgResidency.md).[`pendingMove`](OrgResidency.md#pendingmove)

***

### policy

> **policy**: [`ResidencyPolicy`](../../../regions/interfaces/ResidencyPolicy.md)

The policy that region implies.

#### Inherited from

[`OrgResidency`](OrgResidency.md).[`policy`](OrgResidency.md#policy)

***

### region

> **region**: [`Region`](../../../regions/interfaces/Region.md)

The tenant's region, resolved from the catalogue.

#### Inherited from

[`OrgResidency`](OrgResidency.md).[`region`](OrgResidency.md#region)

***

### retention

> **retention**: `object`

Retention posture for the tenant's audit trail.

#### auditRetentionDays

> **auditRetentionDays**: `number`

The regional commitment, in days.

#### auditRetentionDeadlineMs

> **auditRetentionDeadlineMs**: `number` \| `null`

When that oldest event falls out of the commitment, or `null`.

#### auditRetentionExceeded

> **auditRetentionExceeded**: `boolean`

`true` when the tenant holds an event older than the region's commitment.
This is a report, not a failure: this kit's audit log is append-only, so
the operator prunes on their own schedule and the number tells them when
they are out of step with their own policy.

#### inviteRetentionDays

> **inviteRetentionDays**: `number`

The regional commitment for unaccepted invites, in days.

#### invitesAwaitingPruning

> **invitesAwaitingPruning**: `number`

Unaccepted, unrevoked invites already older than that commitment.

#### oldestAuditEventAtMs

> **oldestAuditEventAtMs**: `number` \| `null`

The oldest audit event the tenant has, or `null` when it has none.
