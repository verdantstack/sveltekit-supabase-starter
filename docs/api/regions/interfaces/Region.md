[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: Region

One region: where it is, what it runs on, and the policy it implies.

## Properties

### code

> `readonly` **code**: `"us-east-1"` \| `"eu-west-1"` \| `"ap-southeast-1"` \| `"ap-southeast-2"`

Stable machine code stored on `organizations.region_code`.

***

### hostingLocation

> `readonly` **hostingLocation**: `string`

Where the data physically lives, as the operator provisioned it.

***

### jurisdiction

> `readonly` **jurisdiction**: `string`

The legal regime the operator asserts applies at this location.

***

### keyAlias

> `readonly` **keyAlias**: `string`

Key-management alias a real deployment would resolve to a regional CMK.
This kit never calls a KMS; the field exists so the seam is named rather
than invented later, and so an operator can point it at their own key.

***

### label

> `readonly` **label**: `string`

Human label, e.g. `EU West (Ireland)`.

***

### note

> `readonly` **note**: `string`

One line on why the policy looks the way it does, for the operator (and
for the compliance reviewer who reads the UI).

***

### policy

> `readonly` **policy**: [`ResidencyPolicy`](ResidencyPolicy.md)

The policy this region implies.

***

### status

> `readonly` **status**: [`RegionStatus`](../type-aliases/RegionStatus.md)

Whether this region accepts new tenants — see [RegionStatus](../type-aliases/RegionStatus.md).
