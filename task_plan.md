# Task Plan — B.L.A.S.T.

**Current phase: L — Link** · **Current milestone: M1 — Live skeleton (due Sun 2026-10-11)**

## Deadline

**Launch: Sunday 2026-12-27.** The date is fixed; scope is cut to meet it (decided 2026-09-28).
Budget: ~5 h/week × 13 weeks ≈ 65 h. Estimated work after cuts: ~40–65 h.

| # | Milestone | Weeks | Due (Sunday) | Budget | "Done" means |
|---|---|---|---|---|---|
| M1 | Live skeleton | 1–2 | 2026-10-11 | 10 h | `GET /api/health` returns 200 **on the public URL**, backed by a hosted database |
| M2 | Resume API live | 3–6 | 2026-11-08 | 20 h | `GET /api/resume` on the public URL returns the full resume, synced from `resume/praveens_resume.tex`; API tests pass |
| M3 | Contact API live | 7–8 | 2026-11-22 | 10 h | `POST /api/contact` on the public URL saves messages; 201/400/429 tested |
| M4 | React site live | 9–12 | 2026-12-20 | 20 h | The React site, in the existing design language, shows every resume section from the API and sends contact messages; works at 360 px |
| M5 | Launch | 13 | 2026-12-27 | 5 h | Key end-to-end tests pass, `run_dev.ps1`, README; site shared |

## Rules that keep this from becoming an endless loop

1. **Every milestone ends with something live on the public URL.** Not "almost done locally".
2. **Log hours** in each `progress.md` entry. At each due date, compare hours used vs. budget.
3. **Missed due date → cut, don't extend.** Drop items from the cut list below (top first) until the milestone fits. The launch date does not move.
4. **Timebox:** if one task takes more than 2× its estimate, stop and ask for a simpler approach instead of pushing on.
5. **New ideas go to "Later"** at the bottom of this file, not into the current milestone.
6. **Weeks with no time** (exams, travel): tell Claude in advance; the plan is re-cut, the launch date stays.

**Cut list** (first to go → last): JPA comparison · micro-animations · E2E tests beyond 2 key flows (load page, send message) · loading/empty-state polish.

---

## Phase 0 — Prep ✅
- [x] Split `portfolio.html` into `frontend/index.html`, `css/styles.css`, `js/main.js`
- [x] `git init` + `.gitignore`
- [x] Project `CLAUDE.md`

## Phase B — Blueprint ✅
- [x] Discovery questions answered (features, stack, database, DB access, frontend, project fields)
- [x] `blueprint.md`, `task_plan.md`, `progress.md` created
- [x] Resume adopted as single source of truth; committed copy without phone in `resume/`
- [x] Lesson: tables, keys, relationships, constraints → Praveen's design decisions → schema (§5) agreed
- [x] Lesson: HTTP requests/responses, methods, status codes, JSON → Praveen's decisions → endpoints (§6) agreed
- [x] Resume sync = separate command; AIESEC entry fixed in the resume (updated file pending)
- [x] Invariants final
- [x] **Blueprint approved by Praveen** → APPROVED v1.0

## M1 — Live skeleton (Phase L + early deploy) · due 2026-10-11 · 10 h
- [x] Install JDK 25 (Temurin 25.0.4 via scoop); `JAVA_HOME` points to it
- [x] Spring Boot 4.1.1 (current stable), supports Java 25
- [x] Generate the Spring Boot project in `backend/` (start.spring.io: Web MVC, Validation, JDBC, PostgreSQL driver, Flyway)
- [x] Create local databases `portfolio` + `portfolio_test` and user `portfolio_app` (`backend/scripts/create-local-db.ps1`)
- [x] `.env.example` + config reads DB settings from environment variables
- [x] App starts on port 8081 and Flyway connects to the database
- [x] Commands section of `CLAUDE.md`
- [x] Build fails with a clear message when not on Java 25 (Maven Enforcer)
- [ ] `GET /api/health` returns 200 locally — **Praveen's first code**
- [ ] Choose host for backend + database (and later the frontend)
- [ ] Deploy database + backend; production environment variables set
- [ ] `GET /api/health` returns 200 on the public URL

## M2 — Resume API live (Phase A, part 1) · due 2026-11-08 · 20 h
- [ ] Flyway migration: create tables
- [ ] Flyway migration: manual entries (Prashanthi Delights)
- [ ] Resume parser: LaTeX → plain-text objects, with unit tests on the real resume file
- [ ] Resume sync: one transaction, idempotent, leaves manual rows alone, phone-number guard
- [ ] Resume sync command (runs the parser + sync, outside the web server); run it against production
- [ ] `GET /api/resume`: repositories → service → controller → API test
- [ ] Deployed; `GET /api/resume` matches `blueprint.md` §6 on the public URL
- [ ] *(cut list)* Switch one entity from `JdbcClient` to Spring Data JPA; compare the two

## M3 — Contact API live (Phase A, part 2) · due 2026-11-22 · 10 h
- [ ] Contact: validation → honeypot → rate limit → Problem Details errors
- [ ] API tests (201, 400, 429)
- [ ] Deployed; works on the public URL

## M4 — React site live (Phase S) · due 2026-12-20 · 20 h
- [ ] Vite + React skeleton; Vite proxies `/api` to the backend
- [ ] Port layout and `styles.css` into React components (same design language)
- [ ] Add sections for Education, Experience, Publications, Certifications
- [ ] Load every resume section from the API
- [ ] Contact form → `POST /api/contact`, with honeypot field and labels
- [ ] Loading, error and empty states
- [ ] Responsive down to 360 px
- [ ] Production CORS; frontend deployed
- [ ] *(cut list)* Micro-animations

## M5 — Launch (Phase T) · due 2026-12-27 · 5 h
- [ ] E2E tests for the 2 key flows (page loads with resume data; contact message sent) — tool: Selenium or Playwright
- [ ] `run_dev.ps1` starts database check, backend and frontend together
- [ ] README with setup, run and deploy instructions
- [ ] Final check on the public URL; share the link
- [ ] *(optional)* custom domain

---

## Later (after launch — not in any milestone)
- Admin login + page to read messages
- Email notification on new messages
- Resume PDF download
