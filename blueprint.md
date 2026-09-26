# Blueprint — Praveen's Portfolio

> **Status: DRAFT v0.2 — not approved.** Phase L starts only after Praveen approves this file.
> This is the project constitution. If code and blueprint disagree, the blueprint wins. Change this file first, then the code, and add a line to the change log.

---

## 1. Vision

A personal portfolio for Praveen, a CS student working in test automation. Visitors are mainly recruiters and peers.

The backend exists for three reasons:
1. Store messages sent through the contact form.
2. Serve Praveen's resume content (education, skills, experience, projects, publications, certifications) from a database that is kept in sync with the resume.
3. Be Praveen's hands-on project for learning backend development end to end.

## 2. Scope

**In v1**
- Contact form saves messages to the database.
- A resume parser reads `resume/praveens_resume.tex` and syncs its content into the database.
- The website shows every resume section, loaded from the API: Education, Skills, Experience, Projects, Publications, Certifications.
- Manually added entries that are not on the resume (currently: the Prashanthi Delights project).

**Out of v1 (later versions)**
- Admin login and an admin page (until then, messages are read with `psql`).
- Email notification on new messages.
- Blog, visitor analytics, resume PDF download.

## 3. Architecture

```
resume/praveens_resume.tex
  │  resume parser (sync)
  ▼
PostgreSQL  ◄──────────────────────────┐
                                       │  Repository → the only layer that runs SQL
Spring Boot REST API  (/api/*)         │  Service    → business rules (validation, honeypot, rate limit, sync)
  ▲                                    │  Controller → receives the HTTP request, returns the HTTP response
  │  fetch("/api/...") — JSON over HTTP
React app (static files on a host)
  ▲
Browser
```

- **Why three layers:** each layer has one job, so each can be tested and changed on its own. Example: switching one repository from hand-written SQL to JPA changes one class; the controller and service don't notice.
- **Local development:** the Vite dev server forwards (proxies) every `/api/*` request to `http://localhost:8080`. The browser sees one origin, so no CORS setup is needed locally.
- **Repo layout:** `frontend/` (React, Vite), `backend/` (Maven project), `resume/` (resume without phone number), docs at the root.
- Host-independent: nothing may assume a specific hosting provider until Phase T.

## 4. Tech stack

| Part | Choice | Notes |
|---|---|---|
| Language (backend) | Java 25 (LTS) | Installed in Phase L next to the existing Java 22 |
| Framework | Spring Boot | Exact version chosen on start.spring.io in Phase L, must support Java 25 |
| Build tool | Maven 3.9.9 | Already installed |
| Spring modules | Web, Validation, JDBC (`JdbcClient`); later Data JPA | SQL by hand first, JPA later for comparison |
| Migrations | Flyway | Versioned SQL files create and change the schema |
| Database | PostgreSQL 18 | Already installed locally |
| Frontend | React + Vite, JavaScript | Built in Phase S |
| API tests | JUnit 5 + Spring Boot Test + REST Assured | Written alongside each endpoint in Phase A |
| E2E tests | Selenium or Playwright | Chosen in Phase T |

## 5. Data schema — **to be designed by Praveen**

Praveen designs the tables, columns, keys and constraints. Claude teaches the concepts first, then reviews the design. The schema must satisfy these requirements:

**From the resume**
- **Education:** institution, degree, start and end dates, CGPA, location.
- **Skills:** each skill belongs to one category, exactly as named on the resume (currently Languages, Data Formats, Frameworks & Tools, Testing Concepts, Reporting & Tools, Cloud & DevOps). Categories can be added, renamed or removed when the resume changes. The order of categories, and of skills within a category, matches the resume.
- **Experience:** organization, role, start date, end date *or* "Present", location (may be missing), and an ordered list of bullet points.
- **Projects:** name, a list of technologies, an optional GitHub link, and an ordered list of bullet points. Technologies are **not** the same list as skills: many project technologies (AWS, React, Locust, …) are not in the Skills section, and the website's Skills section must match the resume exactly.
- **Publications:** ordered author list (Praveen's name marked), title, venue/conference, status (e.g. "accepted, to be published").
- **Certifications:** a list of names, in resume order.

**Beyond the resume**
- **Manual entries:** some rows are added by hand and are not on the resume (currently the Prashanthi Delights project). The resume sync must never change or delete these rows. The schema needs a way to tell the two apart.
- **Contact messages:** name, email, message text, time received.

**Things to think about while designing**
- Which columns are required and which are optional?
- Which lists need a stored order (the database does not keep insertion order on its own)?
- What makes a row unique, so the parser can tell "this project already exists, update it" from "this is a new project"?
- What should happen to child rows (bullet points) when their parent (a project) is deleted?

## 6. API endpoints — **to be designed by Praveen**

Praveen designs the methods, paths, request/response bodies, status codes and error format. Claude teaches HTTP and REST concepts first, then reviews. The API must let the frontend:

1. Load every resume section shown on the page.
2. Send a contact message, and learn whether it was accepted, rejected (and why, per field), or blocked for sending too many.
3. Check that the backend is running (health check, used by hosting providers and by `run_dev.ps1`).

**Required behavior for the contact message**
- The server validates every field, even if the browser already did: after trimming, name 1–100 characters, email a valid format and at most 254 characters, message 1–5000 characters.
- Honeypot: the form has a field hidden from humans with CSS. Bots fill every field. If it is filled, the server responds exactly as for a real success but stores nothing. A bot must not be able to tell the difference from the response.
- Rate limit: at most 5 messages per IP address per hour.

**Decisions for the endpoint design**
- Resource names and URL structure (one endpoint per section, or one for the whole resume?).
- Status codes for success, invalid input and too many requests.
- One consistent error format across all endpoints (worth reading about: RFC 9457 "Problem Details", which Spring Boot supports).
- JSON naming style (camelCase or snake_case) and date format.
- How the resume sync is triggered (see §7).

## 7. Resume parser (sync)

- **Input:** `resume/praveens_resume.tex` (the committed copy, without phone number).
- **Strict:** it recognizes the template's commands (`\section`, `\resumeSubheading`, `\resumeProjectHeading`, `\resumeItem`, …). If the file contains a structure it does not recognize, it stops with a clear error and **the database is not changed**.
- **Plain text out:** LaTeX markup is converted to plain text before storing (e.g. `\&` → `&`, `` ``…'' `` → "…", `R$^2$` → R², `\textbf{…}` → the text inside).
- **All or nothing:** one sync runs in one database transaction. If any step fails, the whole sync is rolled back.
- **Idempotent:** running the sync twice on the same file gives the same database as running it once. No duplicates.
- **Manual rows are untouched** (see §5).
- **Privacy guard:** if the file contains something that looks like a phone number, the sync refuses to run.
- **Known template quirk:** the AIESEC entry puts its dates in the location slot and leaves the date slot empty. The parser must handle this, or the resume entry should be fixed (see §12).

## 8. Invariants (rules that must always hold)

1. Blueprint first, code second.
2. `resume/praveens_resume.tex` is the single source of truth for education, skills, experience, projects, publications and certifications. The only exceptions are rows explicitly marked as manual entries.
3. The phone number is never committed and never shown on the website.
4. The server validates every input; the browser's checks are only for convenience.
5. The schema changes only through a new Flyway migration file. A migration that has already run is never edited.
6. Controllers never touch the database. Only repositories run SQL.
7. Secrets (DB password etc.) live only in environment variables. `.env` is never committed; `.env.example` lists the variable names with fake values.
8. In production, CORS allows only the site's own frontend origin.
9. The frontend never inserts API data as raw HTML (no `innerHTML`, no `dangerouslySetInnerHTML`).
10. An endpoint is "done" only when its API test passes and it matches §6.

## 9. Design language

Same as the existing site. Full token table and component rules are in `CLAUDE.md` → "Design language". Summary: peach page, cream cards with a purple left border, indigo header/footer bands, purple headings and buttons, Libre Baskerville headings, Helvetica body, 800px centered column.

## 10. Non-functional requirements

- API responses under 300 ms on a local machine.
- Every form input has a real `<label>` (not only a placeholder), so screen readers can read it.
- Layout works down to 360 px wide (small phones) with no sideways scrolling.
- If the API is down, the site still shows its layout with a clear "couldn't load" message instead of empty sections.

## 11. Working agreement

| Phase | Who does what |
|---|---|
| B — Blueprint | **Praveen designs the schema (§5) and endpoints (§6)**; Claude teaches the concepts first, then reviews. Claude drafts the rest; Praveen decides and approves. |
| L — Link | Claude sets up tools and explains each step; Praveen runs the key commands. |
| A — Architect | **Praveen writes the code**, including the resume parser. Claude explains, gives steps and hints, reviews. |
| S — Stylize | Praveen leads the React work; Claude guides and reviews. |
| T — Trigger | Together. |

## 12. Open questions

1. When does the resume sync run: at backend startup, as a separate command, or during deployment? (Decide while designing §6.)
2. AIESEC entry: fix the resume so dates are in the date slot like the other entries, or make the parser handle it?
3. Hosting provider and domain name — Phase T.
4. E2E test tool — Phase T.

## 13. Change log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-09-26 | First draft from discovery answers. |
| 0.2 | 2026-09-26 | Resume becomes the single source of truth; added all resume sections, resume parser (§7) and manual-entry exception. Schema (§5) and endpoints (§6) cleared: Praveen designs them. |
