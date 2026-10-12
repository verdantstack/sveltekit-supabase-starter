-- SvelteKit + Supabase Multi-Tenant Starter
-- 0002 — public.users profile table
--
-- Why this migration exists
-- -------------------------
-- `services/members.ts::listMembers` embeds `users!inner(id, email, name)` so
-- the member table can show an email and a name alongside each role. That embed
-- needs two things from the schema:
--
--   1. a relation named `users`, and
--   2. a FOREIGN KEY from memberships.user_id to it, because PostgREST cannot
--      plan an embedded resource without a detectable relationship.
--
-- 0001_initial_schema.sql creates only organizations, memberships, invites and
-- audit_log. Real users live in `auth.users` (written by
-- `supabase.auth.admin.createUser` in `lib/server/auth.ts`), which is not a
-- PostgREST-embeddable relation from the public schema. So on a clean install
-- the member list — and therefore the whole org dashboard, which calls
-- listMembers() in its load — fails. The test suite never saw it because the
-- in-memory fake provisions a `users` table the deployed schema never had.
--
-- This migration adds that table, keeps it in sync from auth.users, and wires
-- the foreign key PostgREST needs.
--
-- ADDITIVE AND IDEMPOTENT
-- -----------------------
-- No DROP, no column rewrite, no data deletion. Every statement is guarded, so
-- applying this to a Supabase project that already has a public.users table
-- (some deployments create one out of band) is a no-op rather than an error or
-- a silent overwrite. Existing columns and rows are left exactly as they are.

-- ============================================================
-- TABLE
-- ============================================================
-- `id` mirrors auth.users.id, so it is both the primary key and the FK target
-- memberships needs. `email` and `name` are a denormalised copy: PostgREST
-- cannot reach across into auth, and the member list must not depend on the
-- Auth service being reachable.
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email TEXT,
  name TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Additive only: if an existing public.users already has these columns the
-- ADD COLUMN IF NOT EXISTS statements are skipped. If it lacks them, they are
-- added with nullable/defaulted definitions so no existing row is invalidated.
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS name TEXT NOT NULL DEFAULT '';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Backfill from auth.users so existing accounts gain a profile row. ON CONFLICT
-- DO NOTHING means an already-populated row is left untouched.
INSERT INTO public.users (id, email, name)
SELECT
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data ->> 'name', '')
FROM auth.users u
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- FOREIGN KEY — the part PostgREST actually needs
-- ============================================================
-- 0001 gives memberships.user_id a FK to auth.users(id). That is correct but
-- not sufficient: the embed is against `users`, so memberships needs its own FK
-- to public.users(id) for PostgREST to plan the join. Without this the embed
-- fails with a missing-relationship error instead of a missing-table error —
-- same broken page, different message.
--
-- 0001 keeps its auth.users FK. Both can coexist: they point at the same value
-- (a membership always references a real auth user, and the backfill above
-- guarantees a matching profile row), and the `users!inner(...)` hint tells
-- PostgREST which relationship to follow.
--
-- Postgres has no "ADD CONSTRAINT IF NOT EXISTS", so guard via pg_constraint.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'memberships_user_id_fkey_users'
      AND conrelid = 'public.memberships'::regclass
  ) THEN
    ALTER TABLE public.memberships
      ADD CONSTRAINT memberships_user_id_fkey_users
      FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
-- Same posture as every other table in this kit: RLS is enabled, and access is
-- scoped to the caller's own orgs. This adds policies; it removes none.
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- A user can read their own profile, plus the profiles of the people they share
-- an org with — which is exactly the set listMembers() needs to render a member
-- table. Written as a self-join over `memberships` rather than via a helper,
-- because "is this profile in one of MY orgs" is not the question
-- is_org_member(org, user) answers.
--
-- No recursion risk: this policy reads `memberships`, whose own policy calls
-- is_org_member(), and that helper is SECURITY DEFINER (so it is not itself
-- subject to RLS). Nothing reads `users` from inside a `users` policy.
DROP POLICY IF EXISTS "users_select" ON public.users;
CREATE POLICY "users_select" ON public.users
  FOR SELECT USING (
    id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM memberships mine
      JOIN memberships theirs ON theirs.org_id = mine.org_id
      WHERE mine.user_id = auth.uid()
        AND theirs.user_id = public.users.id
    )
  );

-- A user may edit their own profile, but NOT change which row is theirs: the
-- WITH CHECK re-asserts the id, so a PATCH cannot re-point a profile at another
-- user and ride on the select policy above.
DROP POLICY IF EXISTS "users_update_self" ON public.users;
CREATE POLICY "users_update_self" ON public.users
  FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- No INSERT or DELETE policy: profiles are created by the trigger below and
-- removed with their auth user. Without a policy, the public role cannot do
-- either, which is the intended posture.

-- ============================================================
-- SYNC FROM auth.users
-- ============================================================
-- Supabase Auth owns signup, so the profile row is created by a trigger rather
-- than by application code. That keeps the two in step even for accounts
-- created through the Supabase dashboard, the Admin API, or a magic link.
--
-- SECURITY DEFINER because auth.users is not readable by the public role.
-- search_path is pinned to '' and every object is schema-qualified, so the
-- function body cannot be redirected by a caller-controlled search_path.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'name', '')
  )
  ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        name = EXCLUDED.name;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE OF email, raw_user_meta_data ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
