# Progress Log

Newest entry on top. One entry per working session.
Template: **Done** · **Errors** (exact message → fix) · **Learned** · **Next**

---

## 2026-11-02 (continued) — M1: hosting decision, Dockerfile, test database

**Done**
- Hosting decided (blueprint v1.3), all free: **Render** runs the backend from a Docker image, **Neon** hosts PostgreSQL, **Vercel** will host the React frontend in M4. Paid hosting (~$5/month) ruled out.
- Vercel was considered for the backend and rejected: it runs short-lived functions (JavaScript, Python, Go, …), not a Java server that stays running.
- Working agreement changed (option A): Claude writes the resume parser and sync command. Praveen writes repositories, services, controllers and their tests. Praveen's focus: architecting the backend and connecting it to the frontend.
- `backend/Dockerfile` (two stages: JDK builds the jar, JRE runs it as a non-root user) + `.dockerignore` (keeps `.env` out of images). Not built locally: Docker isn't installed. Render's first build is the test.
- Tests now use `portfolio_test`, via `backend/src/test/resources/config/application.properties`. Verified in the Flyway log: `Database: jdbc:postgresql://localhost:5432/portfolio_test`. `.\mvnw.cmd test` → 1 test, 0 failures.

**Errors**
- None.

**Learned**
- A host has to match the kind of program it runs. Static files and short functions → Vercel. A server process that stays running → Render or similar.
- Free web services sleep when idle. The first request after a sleep is slow (cold start).
- Spring Boot reads `classpath:/config/application.properties` after `classpath:/application.properties`, so a file there on the test classpath overrides settings for tests only.

**Hours:** 0.25

**Next**
- Praveen creates Render + Neon accounts (Sign in with GitHub).
- Neon: create the database. Render: connect the repo, set root directory `backend`, set `DB_*` variables, deploy. Check `GET /api/health` on the public URL. M1 done.
- Re-plan M2–M5 dates: M1 is 3 weeks late and M2 is due 2026-11-08. The parser moving to Claude frees most of the M2 budget.

---

## 2026-11-02 — Tooling: VS Code cleanup

**Done**
- Moved from Antigravity (kept crashing) to VS Code and cleaned it up. Backup of the old setup: `%USERPROFILE%\vscode-backup-2026-11-02\`.
- New VS Code profile **Portfolio** for this repo: Red Hat Java, Maven, Java debugger + test runner, Spring Boot pack, SQLTools + PostgreSQL driver, GitLens, Error Lens, spell checker, HTML/CSS, Claude Code. Hover on, autocomplete off.
- **Default** profile kept for DSA practice (Python/Jupyter/Colab, C/C++, SQL Server/MySQL): autocomplete and hover off.
- Removed: Oracle Java, Code Runner, Java upgrade/Azure migration tools, Gradle, IntelliCode, Flutter/Dart, duplicate git-history extensions, Live Server, Markdown Preview Enhanced, snippet packs. Dead settings removed (Copilot, Oracle JDK 22 path, Dart, missing icon theme).
- `.vscode/settings.json` (gitignored): Java tools use JDK 25 (`java.configuration.runtimes`); Maven sidebar uses `mvnw.cmd`.
- Removed the leftover `.github/modernize/` folder from the Java upgrade extension (moved into the backup).
- Committed Praveen's `HealthController` (`GET /api/health` → `200 {"status":"UP"}`, matches blueprint §6), written in an earlier session. `.\mvnw.cmd test` passes.

**Errors**
- Two Java language servers (Oracle's and Red Hat's) were active at once, and Oracle's pointed at JDK 22 (`jdk.jdkhome: c:\Oracle_JDK-22`). → Removed Oracle's extension; Red Hat's uses JDK 25.
- `code --profile Portfolio --install-extension ...` → `Profile 'Portfolio' not found.` A profile must exist before extensions can be installed into it, and `code --profile Portfolio <folder>` did not create it because that folder was already open (VS Code just focused that window). → Created it by opening an empty folder with `--profile`, then switched this project's window to the profile.

**Learned**
- A VS Code profile is a named set of extensions and settings; each folder remembers its profile. One profile per tech stack keeps each window light.
- Strange duplicate errors in an editor usually mean two extensions are doing the same job.
- Ctrl+K, Ctrl+I shows a hover once, even when hover is switched off.

**Hours:** 0.5

**Next**
- M1 is overdue (due 2026-10-11): choose host, deploy, `GET /api/health` on the public URL.
- M2 is due 2026-11-08 and not started: decide cuts.
- Tests currently connect to the `portfolio` database, not `portfolio_test`. Fix before M2 tests write data.

---

## 2026-09-28 — Planning: deadline

**Done**
- Estimated remaining work (~47–77 h full, ~40–65 h after cuts).
- Set the deadline: **launch 2026-12-27**, fixed date, scope is cut to meet it. ~5 h/week.
- Milestones M1–M5 with due dates, hour budgets and "done" definitions in `task_plan.md`.
- Deploy early: skeleton goes live in M1 (due 2026-10-11). Blueprint v1.2.

**Errors**
- Praveen's terminal ran `mvnw.cmd spring-boot:run` on Java 22 → `UnsupportedClassVersionError ... class file version 69.0 ... up to 66.0`. The terminal session predates the JDK 25 install, so it lacked the new `JAVA_HOME`; `mvnw.cmd` fell back to Oracle 22 on PATH. → Set `$env:JAVA_HOME` from the saved user setting, or restart the terminal app. Maven Enforcer check proposed.

**Learned**
- Environment variable changes only reach programs started afterwards; already open terminals keep the old values.
- Class file version 69 = Java 25, 66 = Java 22.

**Hours:** — (start logging from the next session)

**Next**
- M1: Enforcer check (pending OK), Praveen writes `GET /api/health`, choose host, deploy.

---

## 2026-09-27 (continued) — Phase L (Link)

**Done**
- Spring Boot 4.1.1 confirmed as current stable (start.spring.io), supports Java 25.
- Installed Temurin JDK 25.0.4 via scoop; `JAVA_HOME` points to it. Oracle Java 22 stays first on the system PATH (left alone on purpose; we always go through Maven).
- Generated `backend/` (Maven, Java 25, Web MVC, Validation, JDBC, PostgreSQL, Flyway, package `io.github.elementz76.portfolio`). Maven Wrapper pins Maven 3.9.16.
- Local DB: `portfolio` + `portfolio_test`, owned by login `portfolio_app` (not a superuser). Random password in gitignored `backend/.env`; template in `.env.example`; setup script `backend/scripts/create-local-db.ps1` (Praveen ran it with the `postgres` password).
- Backend starts, connects to PostgreSQL (HikariCP), Flyway creates `flyway_schema_history`. `GET /api/health` → 404 (no controller yet — expected).
- Working agreement: Claude runs all setup commands.

**Errors**
- `Port 8080 was already in use` → held by the `PEMHTTPD-x64` service (Postgres Enterprise Manager, installed with EDB PostgreSQL). Backend moved to `server.port=${PORT:8081}`; blueprint v1.1.
- Maven 3.9.9 printed "restricted method" warnings on Java 25 → gone with the wrapper's Maven 3.9.16.

**Learned**
- Startup order: settings → connection pool (proves DB access) → Flyway → web server.
- A dedicated non-superuser DB login limits damage from bugs or attacks (least privilege).
- A port can only be held by one program; `Get-NetTCPConnection -LocalPort N` shows who holds it.

**Next**
- Praveen writes the first controller: `GET /api/health` → `200 {"status":"UP"}`.

---

## 2026-09-27 (continued) — Phase B (Blueprint): endpoints + approval

**Done**
- HTTP lesson (request/response, GET vs POST, status codes, JSON).
- Endpoints agreed in `blueprint.md` §6: `GET /api/health`, `GET /api/resume` (one call for the whole page), `POST /api/contact` (201 / 400 / 429), Problem Details error format with a per-field `errors` list.
- Resume sync decided as a separate command (no HTTP endpoint). AIESEC entry to be fixed in the resume itself.
- **Blueprint approved: v1.0.** Phase B complete.

**Learned**
- The JSON sent to the frontend is shaped for the page, not copied from the table (no `id`/`position`/`source`; authors as `{name, self}` objects).
- PostgreSQL arrays count from 1, JavaScript from 0: converting in one place avoids off-by-one bugs.
- The API sends data (URLs, `"2026-01"`, `null`); the frontend decides how to display it.

**Next**
- Phase L: check Spring Boot version, install JDK 25, generate the backend project.

---

## 2026-09-27 — Phase B (Blueprint): schema

**Done**
- Schema lesson (tables, types, keys, constraints, relationships, order, natural keys, normalization).
- Praveen's design answers reviewed; schema agreed in `blueprint.md` §5 (v0.3): 7 tables, no foreign keys, upsert sync, `source` column for manual rows, `NULL` end date = ongoing.
- Simplified step by step on Praveen's questions: bullets → arrays, skills → array on `skill_categories`, authors → array + `self_author` on `publications`.
- Working agreement updated: Praveen makes design decisions, Claude writes the SQL/spec from them; explanations use resume data and small row examples.

**Errors**
- `blueprint.md` was overwritten on disk by the old v0.1 (likely an editor tab saving a stale copy). Praveen restored it with `git restore blueprint.md`.
- `CHECK (... array_length(authors, 1))` would let an empty list through: `array_length` of an empty array is `NULL`, and a `CHECK` that evaluates to `NULL` passes. → Use `cardinality(authors)`, which returns 0.

**Learned**
- Rows in a table have no guaranteed order; items inside an array keep theirs.
- Foreign key goes on the "many" side; a foreign key can reference only one table.
- A list of plain display values can be an array; items with their own facts need a table.
- `CHECK` only rejects when the condition is `false`, not when it is `NULL`.

**Next**
- HTTP/REST lesson → Praveen's decisions for the endpoints (§6).

---

## 2026-09-26 (continued) — Phase B (Blueprint)

**Done**
- First commit `d238b97`; Praveen linked the GitHub remote and renamed the branch to `main`.
- Resume adopted as the single source of truth for site content. Copied to `resume/praveens_resume.tex` with the phone line removed; the original (with phone) is gitignored.
- Decisions: sync via a strict `.tex` parser; Praveen designs the schema and the endpoints; Prashanthi Delights stays as a manual exception.
- `frontend/js/main.js`: projects now match the resume (Flipkart removed; Enterprise Test Automation Framework, Proactive Cloud Autoscaling, FuelTrack Webapp) + Prashanthi Delights.
- `blueprint.md` v0.2: §5 and §6 turned into requirements for Praveen's design; new §7 resume parser.

**Errors**
- `sed` pattern to remove the phone line matched nothing: the resume uses Windows line endings (CRLF), so each line ends in `\r` before `$`. → Copied the file as is and edited the line directly; `diff` confirmed only that line changed.

**Learned**
- If the resume is the source of truth, the database is a *copy* and needs an automatic sync, or the two drift apart.
- Line endings differ between Windows (CRLF) and Linux/macOS (LF); text tools can trip on this.

**Next**
- Schema lesson → Praveen designs §5.

---

## 2026-09-26 — Phase 0 (Prep) + Phase B (Blueprint)

**Done**
- Split `portfolio.html` into `frontend/index.html`, `frontend/css/styles.css`, `frontend/js/main.js`. Diffed against the original: CSS and JS identical, HTML identical apart from the two new `<link>`/`<script src>` lines. Checked in headless Chrome: styles load, 6 skills + 4 projects render, footer year shows. Deleted `portfolio.html`.
- `git init`, `.gitignore` (Java/Maven, Node/Vite, `.env` secrets).
- Project `CLAUDE.md` (design language, working agreement, BLAST rules).
- Discovery decisions: v1 = contact messages + projects/skills from DB; Java 25 + Spring Boot + Maven; PostgreSQL; JdbcClient first, then JPA; React (Vite) in Phase S; hosting decided in Phase T.
- Drafted `blueprint.md` v0.1, `task_plan.md`, this log.

**Errors**
- Claude in Chrome extension not connected → verified with headless Chrome instead. "Read more" toggle and form validation messages were not click-tested (their code is unchanged byte for byte).

**Environment found**
- Java 22.0.1 (not LTS; to be replaced by 25 for this project), Maven 3.9.9, Node 22.14.0 / npm 11.12.1, PostgreSQL 18.6 (psql), Git 2.47.1. No Docker.

**Learned**
- Separating HTML (structure), CSS (look) and JS (behavior) into files lets the browser cache each one and lets each change independently.
- A blueprint written before code makes "done" testable: each endpoint is checked against the table in §6.

**Next**
- Answer `blueprint.md` §11 open questions 1–3, review the whole blueprint, approve → Phase L.
