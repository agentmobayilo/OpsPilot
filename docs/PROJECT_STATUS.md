# PROJECT_STATUS — OpsPilot

## Overall Status
- Phase: Planning → Foundation Build
- Confidence: High
- Risk: Medium (OAuth + workflow orchestration)

## Active Tasks

### Task 1 — Foundation Setup
- [x] Create Rails 8 app skeleton
- [x] Configure Postgres, Redis, Sidekiq
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
- [ ] Add user auth and session management
- [ ] Implement Google OAuth connect/disconnect
- [ ] Persist account/token metadata securely

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

## Blockers
- None right now.

## Notes
- Human approval mode remains default in MVP.
- No direct work on `main` branch.
