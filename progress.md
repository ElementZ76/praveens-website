# Progress Log

Newest entry on top. One entry per working session.
Template: **Done** · **Errors** (exact message → fix) · **Learned** · **Next**

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
