-- SvelteKit + Supabase Multi-Tenant Starter
-- Initial schema with RLS policies for multi-tenancy
--
-- This migration creates:
-- 1. Organizations table
-- 2. Memberships table (with role-based access)
-- 3. Invites table (single-use, hashed tokens)
-- 4. Audit log (append-only)
-- 5. RLS policies for tenant isolation
-- 6. Explicit Data API grants for every table created above
--
-- Supabase Auth handles users and sessions (auth.users, auth.sessions)
--
-- WHY THE GRANT BLOCK AT THE END OF THIS FILE IS NOT OPTIONAL
-- ----------------------------------------------------------
-- From 2026-10-30, Supabase stops automatically granting Data API access to
-- tables newly created in the `public` schema, on existing projects too. A table
-- created after that date is reachable only if the GRANT is present; without it
-- PostgREST answers every request for it with
--   `42501 permission denied for table <name>`
-- even though the table, its RLS policies and the service-role key are all
-- correct. `supabase db push`, a fresh `supabase db reset`, and every preview
-- branch create these tables from this file, so all three would ship a broken
-- install.
--
-- That is why the grants live in this file rather than in a later one: the
-- privilege has to exist in the same transaction that creates the table, so no
-- install path can run the CREATE without the GRANT. Putting it in a separate
-- migration would re-create exactly the gap this is meant to close — an install
-- that stops between the two files.
--
-- The matrix below mirrors Supabase's documented default for new tables, so
-- behaviour after the change matches behaviour before it. Existing tables are
-- unaffected: the new default applies only to tables created on or after the
-- effective date, and installations that already ran this migration keep the
-- grants they already hold.
--
-- RLS is unchanged by this. Table privileges decide whether a role may touch a
-- table at all; RLS policies still decide which rows it sees. Both apply.

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for slug lookups (used in URL routing)
CREATE INDEX idx_organizations_slug ON organizations(slug);

-- ============================================================
-- MEMBERSHIPS
-- ============================================================
-- role ∈ 'owner' | 'admin' | 'member' — validated in application code
CREATE TABLE memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'member')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(org_id, user_id)
);

CREATE INDEX idx_memberships_org ON memberships(org_id);
CREATE INDEX idx_memberships_user ON memberships(user_id);

-- ============================================================
-- INVITES
-- ============================================================
-- token_hash = encode(sha256(token), 'hex')
-- The raw token is shown once, never stored.
CREATE TABLE invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'member')),
  email TEXT, -- optional "intended recipient" note
  invited_by UUID NOT NULL REFERENCES auth.users(id),
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_at TIMESTAMPTZ,
  accepted_by UUID,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_invites_org ON invites(org_id);
CREATE INDEX idx_invites_token ON invites(token_hash);

-- ============================================================
-- AUDIT LOG
-- ============================================================
-- Append-only by design: no UPDATE/DELETE path exists.
-- org_id/actor_user_id are plain text (no FK) so history
-- survives member/org removal.
CREATE TABLE audit_log (
  seq BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  org_id UUID,
  actor_user_id UUID,
  action TEXT NOT NULL,
  target_type TEXT,
  target_id TEXT,
  metadata_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_org_seq ON audit_log(org_id, seq);

-- ============================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================
-- These policies enforce multi-tenancy at the database level.
-- Application code also enforces RBAC, but RLS provides defense-in-depth.

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Helper function: check if user is member of an org
CREATE OR REPLACE FUNCTION is_org_member(org_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM memberships
    WHERE org_id = org_uuid AND user_id = user_uuid
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper function: get user's role in an org
CREATE OR REPLACE FUNCTION get_org_role(org_uuid UUID, user_uuid UUID)
RETURNS TEXT AS $$
  SELECT role FROM memberships
  WHERE org_id = org_uuid AND user_id = user_uuid
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper function: check if user has minimum role rank
-- owner=2, admin=1, member=0
CREATE OR REPLACE FUNCTION has_min_role(org_uuid UUID, user_uuid UUID, min_role TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM memberships
    WHERE org_id = org_uuid
      AND user_id = user_uuid
      AND (
        (role = 'owner')
        OR (role = 'admin' AND min_role != 'owner')
        OR (role = 'member' AND min_role = 'member')
      )
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================
-- ORGANIZATIONS POLICIES
-- ============================================================
-- Users can only see organizations they belong to
CREATE POLICY "org_select" ON organizations
  FOR SELECT USING (
    is_org_member(id, auth.uid())
  );

-- Any authenticated user can create an organization
CREATE POLICY "org_insert" ON organizations
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
  );

-- Only owners can update org settings
CREATE POLICY "org_update" ON organizations
  FOR UPDATE USING (
    get_org_role(id, auth.uid()) = 'owner'
  );

-- Only owners can delete orgs
CREATE POLICY "org_delete" ON organizations
  FOR DELETE USING (
    get_org_role(id, auth.uid()) = 'owner'
  );

-- ============================================================
-- MEMBERSHIPS POLICIES
-- ============================================================
-- Users can see memberships for orgs they belong to
CREATE POLICY "memberships_select" ON memberships
  FOR SELECT USING (
    is_org_member(org_id, auth.uid())
  );

-- Only owners/admins can add members (via invite acceptance)
CREATE POLICY "memberships_insert" ON memberships
  FOR INSERT WITH CHECK (
    has_min_role(org_id, auth.uid(), 'admin')
    OR auth.uid() = user_id -- users can accept invites for themselves
  );

-- Only owners can update member roles
CREATE POLICY "memberships_update" ON memberships
  FOR UPDATE USING (
    get_org_role(org_id, auth.uid()) = 'owner'
  );

-- Owners/admins can remove members (except last owner)
CREATE POLICY "memberships_delete" ON memberships
  FOR DELETE USING (
    has_min_role(org_id, auth.uid(), 'owner')
  );

-- ============================================================
-- INVITES POLICIES
-- ============================================================
-- Users can see invites for orgs they belong to
CREATE POLICY "invites_select" ON invites
  FOR SELECT USING (
    is_org_member(org_id, auth.uid())
  );

-- Owners/admins can create invites
CREATE POLICY "invites_insert" ON invites
  FOR INSERT WITH CHECK (
    has_min_role(org_id, auth.uid(), 'admin')
  );

-- Owners/admins can revoke invites
CREATE POLICY "invites_update" ON invites
  FOR UPDATE USING (
    has_min_role(org_id, auth.uid(), 'admin')
  );

-- ============================================================
-- AUDIT LOG POLICIES
-- ============================================================
-- Users can see audit logs for orgs they belong to
CREATE POLICY "audit_select" ON audit_log
  FOR SELECT USING (
    is_org_member(org_id, auth.uid())
  );

-- Only the application (service role) can insert audit entries
-- Regular users cannot insert directly
CREATE POLICY "audit_insert" ON audit_log
  FOR INSERT WITH CHECK (
    true -- service role bypasses RLS
  );

-- No UPDATE or DELETE policies — append-only by design

-- ============================================================
-- DATA API GRANTS (required — see the header for why)
-- ============================================================
-- One block per table, covering every table this file creates. Each statement
-- is idempotent: re-running a GRANT for a privilege a role already holds is a
-- no-op in Postgres, so `supabase db reset` and preview branches are safe.
--
-- `service_role` needs real privileges too. It bypasses RLS, but bypassing RLS
-- is not the same as bypassing the privilege system — without the GRANT below,
-- this kit's own admin writes fail with 42501.
--
-- `audit_log` is granted UPDATE/DELETE to match the vendor matrix, even though
-- this kit never writes either. It does not weaken append-only: RLS is enabled
-- and there is no UPDATE or DELETE policy, so those operations match zero rows
-- for every non-bypassing role. The application-role grant is there so the table
-- behaves like every other table; the guarantee is still the missing policy.
--
-- `anon` gets SELECT only. It is a signed-out visitor: it may read what RLS
-- allows and may not write anything.

-- organizations
GRANT SELECT ON TABLE public.organizations TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.organizations TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.organizations TO service_role;

-- memberships
GRANT SELECT ON TABLE public.memberships TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.memberships TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.memberships TO service_role;

-- invites
GRANT SELECT ON TABLE public.invites TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.invites TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.invites TO service_role;

-- audit_log (append-only is enforced by the absence of UPDATE/DELETE policies,
-- not by withholding table privileges — see the note above)
GRANT SELECT ON TABLE public.audit_log TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.audit_log TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.audit_log TO service_role;

-- waitlist_entries
CREATE TABLE public.waitlist_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.waitlist_entries TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.waitlist_entries TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.waitlist_entries TO service_role;

-- rate_limit_entries
CREATE TABLE public.rate_limit_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL,
  timestamp_ms BIGINT NOT NULL
);

GRANT SELECT ON TABLE public.rate_limit_entries TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.rate_limit_entries TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.rate_limit_entries TO service_role;

-- webhooks
CREATE TABLE public.webhooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  secret TEXT NOT NULL,
  events TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.webhooks TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.webhooks TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.webhooks TO service_role;

-- notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  org_id UUID REFERENCES public.organizations(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  body TEXT,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.notifications TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.notifications TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.notifications TO service_role;

-- files
CREATE TABLE public.files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size_bytes BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.files TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.files TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.files TO service_role;

-- api_keys
CREATE TABLE public.api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  key_hash TEXT NOT NULL,
  prefix TEXT NOT NULL,
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  revoked_at TIMESTAMPTZ
);

GRANT SELECT ON TABLE public.api_keys TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.api_keys TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.api_keys TO service_role;

-- blog_posts
CREATE TABLE public.blog_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  content TEXT NOT NULL,
  published BOOLEAN NOT NULL DEFAULT false,
  author_id UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.blog_posts TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.blog_posts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.blog_posts TO service_role;

-- usage_records
CREATE TABLE public.usage_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  metric TEXT NOT NULL,
  quantity BIGINT NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.usage_records TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.usage_records TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.usage_records TO service_role;

-- affiliates
CREATE TABLE public.affiliates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  code TEXT NOT NULL UNIQUE,
  clicks BIGINT NOT NULL DEFAULT 0,
  conversions BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON TABLE public.affiliates TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.affiliates TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.affiliates TO service_role;
