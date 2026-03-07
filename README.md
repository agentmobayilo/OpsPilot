# OpsPilot

AI Executive Copilot for Google Workspace.

## Current stack
- Rails 8.1
- PostgreSQL
- Redis + Sidekiq
- Devise auth
- Google OAuth (connect/disconnect flow)

## Quick start

```bash
bundle install
bin/rails db:create db:migrate
bin/dev
```

App runs at `http://localhost:3000`.

## Docs
- Project status: `docs/PROJECT_STATUS.md`
- Local setup + OAuth config: `docs/SETUP.md`
