import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    alias: {
      $lib: fileURLToPath(new URL('./src/lib', import.meta.url)),
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
