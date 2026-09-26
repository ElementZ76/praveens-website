# Task Plan — B.L.A.S.T.

**Current phase: B — Blueprint** (Praveen designs the schema, then the endpoints)

## Phase 0 — Prep
- [x] Split `portfolio.html` into `frontend/index.html`, `css/styles.css`, `js/main.js`
- [x] `git init` + `.gitignore`
- [x] Project `CLAUDE.md`

## Phase B — Blueprint
- [x] Discovery questions answered (features, stack, database, DB access, frontend, project fields)
- [x] `blueprint.md`, `task_plan.md`, `progress.md` created
- [x] Resume adopted as single source of truth; committed copy without phone in `resume/`
- [ ] Lesson: tables, keys, relationships, constraints → **Praveen designs schema (§5)** → review
- [ ] Lesson: HTTP methods, status codes, REST, error formats → **Praveen designs endpoints (§6)** → review
- [ ] Decide when the resume sync runs (§12.1) and the AIESEC entry quirk (§12.2)
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
- [ ] Flyway migration: manual entries (Prashanthi Delights)
- [ ] Resume parser: LaTeX → plain-text objects, with unit tests on the real resume file
- [ ] Resume sync: one transaction, idempotent, leaves manual rows alone, phone-number guard
- [ ] Read endpoints for each resume section: repository → service → controller → API test
- [ ] Contact: validation → honeypot → rate limit → Problem Details errors → API tests (201, 400, 429)
- [ ] Switch one entity from `JdbcClient` to Spring Data JPA; compare the two
- [ ] Every endpoint matches `blueprint.md` §6

## Phase S — Stylize
- [ ] Port layout and `styles.css` into React components (same design language)
- [ ] Add sections for Education, Experience, Publications, Certifications
- [ ] Load every resume section from the API
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
