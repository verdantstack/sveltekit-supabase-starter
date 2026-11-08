# Data residency — multi-region tenants, per-region processing policy

A tenant's data lives in **one** region, and that region's policy decides what the
application is willing to do with it. This document covers the model, every
control it enforces, and — deliberately — what it does **not** do.

> **Read this first.** The policy values shipped in `src/lib/server/regions.ts`
> are a defensible starting configuration, **not legal advice**. Retention,
> erasure-SLA and transfer settings differ by contract and by statute, and they
> are yours to set with counsel. Every value is in one file, on purpose:
> [`POLICY_REVIEW_NOTICE`](../src/lib/server/regions.ts) travels with the numbers
> into the UI so a reader is never told they are authoritative.

This is the Supabase edition of the feature. The catalogue and every rule below
are the same as the SQLite edition's; what differs is the storage
(PostgREST tables in `supabase/migrations/`, not Drizzle) and the absence of a
client-side transaction — see [§5](#5-storage-concurrency-and-what-a-crash-leaves-behind).

---

## 1. The model

| Concept               | Where it lives                                  | Why                                                                                                        |
| --------------------- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Region catalogue**  | `src/lib/server/regions.ts` (code, frozen)      | A table would let a tenant pick a jurisdiction the operator does not run                                   |
| **Policy per region** | `Region.policy` in the same file                | One registry = one answer to "what does this region enforce?"                                              |
| **Tenant's region**   | `organizations.region_code`                     | Written once at creation; afterwards only by an applied region change                                      |
| **DPA acceptance**    | `organizations.dpa_accepted_at` (`TIMESTAMPTZ`) | A timestamp, not a boolean: a reviewer asks _when_, and "yes" cannot be reconciled with a contract version |
| **Change requests**   | `region_moves`                                  | Attributable, reviewable, and applies at most once                                                         |

All four arrive in `supabase/migrations/0003_residency.sql`. The codes are
**not** a table: adding a jurisdiction is a reviewed deploy, not an `INSERT`.

### Shipped regions

| Code             | Location                      | Jurisdiction                        | Status    | DPA required | Cross-border export | Webhook egress | Exports pseudonymised |
| ---------------- | ----------------------------- | ----------------------------------- | --------- | :----------: | :-----------------: | :------------: | :-------------------: |
| `us-east-1`      | AWS us-east-1, N. Virginia    | United States (state statutes vary) | active    |      no      |       allowed       |    allowed     |          no           |
| `eu-west-1`      | AWS eu-west-1, Ireland        | EU/EEA — GDPR                       | active    |   **yes**    |     **refused**     |  **refused**   |        **yes**        |
| `ap-southeast-1` | AWS ap-southeast-1, Singapore | Singapore — PDPA 2012               | active    |   **yes**    |     **refused**     |    allowed     |        **yes**        |
| `ap-southeast-2` | AWS ap-southeast-2, Sydney    | Australia — Privacy Act 1988 (Cth)  | **pilot** |     yes      |       refused       |    refused     |          no           |

Retention windows: `us-east-1` 1095 / 30 / 45, `eu-west-1` 730 / 14 / 30,
`ap-southeast-1` 365 / 14 / 30, `ap-southeast-2` 2555 / 14 / 30
(audit-retention / invite-retention / DSAR-erasure days).

`us-east-1` is the default. **The default is the permissive region on purpose**: a
kit whose `createOrg()` demanded a DPA signature for every buyer on the first call
would teach them to pass a flag they do not understand. Set `REGION_DEFAULT` to
your primary region and the strict one becomes the default — that is a deploy-time
decision, not a code change.

`ap-southeast-1` is the row that proves the policy is not "strict vs permissive":
it requires a DPA, refuses cross-border export and pseudonymises identifiers, yet
**allows webhook egress**.

`ap-southeast-2` ships as `pilot` to make one behaviour visible: **a region that is
not accepting new tenants still serves the tenants already in it, and refuses both
new organizations and in-flight moves into it.**

---

## 2. What the policy actually enforces

Every field in `ResidencyPolicy` is consumed somewhere. A field that is not
enforced anywhere is a marketing claim, and this kit does not ship those.

| Control                                                                              | Enforced by                                                                        | Refusal code                                     | HTTP    |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------------------------------ | ------- |
| No tenant may be created in a `pilot`/`retired` region                               | `regions.resolveNewOrgRegion` ← `services/orgs.ts:createOrg`                       | `region_not_accepting`                           | 400     |
| No tenant may be created in a region whose DPA it has not accepted                   | same                                                                               | `dpa_required`                                   | 400     |
| An unknown region is never silently defaulted                                        | `regions.requireRegion`                                                            | `unknown_region`                                 | 400     |
| A tenant cannot be committed to a move into a region requiring a DPA nobody accepted | `services/residency.ts:requestRegionChange`                                        | `dpa_required`                                   | 400     |
| Tenant events cannot be exported to another region unless the **origin** allows it   | `services/residency.ts:exportOrgAudit` ← `routes/app/org/[id]/audit/export`        | `cross_border_blocked`                           | **403** |
| A tenant cannot stream events off-platform where the region forbids it               | `services/residency.ts:assertWebhookEgress` ← `services/webhooks.ts:createWebhook` | `egress_blocked`                                 | **403** |
| Identifiers leave pseudonymised where the region requires it                         | `exportOrgAudit` + `regions.pseudonymizeActorId`                                   | — (transform)                                    | —       |
| The region changes only through a recorded, reviewed request                         | `requestRegionChange` / `completeRegionChange`                                     | `same_region`, `move_pending`, `no_pending_move` | 400     |
| A misconfigured `REGION_DEFAULT` is loud, not silent                                 | `regions.defaultRegionCode`                                                        | `bad_default_region`                             | **500** |

Two of those deserve a note.

**The export gate reads the origin's policy, not the destination's.** A tenant in
`eu-west-1` cannot escape its own policy by addressing an export to `us-east-1`.
Addressing an export to the tenant's _own_ region is always allowed — nothing
crossed a border. The destination is the `destination` query parameter of
`/app/org/[id]/audit/export`.

**`bad_default_region` is not registered in `http.ts`.** Every other code is
mapped so the browser gets a meaningful status. This one is absent on purpose: it
is an operator misconfiguration, the user cannot fix it, and echoing it as a 400
would tell them to try again. It surfaces as a logged 500 instead. That registry —
and the fact that an _unregistered_ code is never echoed — is what
`tests/http.test.ts` and `tests/residency.test.ts` pin.

---

## 3. Pseudonymised exports

Where `pseudonymizeActorIds` is set, the export replaces `actorUserId` with
`psn_` + 32 hex characters of `sha256("residency:<region>:<userId>")`.

- **Stable**, so an auditor comparing two exports of the same tenant can still
  follow one actor across them. A random or per-export salt would destroy the
  audit trail it was meant to protect.
- **Region-scoped**, so the same person does not pseudonymise to the same value in
  two regions, and an outsider holding both files cannot join them.
- **Marked** with the `psn_` prefix, so nobody downstream mistakes a
  pseudonymised file for a real identifier list. The response also carries
  `x-residency-pseudonymized: true|false` — a recipient of two exports cannot
  infer it from the contents, because both files are full of ids.

Pseudonymisation is applied _after_ the rows are read and _before_ the single CSV
writer runs (`audit.ts:auditRowsToCsv`), so the formula-injection guard and RFC
4180 escaping still apply. There is one CSV writer in this kit, not two.

---

## 4. Changing a tenant's region

**This kit does not move data.** Copying a tenant's rows across a jurisdiction is
an operator-run migration, and a starter kit that flipped a column and called it a
residency change would be worse than one that says so out loud.

What the kit does is make the decision attributable and impossible to fake:

1. **Request** — an owner (`org.region.move`) records `from`, `to`, a reason, and
   — where the destination demands it — the DPA acceptance. Refused if a request
   is already open, if the target is not `active`, or if the destination's DPA has
   not been accepted. **Nothing moves.** The page says so, and so does the audit
   row: `org.region.change_requested`.
2. **Apply** — after the operator has copied the rows out of band, the owner
   completes the request. That call flips `organizations.region_code`, closes the
   request, and writes `org.region.change_completed` with the from/to pair and the
   account that applied it.
3. **Or cancel** — the request is closed (`cancelled`) and the tenant stays where
   it was. The row is kept, not deleted: "who asked to move us, and why did it not
   happen?" is a question an operator gets asked afterwards.

Re-validated at apply time, not only at request time: a region can be retired
while a request is open, and applying the move would strand the tenant in the one
place it must not be.

The UI is [`/app/org/[id]/region`](../src/routes/app/org/%5Bid%5D/region/+page.svelte);
every role can read it (`org.region.view` — where a member's data is processed is
a fact about _their_ data, not an admin detail), only an owner can act on it
(`org.region.move`).

### Tenancy

`region_moves` carries RLS policies in the migration that creates it: `SELECT` to
org members, `INSERT`/`UPDATE` to owners, and no `DELETE` policy at all. The page
reads through the RLS-scoped client (`requireTenantClient`); the writes run as the
service role like every other write in this kit, with `actorRole` re-derived on
every action. RLS is the backstop, not the control.

---

## 5. Storage, concurrency, and what a crash leaves behind

PostgREST has no multi-statement transaction, so the three writes of an apply are
sequential. The order is chosen so the **interrupted** state is the readable one:

1. `organizations.region_code` — the tenant moves. This is the write that must not
   be lost.
2. `region_moves.status = 'completed'` — the request closes.
3. the `org.region.change_completed` audit row.

A crash between 1 and 2 leaves an open request that already matches the tenant's
row: every reader sees the truth (the tenant is in the new region, and a request is
still open), and a retry completes it. The reverse order would leave a move
recorded as completed while the tenant had not moved — a state no reader could
distinguish from a lie. `audit()` in this kit is deliberately non-throwing; it logs
loudly, so a lost audit row is a logging failure rather than a half-applied move.

The one-open-request rule is enforced twice. `requestRegionChange()` checks first,
so it can answer `move_pending` with a message; migration `0003` adds a partial
unique index — `UNIQUE (org_id) WHERE status = 'requested'` — so two concurrent
owner tabs cannot both win the read-then-write.

---

## 6. The report

`residencyReport()` — rendered on the same page — returns row counts per data
class plus the retention posture:

- `oldestAuditEventAtMs`, and `auditRetentionDeadlineMs` = oldest + the region's
  `auditRetentionDays`;
- `auditRetentionExceeded` when the tenant holds an event past that commitment;
- `invitesAwaitingPruning` — unaccepted, unrevoked invites older than
  `inviteRetentionDays` (invites carry an email address, so they are the
  shortest-lived personal data in the schema);
- `dsarErasureSlaDays` — the deadline a data-subject request runs against.

Both retention figures are **reported, not enforced**. The audit log is
append-only by construction — there is no UPDATE or DELETE path anywhere — and a
kit that quietly deleted a compliance trail on a timer would be trading the feature
it sells for the one it measures. Your pruning job reads these numbers.

---

## 7. Configuration

| Variable         | Default     | Effect                                                                                                                                           |
| ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `REGION_DEFAULT` | `us-east-1` | Region a new organization lands in when the caller names none. Validated against the catalogue; an unknown value throws rather than falling back |

Nothing else is configurable at runtime, by design: the region catalogue is code,
so adding a jurisdiction is a reviewed deploy and not an `INSERT`.

---

## 8. Adding a region

1. Add the code to `REGION_CODES` and an entry to `CATALOGUE` in
   `src/lib/server/regions.ts`.
2. `tests/residency.test.ts` fails if the two disagree, if a policy window is not a
   positive integer, if the catalogue is not frozen, or if a shipped policy value
   drifts.
3. **Add the code to the `CHECK` constraint in
   `supabase/migrations/0003_residency.sql`.** The database refuses a
   `region_code` the constraint does not list, so a region that exists only in
   code would fail at the first `INSERT` rather than at the first read.
4. If the new region introduces a policy field that nothing consumes, either wire
   it to an enforcement point or leave it out. See §2.
5. Provision it for real: a row in the catalogue is a claim about where data is
   processed. Point `keyAlias` at your own regional key, and do not deploy a
   region you have not stood up.

---

## 9. What this does **not** do

Said plainly, because the failure mode of a residency feature is a buyer believing
more than the code delivers:

- **It does not move or copy data**, and it does not verify that a migration
  happened. §4.
- **It is not per-table routing.** There is one database; the region is a recorded
  fact about the tenant, and physical placement is the operator's job (a Supabase
  project per region, selected at deploy time).
- **It does not encrypt per region.** `keyAlias` names the seam; no KMS is called.
- **It does not redact metadata inside audit rows.** `metadata_json` can carry
  tenant-supplied values; if your policy needs those redacted, that is a
  per-field decision at the write site, not something this module can infer.
- **It is not a legal opinion.** §0.
