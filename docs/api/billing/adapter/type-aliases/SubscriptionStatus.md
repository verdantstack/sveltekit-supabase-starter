[**sveltekit-supabase-starter**](../../../README.md)

***

# Type Alias: SubscriptionStatus

> **SubscriptionStatus** = `"none"` \| `"active"` \| `"trialing"` \| `"past_due"` \| `"canceled"`

The lifecycle status of an organization's subscription.

## Remarks

`none` means no plan is attached; `active`/`trialing` are billable;
`past_due` blocks new seats; `canceled` is inactive for new enrollments.
