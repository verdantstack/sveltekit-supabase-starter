# Usage-Based Billing & AI Token Management

This kit ships a **seat-based** `BillingAdapter` for subscription billing. If your product usage-based pricing — AI token consumption, API calls, storage, compute — this guide shows how to extend the adapter pattern.

## Why usage-based billing?

Traditional SaaS pricing (per-seat subscriptions) doesn't work for AI-powered products where costs scale with usage. Usage-based billing lets you:

- Charge per AI token (input + output)
- Charge per API call, per GB stored, per compute second
- Offer tiered pricing with included usage + overages
- Pass through provider costs (OpenAI, Anthropic, etc.) with a margin

## The adapter pattern

Your kit already has a `BillingAdapter` interface. Extend it for usage tracking:

```ts
// src/lib/server/billing/adapter.ts

export interface BillingAdapter {
  /** Stable identifier (e.g., 'stripe', 'mock'). */
  readonly name: string;

  // --- Existing seat-based methods ---
  getPlan(orgId: string): Promise<PlanState>;
  getSeatCount(orgId: string): Promise<number>;
  assertSeatAvailable(orgId: string, currentSeats: number): Promise<void>;

  // --- Add usage-based methods ---
  /** Record token consumption for an org. */
  recordUsage(input: UsageRecord): Promise<void>;

  /** Get current period usage for an org. */
  getUsage(orgId: string, period: UsagePeriod): Promise<UsageSummary>;

  /** Check if an org has exceeded its usage limit. */
  checkUsageLimit(orgId: string): Promise<UsageLimitResult>;
}

export interface UsageRecord {
  orgId: string;
  service: string;        // e.g., 'openai', 'anthropic', 'custom'
  model: string;          // e.g., 'gpt-4o', 'claude-sonnet-4-20250514'
  inputTokens: number;
  outputTokens: number;
  metadata?: Record<string, unknown>;
}

export interface UsagePeriod {
  start: Date;
  end: Date;
}

export interface UsageSummary {
  orgId: string;
  period: UsagePeriod;
  totalInputTokens: number;
  totalOutputTokens: number;
  totalCost: number;      // in cents
  byService: Record<string, number>;
  byModel: Record<string, number>;
}

export interface UsageLimitResult {
  allowed: boolean;
  currentUsage: number;
  limit: number;
  message?: string;
}
```

## Implementation: database schema

Add a `usage_log` table to track consumption:

```sql
-- drizzle/0002_usage_log.sql (or add to existing migration)

CREATE TABLE usage_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id),
  service TEXT NOT NULL,           -- 'openai', 'anthropic', 'custom'
  model TEXT NOT NULL,             -- 'gpt-4o', 'claude-sonnet-4-20250514'
  input_tokens INTEGER NOT NULL,
  output_tokens INTEGER NOT NULL,
  cost_cents INTEGER NOT NULL,     -- calculated cost in cents
  metadata_json TEXT,              -- flexible metadata
  created_at BIGINT NOT NULL       -- Unix epoch ms
);

CREATE INDEX usage_log_org_id ON usage_log(org_id);
CREATE INDEX usage_log_created_at ON usage_log(created_at);
CREATE INDEX usage_log_org_period ON usage_log(org_id, created_at);
```

## Implementation: recording usage

```ts
// src/lib/server/billing/usage.ts

import { sql } from 'drizzle-orm';
import type { UsageRecord, UsageSummary, UsagePeriod } from './adapter';

/**
 * Calculate cost from token counts. Customize per model/provider.
 */
function calculateCost(record: UsageRecord): number {
  const pricing: Record<string, { input: number; output: number }> = {
    'gpt-4o': { input: 2.50, output: 10.00 },           // per 1M tokens
    'gpt-4o-mini': { input: 0.15, output: 0.60 },
    'claude-sonnet-4-20250514': { input: 3.00, output: 15.00 },
    'claude-haiku': { input: 0.25, output: 1.25 },
  };

  const rates = pricing[record.model] ?? { input: 1.00, output: 3.00 };
  const inputCost = (record.inputTokens / 1_000_000) * rates.input;
  const outputCost = (record.outputTokens / 1_000_000) * rates.output;

  return Math.ceil((inputCost + outputCost) * 100); // cents
}

/**
 * Record AI token usage for an org.
 */
export async function recordUsage(
  db: Db,
  record: UsageRecord
): Promise<void> {
  const costCents = calculateCost(record);

  await db.execute(sql`
    INSERT INTO usage_log (id, org_id, service, model, input_tokens, output_tokens, cost_cents, created_at)
    VALUES (gen_random_uuid(), ${record.orgId}, ${record.service}, ${record.model},
            ${record.inputTokens}, ${record.outputTokens}, ${costCents},
            ${Date.now()})
  `);
}

/**
 * Get usage summary for an org in a given period.
 */
export async function getUsageSummary(
  db: Db,
  orgId: string,
  period: UsagePeriod
): Promise<UsageSummary> {
  const startMs = period.start.getTime();
  const endMs = period.end.getTime();

  const rows = await db.execute(sql`
    SELECT
      COALESCE(SUM(input_tokens), 0) as total_input,
      COALESCE(SUM(output_tokens), 0) as total_output,
      COALESCE(SUM(cost_cents), 0) as total_cost
    FROM usage_log
    WHERE org_id = ${orgId}
      AND created_at >= ${startMs}
      AND created_at < ${endMs}
  `);

  return {
    orgId,
    period,
    totalInputTokens: Number(rows[0]?.total_input ?? 0),
    totalOutputTokens: Number(rows[0]?.total_output ?? 0),
    totalCost: Number(rows[0]?.total_cost ?? 0),
    byService: {},  // aggregate in a real implementation
    byModel: {},    // aggregate in a real implementation
  };
}
```

## Integration with AI providers

### OpenAI example

```ts
// src/lib/server/ai/openai.ts

import OpenAI from 'openai';
import { recordUsage } from '../billing/usage';

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export async function chatCompletion(
  db: Db,
  orgId: string,
  messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[]
) {
  const response = await client.chat.completions.create({
    model: 'gpt-4o',
    messages,
  });

  const usage = response.usage;
  if (usage) {
    await recordUsage(db, {
      orgId,
      service: 'openai',
      model: response.model,
      inputTokens: usage.prompt_tokens,
      outputTokens: usage.completion_tokens,
    });
  }

  return response.choices[0].message;
}
```

### Anthropic example

```ts
// src/lib/server/ai/anthropic.ts

import Anthropic from '@anthropic-ai/sdk';
import { recordUsage } from '../billing/usage';

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export async function chatCompletion(
  db: Db,
  orgId: string,
  messages: Anthropic.MessageParam[]
) {
  const response = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 4096,
    messages,
  });

  await recordUsage(db, {
    orgId,
    service: 'anthropic',
    model: response.model,
    inputTokens: response.usage.input_tokens,
    outputTokens: response.usage.output_tokens,
  });

  return response.content;
}
```

## Usage limits and overages

```ts
// src/lib/server/billing/usage-limits.ts

export async function checkUsageLimit(
  db: Db,
  orgId: string
): Promise<UsageLimitResult> {
  const plan = await getPlan(db, orgId);
  const usage = await getUsageSummary(db, orgId, getCurrentPeriod());

  const limit = plan.usageLimitCents ?? Infinity;
  const currentUsage = usage.totalCost;

  if (currentUsage >= limit) {
    return {
      allowed: false,
      currentUsage,
      limit,
      message: `Usage limit reached. Current: $${(currentUsage / 100).toFixed(2)}, Limit: $${(limit / 100).toFixed(2)}`,
    };
  }

  return { allowed: true, currentUsage, limit };
}
```

## Dashboard: display usage to users

```svelte
<!-- src/routes/app/org/[id]/+page.svelte -->
<script>
  let { data } = $props();
  const { usage } = data;
</script>

<div class="usage-card">
  <h3>Usage this period</h3>
  <div class="stats">
    <div>
      <span class="label">Input tokens</span>
      <span class="value">{usage.totalInputTokens.toLocaleString()}</span>
    </div>
    <div>
      <span class="label">Output tokens</span>
      <span class="value">{usage.totalOutputTokens.toLocaleString()}</span>
    </div>
    <div>
      <span class="label">Total cost</span>
      <span class="value">${(usage.totalCost / 100).toFixed(2)}</span>
    </div>
  </div>

  {#if usage.totalCost > usage.limit * 0.8}
    <p class="warning">Approaching usage limit</p>
  {/if}
</div>
```

## Third-party usage-based billing platforms

If you need metered billing at scale, consider these platforms:

| Platform | Best for | Pricing |
|----------|----------|---------|
| [Stripe Billing](https://stripe.com/billing) | Usage-based subscriptions | 0.5% of revenue |
| [Metronome](https://metronome.com) | AI/infrastructure billing | Custom |
| [Orb](https://useorb.com) | Usage-based billing infrastructure | Custom |
| [Lemon Squeezy](https://lemonsqueezy.com) | Simple usage billing | 5% + 50¢ |

## Further reading

- [Stripe: Usage-based billing](https://docs.stripe.com/billing/subscriptions/usage-based)
- [Metronome: AI token billing](https://docs.metronome.com/)
- [Deloitte: AI tokenomics for CFOs](https://www2.deloitte.com/)
- [a16z: You are not a model, don't price per token](https://a16z.com/)
