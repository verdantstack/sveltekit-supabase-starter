import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    alias: {
      $lib: fileURLToPath(new URL('./src/lib', import.meta.url)),
      // SvelteKit virtual modules. Vitest runs without the SvelteKit Vite
      // plugin, so these are unresolvable by default — stubbing them is what
      // lets a test import a real `+page.server.ts` and assert the HTTP status
      // its action actually returns, instead of re-implementing the action.
      '$app/paths': fileURLToPath(new URL('./tests/helpers/stubs/app-paths.ts', import.meta.url)),
      '$app/environment': fileURLToPath(
        new URL('./tests/helpers/stubs/app-environment.ts', import.meta.url),
      ),
      '$env/static/private': fileURLToPath(
        new URL('./tests/helpers/stubs/env-static-private.ts', import.meta.url),
      ),
      '$env/static/public': fileURLToPath(
        new URL('./tests/helpers/stubs/env-static-public.ts', import.meta.url),
      ),
    },
  },
  test: {
    include: ['src/**/*.test.ts', 'tests/**/*.test.ts'],
    environment: 'node',
    hookTimeout: 30_000,
    testTimeout: 30_000,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      include: ['src/lib/server/**/*.ts'],
      exclude: [
        'src/lib/server/supabase/client.ts',
        // Process bootstrap only — it builds a Supabase client and hands off to stdio.ts,
        // which is covered in-process. A spawned child is invisible to v8 coverage, so its
        // behaviour is proven by the spawn test in tests/mcp.test.ts instead (skipped without
        // credentials, since it needs a reachable Supabase project).
        'src/lib/server/mcp/cli.ts',
        'src/lib/server/email/index.ts',
        'src/lib/server/email/resend.ts',
        'src/lib/server/billing/stripe.ts',
      ],
      thresholds: {
        statements: 95,
        branches: 95,
        functions: 95,
        lines: 95,
      },
    },
  },
});
