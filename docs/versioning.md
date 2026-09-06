# Versioning & Release Guide

This document describes the versioning strategy for the SvelteKit + Supabase Starter and how to pick a release.

## Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (SemVer):

- **MAJOR** (`X.0.0`): Incompatible API changes
- **MINOR** (`0.X.0`): New functionality, backwards-compatible
- **PATCH** (`0.0.X`): Backwards-compatible bug fixes

Every release updates:

- `package.json` version field
- `CHANGELOG.md` (Keep a Changelog format)
- A git **tag** (e.g. `v0.1.0`) that backs a GitHub Release

### What Constitutes a Version Bump

| Change Type | Bump | Example |
|-------------|------|---------|
| Breaking change to RBAC matrix | MAJOR | Removing a permission, changing role hierarchy |
| New feature (e.g., real billing adapter) | MINOR | Adding a billing adapter, new API endpoint |
| Bug fix (e.g., invite handling) | PATCH | Fixing behavior without API changes |
| Documentation updates | PATCH | Adding docs, fixing typos |
| Dependency updates (non-breaking) | PATCH | Upgrading Supabase client |

## How to Pick a Version

1. **GitHub Releases page**: `https://github.com/verdantstack/sveltekit-supabase-starter/releases`
   - Each release has a tag (e.g. `v0.1.0`) and release notes from `CHANGELOG.md`.
2. **Clone a specific tag**:
   ```bash
   git clone --branch v0.1.0 https://github.com/verdantstack/sveltekit-supabase-starter.git
   ```
3. **Download a specific version**:
   ```bash
   curl -L https://github.com/verdantstack/sveltekit-supabase-starter/archive/refs/tags/v0.1.0.zip -o starter-v0.1.0.zip
   ```

## Changelog Format

We follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/):

```markdown
## [version] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Vulnerability fixes
```

## Version History

| Version | Date | Summary |
|---------|------|---------|
| 0.2.1 | 2026-08-30 | TSDoc on all public exports + generated API reference (`docs/api`) + docs gate |
| 0.2.0 | 2026-08-29 | Seat-limit fix at invite acceptance; test suite grown 24 → 75 |
| 0.1.0 | 2026-08-29 | Initial release: Supabase RLS, RBAC, invites, seat billing, audit log |

## Links

- [CHANGELOG.md](../CHANGELOG.md)
- [GitHub Releases](https://github.com/verdantstack/sveltekit-supabase-starter/releases)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
