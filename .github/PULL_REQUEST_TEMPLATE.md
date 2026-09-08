## Description

<!-- Briefly describe what this PR does. -->

## Type of Change

<!-- Check the one that applies. -->

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)

## How Has This Been Tested?

<!-- Describe the tests you ran. Include test commands and output. -->

```bash
npm test
npm run check
npm run build
```

## Checklist

- [ ] My code follows the project's architecture (routes → services → supabase)
- [ ] I have added tests that prove my fix/feature works
- [ ] All new and existing tests pass (`npm test`)
- [ ] `svelte-check` passes with no errors (`npm run check`)
- [ ] I have not added external service dependencies beyond Supabase
- [ ] Every write path produces an audit entry
- [ ] I have not broken the RBAC hierarchy rules
- [ ] RLS policies are consistent with application-level enforcement
