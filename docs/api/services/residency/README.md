[**sveltekit-supabase-starter**](../../README.md)

***

# services/residency

Data-residency policy enforcement for a Supabase-backed multi-tenant deployment.

## Interfaces

- [AuditExport](interfaces/AuditExport.md)
- [DataClassCounts](interfaces/DataClassCounts.md)
- [OrgResidency](interfaces/OrgResidency.md)
- [RegionMoveView](interfaces/RegionMoveView.md)
- [ResidencyReport](interfaces/ResidencyReport.md)

## Functions

- [assertTargetRegion](functions/assertTargetRegion.md)
- [assertWebhookEgress](functions/assertWebhookEgress.md)
- [cancelRegionChange](functions/cancelRegionChange.md)
- [completeRegionChange](functions/completeRegionChange.md)
- [exportOrgAudit](functions/exportOrgAudit.md)
- [getOrgResidency](functions/getOrgResidency.md)
- [listRegionChanges](functions/listRegionChanges.md)
- [recordAuditExport](functions/recordAuditExport.md)
- [requestRegionChange](functions/requestRegionChange.md)
- [residencyReport](functions/residencyReport.md)
