[**sveltekit-supabase-starter**](../../../README.md)

***

# Function: createBillingAdapter()

> **createBillingAdapter**(): [`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

Create a billing adapter based on environment configuration.
Uses MockBillingAdapter for development/testing.
Invalid/absent MOCK_PLAN_SEATS falls back to the default (3) — a NaN seat
limit would silently allow unlimited joins.

## Returns

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

A configured [BillingAdapter](../../adapter/interfaces/BillingAdapter.md) whose seat limit defaults to 3
  and may be overridden via `MOCK_PLAN_SEATS`.
