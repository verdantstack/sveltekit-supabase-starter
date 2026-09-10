[**sveltekit-supabase-starter**](../../README.md)

***

# Variable: ROLES

> `const` **ROLES**: readonly \[`"owner"`, `"admin"`, `"member"`\]

The ordered set of roles in this starter.

Order implies rank, with `owner` (rank 2) > `admin` (rank 1) > `member`
(rank 0). The rank mapping drives every hierarchy check — see
[mayActOn](../functions/mayActOn.md) and [mayGrant](../functions/mayGrant.md).
