[**sveltekit-supabase-starter**](../../README.md)

***

# Type Alias: RegionStatus

> **RegionStatus** = `"active"` \| `"pilot"` \| `"retired"`

Whether a region may take on new tenants.

- `active` — normal; new organizations may be created here.
- `pilot` — running, existing tenants keep working, but **no new tenant**
  may be homed here. Used for a region that is being validated before it is
  sold.
- `retired` — being drained. Existing tenants must move out; new tenants
  refused, and a pending move *into* it is refused at completion time.
