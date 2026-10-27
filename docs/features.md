# Feature map (31 shipped features)

| Feature | Service / Route |
|---|---|
| Password reset | `src/lib/server/services/password-reset.ts`, `/auth/reset-password` |
| Email verification | `src/lib/server/services/email-verification.ts` |
| User profile/settings | `src/routes/app/settings/` |
| Dark mode toggle | theme toggle in layout |
| Legal pages (privacy/terms) | `src/routes/legal/` |
| Org lifecycle (update/delete) | `src/lib/server/services/orgs.ts` |
| Account deletion/GDPR | `src/lib/server/services/account.ts` |
| Waitlist | `src/routes/waitlist/`, `src/lib/server/services/waitlist.ts` |
| Shared rate limiter | `src/lib/server/ratelimit.ts` |
| Webhook management | `src/routes/app/webhooks/`, `src/lib/server/services/webhooks.ts` |
| In-app notifications | `src/routes/app/notifications/`, `src/lib/server/services/notifications.ts` |
| File upload/storage | `src/routes/app/files/`, `src/lib/server/services/files.ts` |
| API keys | `src/routes/app/api-keys/`, `src/lib/server/services/api-keys.ts` |
| Audit retention/SIEM export | `src/routes/app/audit-retention/`, `src/lib/server/services/audit-retention.ts` |
| User impersonation | `src/routes/app/impersonate/`, `src/lib/server/services/impersonation.ts` |
| Session security hardening | `src/lib/server/services/sessions.ts` |
| Blog/content system | `src/routes/blog/`, `src/lib/server/services/blog.ts` |
| OpenAPI docs | `src/routes/api-docs/` |
| Landing pages | `src/routes/landing/` |
| i18n (4 locales) | `src/lib/i18n/` (en/es/fr/de) |
| MFA/2FA (TOTP) | `src/routes/app/mfa/`, `src/lib/server/services/mfa.ts` |
| OAuth/social login | `src/lib/server/services/oauth.ts` |
| Stripe billing adapter | `src/lib/server/billing/stripe.ts` |
| Usage-based billing | `src/lib/server/services/usage-billing.ts` |
| Affiliate/referral system | `src/lib/server/services/affiliates.ts` |
| Admin dashboard | `src/routes/app/admin/` |
| E2E testing (Playwright) | `e2e/` |
| AI SDK integration | `src/lib/server/ai/` |
