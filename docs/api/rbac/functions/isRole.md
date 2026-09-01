[**sveltekit-supabase-starter**](../../README.md)

***

# Function: isRole()

> **isRole**(`value`): value is "owner" \| "admin" \| "member"

Type guard that narrows an arbitrary string to a [Role](../type-aliases/Role.md).

## Parameters

### value

`string`

## Returns

value is "owner" \| "admin" \| "member"

`true` when `value` is one of [ROLES](../variables/ROLES.md), narrowing the type to
  `Role`; `false` otherwise.
