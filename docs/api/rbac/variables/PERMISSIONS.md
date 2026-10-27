[**sveltekit-supabase-starter**](../../README.md)

***

# Variable: PERMISSIONS

> `const` **PERMISSIONS**: readonly \[`"org.view"`, `"org.update"`, `"org.delete"`, `"members.view"`, `"members.invite"`, `"members.remove"`, `"members.role.set"`, `"invites.revoke"`, `"audit.view"`, `"billing.manage"`, `"ownership.transfer"`\]

The complete set of fine-grained permissions in this starter.

Permissions are granted per role via the internal capability matrix and are
checked server-side on every load/action through [requirePermission](../functions/requirePermission.md).
