-- Data residency: a home region per tenant, the DPA acceptance that goes with
-- it, and the recorded requests to re-home a tenant.
--
-- This migration creates / adds:
-- 1. organizations.region_code      — the tenant's home region (written once)
-- 2. organizations.dpa_accepted_at  — when the region's DPA was accepted, or NULL
-- 3. region_moves                   — the region-change request state machine
-- 4. RLS policies for region_moves
-- 5. Explicit Data API grants for region_moves
--
-- WHY THE REGION IS A COLUMN AND NOT A SETTING
-- --------------------------------------------
-- The value is written once, by `services/orgs.ts:createOrg`, and afterwards only
-- by `services/residency.ts:completeRegionChange` — against an open, owner-requested
-- change. Do not let an ordinary `UPDATE organizations SET …` carry it: a silent
-- re-homing is the exact failure this column exists to make impossible, because
-- nothing about the request or the response would record that the data changed
-- jurisdiction.
--
-- The codes themselves are NOT a table. They live in `src/lib/server/regions.ts`
-- as frozen code, because a row (or a migration) a tenant could influence is how
-- data ends up in a jurisdiction the operator does not run. This column stores a
-- code; the catalogue decides what the code is allowed to do.
--
-- Note on the CHECK below: it names the same four codes the catalogue declares.
-- `tests/residency.test.ts` fails if the two disagree, so a region added to the
-- code without a matching CHECK is caught by the suite rather than by the first
-- tenant whose creation the database refuses.
--
-- WHY region_moves IS A TABLE AND NOT COLUMNS ON organizations
-- ------------------------------------------------------------
-- `requested` → `completed` | `cancelled` is a state machine with history, not a
-- flag. Three of the four failure codes the app must answer need that history:
-- `move_pending` (an open request already exists), `no_pending_move` (the id is
-- not an open request for *this* tenant), and `same_region` (a request to where
-- the tenant already is). A cancelled request has to stay readable afterwards so
-- an operator can answer "who asked to move us, and why did it not happen?" —
-- deleting it on cancel would erase the answer.

-- ============================================================
-- ORGANIZATIONS: home region + DPA acceptance
-- ============================================================
-- The DEFAULT matters for existing rows: an installation that already carries
-- tenants gets them placed in us-east-1, the same region the code's default
-- resolves to, rather than NULL. A NULL region here would be a tenant with no
-- policy at all — refused at read time by `requireRegion()` and therefore with
-- no residency report, no export and no webhook, which is a far worse outcome
-- than a documented default.
ALTER TABLE public.organizations
  ADD COLUMN IF NOT EXISTS region_code TEXT NOT NULL DEFAULT 'us-east-1';
ALTER TABLE public.organizations
  ADD COLUMN IF NOT EXISTS dpa_accepted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_organizations_region ON public.organizations(region_code);

-- A code outside the catalogue is a value no code path can resolve, so refuse it
-- at the only layer that can refuse it cheaply. Retirement of a region is NOT
-- expressed here (that would mean rewriting every tenant's row): a retired region
-- keeps its rows and stops accepting new tenants, which is a fact about the
-- catalogue, not about the column.
ALTER TABLE public.organizations
  DROP CONSTRAINT IF EXISTS organizations_region_code_check;
ALTER TABLE public.organizations
  ADD CONSTRAINT organizations_region_code_check
  CHECK (region_code IN ('us-east-1', 'eu-west-1', 'ap-southeast-1', 'ap-southeast-2'));

-- ============================================================
-- REGION MOVES
-- ============================================================
-- requested_by / cancelled_by are plain UUIDs with no FK, matching audit_log:
-- the record of who asked to move a tenant has to survive that person's account
-- being closed, exactly like the audit trail it accompanies.
CREATE TABLE public.region_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  from_region TEXT NOT NULL,
  to_region TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('requested', 'completed', 'cancelled')),
  requested_by_user_id UUID NOT NULL,
  justification TEXT,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancelled_by_user_id UUID
);

-- The reader is always "this tenant's moves, newest first", and the writer's
-- uniqueness question is "does this tenant have an open request?".
CREATE INDEX IF NOT EXISTS idx_region_moves_org ON public.region_moves(org_id, requested_at DESC);

-- At most one OPEN request per tenant, enforced by the database rather than by
-- the application's read-then-write, which two concurrent owner tabs can both
-- win. A partial unique index is the only place this invariant is race-free;
-- `requestRegionChange()` still checks first so it can answer `move_pending`
-- with a message instead of a constraint violation.
CREATE UNIQUE INDEX IF NOT EXISTS idx_region_moves_one_pending
  ON public.region_moves(org_id) WHERE status = 'requested';

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.region_moves ENABLE ROW LEVEL SECURITY;

-- Every member may see where their tenant lives and any request to move it:
-- `org.region.view` is granted to every role for the same reason.
CREATE POLICY "region_moves_select" ON public.region_moves
  FOR SELECT USING (
    is_org_member(org_id, auth.uid())
  );

-- Only an owner may create a request (`org.region.move` is owner-only).
CREATE POLICY "region_moves_insert" ON public.region_moves
  FOR INSERT WITH CHECK (
    get_org_role(org_id, auth.uid()) = 'owner'
  );

-- Only an owner may complete or cancel one. This policy is the database half of
-- the same rule the service enforces; the service is still the control, because
-- the writes run through the service-role client (see lib/server/tenant.ts).
CREATE POLICY "region_moves_update" ON public.region_moves
  FOR UPDATE USING (
    get_org_role(org_id, auth.uid()) = 'owner'
  );

-- No DELETE policy. A cancelled or completed move is history: it is what lets an
-- operator answer "who asked for this, and what happened to it?" long after the
-- fact. Nothing in this kit deletes a move row.

-- ============================================================
-- DATA API GRANTS (required — see 0001 for why)
-- ============================================================
-- In this file because this file creates the table: `supabase db push`,
-- `supabase db reset` and every preview branch create `region_moves` from here,
-- and from 2026-10-30 a table without these grants answers every request with
-- `42501 permission denied for table region_moves`. `anon` is read-only, and the
-- write privileges match the vendor matrix even though the app's own writes run
-- as service_role — bypassing RLS is not bypassing the privilege system.
GRANT SELECT ON TABLE public.region_moves TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.region_moves TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.region_moves TO service_role;
