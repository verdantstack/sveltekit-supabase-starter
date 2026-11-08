[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: OrgResidency

A tenant's residency as it stands right now.

## Extended by

- [`ResidencyReport`](ResidencyReport.md)

## Properties

### dpaAcceptedAtMs

> **dpaAcceptedAtMs**: `number` \| `null`

When the tenant accepted the region's DPA, or `null` when it needs none.

***

### orgId

> **orgId**: `string`

The organization id.

***

### orgName

> **orgName**: `string`

The organization's name, for the audit metadata and the page heading.

***

### pendingMove

> **pendingMove**: [`RegionMoveView`](RegionMoveView.md) \| `null`

The open change request, if there is one.

***

### policy

> **policy**: [`ResidencyPolicy`](../../../regions/interfaces/ResidencyPolicy.md)

The policy that region implies.

***

### region

> **region**: [`Region`](../../../regions/interfaces/Region.md)

The tenant's region, resolved from the catalogue.
