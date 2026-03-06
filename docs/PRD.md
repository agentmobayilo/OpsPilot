# PRD — OpsPilot (Google Workspace SaaS)

## 1) Product Summary
OpsPilot is an AI executive copilot for Google Workspace that turns inbox activity into action: prioritized email triage, response drafting, follow-up reminders, meeting coordination, and CRM sheet sync.

## 2) Problem
SMB teams run operations in Gmail but miss leads and follow-ups due to manual triage and fragmented tools.

## 3) Goals (MVP)
- Never miss high-value inbound opportunities.
- Reduce time-to-first-response for lead emails.
- Automate follow-up reminders and basic CRM sheet updates.
- Deliver a daily executive briefing.

## 4) Target Users
- Agencies, consultancies, recruiters, clinics, SMB sales teams, founders/EAs on Google Workspace.

## 5) MVP Features
1. Google OAuth connect
2. Inbox Command Center (classification + urgency + lead detection)
3. Smart reply drafts (approve/edit/send)
4. Follow-up engine (task + reminder)
5. CRM Sheet sync (create/update lead rows)
6. Daily briefing (urgent, pending, meetings, blocked)

## 6) Tech Stack
- Backend: Ruby 3.4 + Rails 8
- Frontend: Hotwire (Turbo + Stimulus)
- DB: PostgreSQL
- Jobs: Sidekiq + Redis
- Auth: Omniauth Google OAuth2
- Google Execution Layer: gws CLI process wrapper + service objects
- Billing: Stripe (Pay gem)
- Deploy: Render/Railway/Heroku

## 7) System Design (MVP)
- `GoogleAccount` stores token metadata.
- `GmailSyncJob` ingests threads.
- `EmailClassifierJob` labels messages + scores urgency/lead.
- `DraftReplyJob` generates suggestion.
- `FollowupPlannerJob` schedules reminder task.
- `SheetsSyncJob` upserts lead row.
- `DailyBriefJob` compiles summary.

## 8) Key Data Models
- User
- Workspace
- GoogleAccount
- EmailThread
- EmailMessage
- Lead
- Task
- Followup
- AiActionLog
- DailyBrief
- Subscription

## 9) Success Metrics
- Lead capture rate from inbox
- Median first response time
- Follow-up completion rate
- Daily active users
- Weekly retained workspaces

## 10) Non-Goals (MVP)
- Full CRM replacement
- Multi-provider email (non-Google)
- Complex workflow builder UI

## 11) Risks + Mitigations
- OAuth + token scope complexity → incremental scopes + robust reconnect UX
- AI false positives → confidence thresholds + human approval mode
- API limits → queueing + backoff + observability
