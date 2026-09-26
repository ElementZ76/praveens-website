# Task Plan — B.L.A.S.T.

**Current phase: B — Blueprint** (waiting for answers to open questions + approval)

## Phase 0 — Prep
- [x] Split `portfolio.html` into `frontend/index.html`, `css/styles.css`, `js/main.js`
- [x] `git init` + `.gitignore`
- [x] Project `CLAUDE.md`

## Phase B — Blueprint
- [x] Discovery questions answered (features, stack, database, DB access, frontend, project fields)
- [x] `blueprint.md`, `task_plan.md`, `progress.md` created
- [ ] Open questions in `blueprint.md` §11 (items 1–3) answered
- [ ] Schema final
- [ ] Endpoints final
- [ ] Invariants final
- [ ] **Blueprint approved by Praveen** → status changed to APPROVED v1.0

## Phase L — Link
- [ ] Install JDK 25; point the project at it (`JAVA_HOME`)
- [ ] Check the current Spring Boot version and its Java 25 support
- [ ] Generate the Spring Boot project in `backend/` (start.spring.io: Web, Validation, JDBC, PostgreSQL driver, Flyway)
- [ ] Create local database + dedicated DB user (not the `postgres` superuser)
- [ ] `.env.example` + config reads DB settings from environment variables
- [ ] App starts and Flyway connects to the database
- [ ] `GET /api/health` returns 200
- [ ] Vite + React skeleton in the frontend runs
- [ ] Fill in the Commands section of `CLAUDE.md`

## Phase A — Architect
- [ ] Flyway migration: create tables
- [ ] Flyway migration: seed data
- [ ] Skills: repository → service → controller → API test
- [ ] Projects + tags: repository (JOIN) → service → controller → API test
- [ ] Contact: validation → honeypot → rate limit → Problem Details errors → API tests (201, 400, 429)
- [ ] Switch one entity from `JdbcClient` to Spring Data JPA; compare the two
- [ ] Every endpoint matches `blueprint.md` §6

## Phase S — Stylize
- [ ] Port layout and `styles.css` into React components (same design language)
- [ ] Load skills and projects from the API
- [ ] Contact form → `POST /api/contact`, with honeypot field and labels
- [ ] Loading, error and empty states
- [ ] Responsive down to 360 px
- [ ] Micro-animations

## Phase T — Trigger
- [ ] Choose E2E tool; write end-to-end tests
- [ ] `run_dev.ps1` starts database check, backend and frontend together
- [ ] Choose host(s) and domain
- [ ] Deploy database, backend, frontend
- [ ] Production CORS + environment variables set
- [ ] README with setup, run and deploy instructions
