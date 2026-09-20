-- SvelteKit + Supabase Multi-Tenant Starter
-- Initial schema with RLS policies for multi-tenancy
--
-- This migration creates:
-- 1. Organizations table
-- 2. Memberships table (with role-based access)
-- 3. Invites table (single-use, hashed tokens)
-- 4. Audit log (append-only)
-- 5. RLS policies for tenant isolation
--
-- Supabase Auth handles users and sessions (auth.users, auth.sessions)

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
