[**sveltekit-supabase-starter**](../../README.md)

***

# Function: getBillingAdapter()

> **getBillingAdapter**(): [`BillingAdapter`](../adapter/interfaces/BillingAdapter.md)

The billing adapter services and routes should consume. Never construct an
adapter anywhere else — go through this function so a real MoR swap is a
one-line change.

## Returns

[`BillingAdapter`](../adapter/interfaces/BillingAdapter.md)

A configured [BillingAdapter](../adapter/interfaces/BillingAdapter.md) for the current environment.
