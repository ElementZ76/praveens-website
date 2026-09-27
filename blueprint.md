# Blueprint — Praveen's Portfolio

> **Status: DRAFT v0.3 — not approved.** Phase L starts only after Praveen approves this file.
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

## 5. Data schema

Decided by Praveen through the design questions; SQL written by Claude and reviewed together.

**Design decisions**
- **Sync strategy: upsert.** Each resume entry is matched to its row by a natural key (the `UNIQUE` columns below), then inserted or updated. After the upserts, resume rows whose key was not in the file are deleted.
- **Natural keys:** education = institution + degree · skill category = name · experience = organization + role · project = name · publication = title · certification = name.
- **Manual rows:** `projects.source` is `'RESUME'` or `'MANUAL'`. The sync only touches `'RESUME'` rows. If a manual project later appears on the resume, the upsert switches it to `'RESUME'`.
- **Dates:** month precision, stored as the 1st of the month (`Jun. 2023` → `2023-06-01`). `end_date` is `NULL` while ongoing; the frontend shows "Present".
- **Order:** every list shown on the resume has a stored `position` (the database keeps no order on its own). Lists stored as arrays keep their order inside the array.
- **Arrays vs tables:** a list of plain values that is only displayed is an array (`technologies`, `bullets`, `skills`, `authors`). Items keep their order inside an array, so arrays need no `position`. A list whose items carry their own facts would need its own table; none do today. A fact about the whole list is a column on the row (`self_author` marks which author is Praveen).

**Tables** (PostgreSQL)

```sql
CREATE TABLE education (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institution VARCHAR(150) NOT NULL,
    degree      VARCHAR(200) NOT NULL,
    cgpa        NUMERIC(4,2) CHECK (cgpa BETWEEN 0 AND 10),
    location    VARCHAR(100),
    start_date  DATE NOT NULL,
    end_date    DATE,                                   -- NULL = ongoing
    position    INT  NOT NULL,
    UNIQUE (institution, degree),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE skill_categories (
    id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     VARCHAR(50) NOT NULL UNIQUE,               -- "Frameworks & Tools"
    skills   TEXT[]      NOT NULL DEFAULT '{}',         -- in resume order
    position INT         NOT NULL
);

CREATE TABLE experiences (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organization VARCHAR(150) NOT NULL,
    role         VARCHAR(150) NOT NULL,
    location     VARCHAR(100),
    start_date   DATE   NOT NULL,
    end_date     DATE,                                  -- NULL = "Present"
    bullets      TEXT[] NOT NULL DEFAULT '{}',
    position     INT    NOT NULL,
    UNIQUE (organization, role),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE projects (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         VARCHAR(150) NOT NULL UNIQUE,
    technologies TEXT[]       NOT NULL DEFAULT '{}',
    bullets      TEXT[]       NOT NULL DEFAULT '{}',
    github_url   VARCHAR(500),
    source       VARCHAR(10)  NOT NULL DEFAULT 'RESUME' CHECK (source IN ('RESUME', 'MANUAL')),
    position     INT          NOT NULL
);

CREATE TABLE publications (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       VARCHAR(300) NOT NULL UNIQUE,
    authors     TEXT[]       NOT NULL,                  -- in the order printed on the paper
    self_author INT          NOT NULL,                  -- which author is Praveen (1 = first)
    venue       VARCHAR(200) NOT NULL,
    status      VARCHAR(100),
    position    INT          NOT NULL,
    CHECK (self_author BETWEEN 1 AND cardinality(authors))   -- cardinality('{}') = 0, so an empty list is rejected
);

CREATE TABLE certifications (
    id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     VARCHAR(200) NOT NULL UNIQUE,
    position INT NOT NULL
);

-- Written by visitors; never touched by the resume sync.
CREATE TABLE contact_messages (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    email      VARCHAR(254)  NOT NULL,
    message    VARCHAR(5000) NOT NULL,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

**Connections:** none. Every table stands alone: each resume entry is complete in one row, with its lists stored as arrays. If a future feature needs linked data (e.g. admin users → sessions), it gets foreign keys then.

**Seed data:** the manual Prashanthi Delights project (`source = 'MANUAL'`) is inserted by a Flyway migration. Everything else comes from the resume sync.

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
| B — Blueprint | Claude teaches the concepts first. Praveen makes the design decisions for the schema (§5) and endpoints (§6); Claude writes the SQL/spec from those decisions, and Praveen questions and approves it. Claude drafts the rest. |
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
| 0.3 | 2026-09-27 | Schema (§5) agreed: upsert sync with natural keys, `source` column for manual rows, NULL end date = ongoing, bullets, technologies, skills and authors as arrays (`self_author` marks Praveen). 7 tables, no foreign keys. |
