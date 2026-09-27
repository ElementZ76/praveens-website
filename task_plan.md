# Task Plan — B.L.A.S.T.

**Current phase: L — Link** (blueprint approved v1.0 on 2026-09-27)

## Phase 0 — Prep
- [x] Split `portfolio.html` into `frontend/index.html`, `css/styles.css`, `js/main.js`
- [x] `git init` + `.gitignore`
- [x] Project `CLAUDE.md`

## Phase B — Blueprint
- [x] Discovery questions answered (features, stack, database, DB access, frontend, project fields)
- [x] `blueprint.md`, `task_plan.md`, `progress.md` created
- [x] Resume adopted as single source of truth; committed copy without phone in `resume/`
- [x] Lesson: tables, keys, relationships, constraints → Praveen's design decisions → schema (§5) agreed
- [x] Lesson: HTTP requests/responses, methods, status codes, JSON → Praveen's decisions → endpoints (§6) agreed
- [x] Resume sync = separate command; AIESEC entry fixed in the resume (updated file pending)
- [x] Invariants final
- [x] **Blueprint approved by Praveen** → APPROVED v1.0

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
- [ ] Resume sync command (runs the parser + sync, outside the web server)
- [ ] `GET /api/resume`: repositories → service → controller → API test
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
