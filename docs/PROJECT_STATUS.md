# PROJECT_STATUS — OpsPilot

_Last updated: 2026-03-07 08:47 JST_

## Overall Status
- Phase: Foundation Build → Auth Build
- Confidence: High
- Risk: Medium (OAuth wiring + external integrations)

## Active Tasks

### Task 1 — Foundation Setup
- [x] Create Rails 8 app skeleton
- [x] Configure Postgres, Redis, Sidekiq
- [x] Mount Sidekiq dashboard at `/sidekiq`
- [ ] Setup environments + secrets strategy
- [ ] Add CI checks (lint/test)

**Test criteria**
- `bin/rails about` runs clean
- Sidekiq boots and enqueues test job
- DB migrate + rollback works

**Exit criteria**
- Foundation merged on `development`
- Deployment-ready baseline committed

---

### Task 2 — Auth + Workspace Connection
- [x] Add Devise-based user auth scaffolding (email/password + sessions)
- [x] Add Google OAuth callback route/controller wiring
- [x] Add connect/disconnect UX in settings page
- [x] Add `OAuthConnection` model/migration for provider token metadata
- [x] Run DB migrations
- [ ] Run full auth smoke test
- [ ] Add integration tests for Google connect/reconnect/disconnect
- [ ] Persist token data with encryption-at-rest strategy

**Test criteria**
- New user can sign in/out
- Google account can connect and reconnect
- Token refresh path validated

**Exit criteria**
- Connected workspace visible in settings

---

### Task 3 — Inbox Intelligence v1
- [ ] Ingest Gmail threads/messages
- [ ] Classify emails (urgent/lead/reply/admin)
- [ ] Show triage feed in dashboard

**Test criteria**
- Messages sync into DB
- Classification labels available in UI
- Error retries/backoff work

**Exit criteria**
- Dashboard shows prioritized inbox actions

---

### Task 4 — Actions + Drafting
- [ ] Generate draft replies
- [ ] Create follow-up tasks/reminders
- [ ] Manual approve/edit/send flow

**Test criteria**
- Drafts generated for eligible emails
- Follow-up reminders trigger on time
- Approval workflow audit-logged

**Exit criteria**
- End-to-end “email → action” flow demoable

---

### Task 5 — CRM Sync + Daily Brief
- [ ] Upsert leads/opportunities into Google Sheets
- [ ] Generate daily executive briefing

**Test criteria**
- Lead rows appear/update in sheet
- Daily brief contains urgent/follow-up/meeting sections

**Exit criteria**
- Daily brief visible in dashboard and shareable

## Current Blockers / Required Resources
1. Need Google OAuth app creds for end-to-end login/connect testing:
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
   - Redirect URI: `http://localhost:3000/users/auth/google_oauth2/callback`

## Notes
- Human approval mode remains default in MVP.
- No direct work on `main` branch.
- Central command chat acknowledged. Progress updates mirrored to Agent Repo-OpsPilot channel (`-1003793941840`).
