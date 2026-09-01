# Billing wiring (seat-based, merchant-of-record)

## Why an adapter

```mermaid
graph TB
    subgraph APP["Application Code"]
        INVITE["acceptInvite()"]
    end

    subgraph SEAM["BillingAdapter Interface"]
        ASSERT["assertSeatAvailable()"]
        SEATC["getSeatCount()"]
        PLAN["getPlan()"]
    end

    subgraph MOCK["MockBillingAdapter (dev)"]
        M_ASSERT["compares against<br/>MOCK_PLAN_SEATS"]
        M_SEAT["returns count"]
        M_PLAN["returns mock plan"]
    end

    subgraph FUTURE["Real MoR Adapter (production)"]
        F_ASSERT["subscriptions table<br/>webhook-synced"]
        F_SEAT["query subscriptions"]
        F_PLAN["query subscriptions"]
    end

    INVITE --> ASSERT
    ASSERT --> MOCK
    ASSERT -.->|"swap one line"| FUTURE
    SEATC --> MOCK
    SEATC -.-> FUTURE
    PLAN --> MOCK
    PLAN -.-> FUTURE

    classDef app fill:#e3f2fd,stroke:#1565c0
    classDef seam fill:#fff3e0,stroke:#ef6c00
    classDef mock fill:#e8f5e9,stroke:#2e7d32
    classDef future fill:#f3e5f5,stroke:#7b1fa2

    class INVITE app
    class ASSERT,SEATC,PLAN seam
    class M_ASSERT,M_SEAT,M_PLAN mock
    class F_ASSERT,F_SEAT,F_PLAN future
```

Checkout runs through a **Merchant of Record** (Lemon Squeezy / Paddle / Payhip are the usual candidates): the MoR becomes the legal seller of record and handles sales tax, so you don't register as a merchant in every jurisdiction your customers live in. Which MoR you pick is swappable by design — the product must not depend on that choice, so all payment knowledge sits behind:

```ts
// src/lib/server/billing/adapter.ts
export interface BillingAdapter {
	assertSeatAvailable(orgId: string, currentMemberCount: number): Promise<void>;
	getSeatCount(orgId: string): Promise<number>;
	getPlan(orgId: string): Promise<{ planId: string; seatLimit: number }>;
}
```

Everything else in the codebase consumes the interface. Today it's satisfied by `MockBillingAdapter` (`MOCK_PLAN_SEATS` seats, default 3). Wiring point: `src/lib/server/billing/mock.ts` `createBillingAdapter()` — swap one function, change nothing else.

## Where enforcement happens

```mermaid
flowchart LR
    INVITE["Owner sends<br/>invite"] --> ACCEPT["Member clicks<br/>invite link"]
    ACCEPT --> COUNT["COUNT(memberships)<br/>for org"]
    COUNT --> GATE{"seatsUsed<br/>≥ planSeats?"}
    GATE -->|"❌ at limit"| BLOCK["BillingError<br/>'upgrade or free<br/>a seat'"]
    GATE -->|"✅ seats available"| CLAIM["Single-use<br/>UPDATE (atomic)"]
    CLAIM --> AUDIT["audit_log entry<br/>+ membership created"]

    style GATE fill:#fff3e0,stroke:#ef6c00
    style BLOCK fill:#ffcdd2,stroke:#c62828
    style AUDIT fill:#e8f5e9,stroke:#2e7d32
```

Exactly one gate: **invite acceptance** (`acceptInvite`). The service counts current memberships for the org and calls `assertSeatAvailable(orgId, count)` before the single-use claim. Inviting beyond the seat count is allowed on purpose — the limit surfaces at accept time as an actionable error ("upgrade or free a seat"), which is also how most incumbents behave and what beta testers expect to see.

Counting rule v0.1: `seatsUsed = COUNT(memberships)` for the org.

## What the real adapter must do

1. `assertSeatAvailable`: compare `currentMemberCount` (passed by the caller) against the org's plan seat limit; throw `BillingError('seat_limit', …)` when full.
2. `getSeatCount`: return the org's current seat usage (for admin screens and pre-flight checks).
3. `getPlan`: return the org's plan id + seat limit from a `subscriptions` table keyed by orgId and kept in sync by MoR webhooks.
4. Webhook endpoint (new route, outside auth guard): verify signature → update the local subscription row. Never trust client-side success redirects for entitlements.
5. Keep `MockBillingAdapter` as the default under `NODE_ENV=development` so tests/dev stay hermetic.

## Error contract

`BillingError` carries machine codes (`seat_limit` | `no_plan` | `adapter_error`). The service layer translates `seat_limit` into a clear, actionable rejection at invite-accept time — never a silent drop.