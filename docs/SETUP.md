# OpsPilot Local Setup

## 1) Prerequisites
- Ruby `3.4.2`
- PostgreSQL `16+`
- Redis `7+`

## 2) Start services (macOS/Homebrew)

```bash
brew install postgresql@16 redis
brew services start postgresql@16
brew services start redis
```

## 3) Configure environment variables

Create a `.env` file in project root:

```bash
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

Google OAuth redirect URI (must match Google Cloud Console):

```text
http://localhost:3000/users/auth/google_oauth2/callback
```

## 4) Database bootstrap

```bash
bin/rails db:create db:migrate
```

## 5) Start app

```bash
bin/dev
```

Then open:
- App: http://localhost:3000
- Sidekiq: http://localhost:3000/sidekiq

## 6) OAuth smoke test
1. Sign up with email/password.
2. Open **Settings**.
3. Click **Connect Google**.
4. Approve consent screen.
5. Confirm Google account shows as connected.
6. Click **Disconnect Google** and confirm status resets.
