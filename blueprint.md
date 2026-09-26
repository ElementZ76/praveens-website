# Blueprint — Praveen's Portfolio

> **Status: DRAFT v0.1 — not approved.** Phase L starts only after Praveen approves this file.
> This is the project constitution. If code and blueprint disagree, the blueprint wins. Change this file first, then the code, and add a line to the change log.

---

## 1. Vision

A personal portfolio for Praveen, a CS student working in test automation. Visitors are mainly recruiters and peers.

The backend exists for three reasons:
1. Store messages sent through the contact form.
2. Serve the projects and skills shown on the page from a database, instead of hard-coding them in JavaScript.
3. Be Praveen's hands-on project for learning backend development end to end.

## 2. Scope

**In v1**
- Contact form saves messages to the database.
- Skills and projects (with tech tags) are loaded from the database through the API.

**Out of v1 (later versions)**
- Admin login and an admin page (until then, messages are read with `psql`).
- Email notification on new messages.
- Blog, visitor analytics, resume download.

## 3. Architecture

```
Browser
  │  loads static files (HTML, JS, CSS)
  ▼
React app (static files on a host)
  │  fetch("/api/...")  — JSON over HTTP
  ▼
Spring Boot REST API  (/api/*)
  │  Controller  → receives the HTTP request, returns the HTTP response
  │  Service     → business rules (validation, honeypot, rate limit)
  │  Repository  → the only layer that runs SQL
  ▼
PostgreSQL
```

- **Why three layers:** each layer has one job, so each can be tested and changed on its own. Example: switching the skills repository from hand-written SQL to JPA changes one class; the controller and service don't notice.
- **Local development:** the Vite dev server forwards (proxies) every `/api/*` request to `http://localhost:8080`. The browser sees one origin, so no CORS setup is needed locally.
- **Repo layout:** `frontend/` (React, Vite), `backend/` (Maven project), docs at the root.
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

All `id` columns are `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` (the database assigns 1, 2, 3, …).

### `skills`
| Column | Type | Constraints | Why |
|---|---|---|---|
| `id` | BIGINT | PK, identity | |
| `name` | VARCHAR(50) | NOT NULL, UNIQUE | "Java" can exist only once |
| `category` | VARCHAR(20) | NOT NULL, CHECK IN (`LANGUAGE`,`FRAMEWORK`,`TOOL`,`DATABASE`,`CLOUD`) | Group skills on the page |
| `display_order` | INT | NOT NULL, DEFAULT 0 | Control order without renaming |

### `projects`
| Column | Type | Constraints | Why |
|---|---|---|---|
| `id` | BIGINT | PK, identity | |
| `name` | VARCHAR(100) | NOT NULL | |
| `summary` | VARCHAR(200) | NOT NULL | Today's one-line "detail" |
| `description` | TEXT | NULL | Optional longer paragraph |
| `github_url` | VARCHAR(500) | NULL | Optional |
| `live_url` | VARCHAR(500) | NULL | Optional |
| `featured` | BOOLEAN | NOT NULL, DEFAULT false | Featured projects appear first |
| `display_order` | INT | NOT NULL, DEFAULT 0 | |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT now() | |

### `project_skills` (many-to-many link)
| Column | Type | Constraints |
|---|---|---|
| `project_id` | BIGINT | NOT NULL, FK → `projects(id)` ON DELETE CASCADE |
| `skill_id` | BIGINT | NOT NULL, FK → `skills(id)` ON DELETE RESTRICT |
| | | PRIMARY KEY (`project_id`, `skill_id`) |

- **Design choice:** a project's tech tags *are* rows in `skills`. One project has many skills, one skill appears in many projects, so a link table sits between them.
- Deleting a project removes its links (CASCADE). Deleting a skill that a project still uses is refused (RESTRICT), so no project silently loses a tag.
- Side effect: every tag also appears in the Skills section.

### `contact_messages`
| Column | Type | Constraints |
|---|---|---|
| `id` | BIGINT | PK, identity |
| `name` | VARCHAR(100) | NOT NULL |
| `email` | VARCHAR(254) | NOT NULL |
| `message` | VARCHAR(5000) | NOT NULL |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT now() |

### Seed data (a Flyway migration)
- Skills from today's page: Java, Python, Selenium, REST Assured, SQL, Git.
- Projects from today's page: Flipkart E2E test framework, Predictive cloud autoscaling, FuelTrack AI, Prashanthi Delights (name → `name`, detail → `summary`).
- Project ↔ skill links: **see Open questions.**

## 6. API endpoints

Base path: `/api`. All request and response bodies are JSON.

| Method | Path | Request body | Success | Errors |
|---|---|---|---|---|
| GET | `/api/health` | – | `200 {"status":"UP"}` | – |
| GET | `/api/skills` | – | `200 [{"id","name","category"}]`, ordered by `display_order`, then `name` | 500 |
| GET | `/api/projects` | – | `200 [{"id","name","summary","description","githubUrl","liveUrl","featured","skills":[{"id","name"}]}]`, ordered by `featured` desc, `display_order`, `id` | 500 |
| POST | `/api/contact` | `{"name","email","message","website"}` | `201 {"status":"received"}` | 400, 429 |

**`POST /api/contact` details**
- `website` is the honeypot: a form field hidden from humans with CSS. Bots fill every field. If `website` is non-empty, the server returns the normal `201` but stores nothing.
- The response never includes the new row's id, so a bot can't tell a real save from a honeypot drop.
- `400` body lists each invalid field: `{"type","title","status","detail","errors":[{"field","message"}]}`.
- `429 Too Many Requests` after 5 messages from one IP address in one hour, with a `Retry-After` header (seconds).

## 7. Invariants (rules that must always hold)

1. Blueprint first, code second.
2. The server validates every input, even if the browser already did: after trimming, `name` 1–100 chars, `email` valid format and ≤ 254 chars, `message` 1–5000 chars.
3. Errors use RFC 9457 Problem Details (`Content-Type: application/problem+json`), which Spring Boot supports out of the box.
4. JSON field names are camelCase; timestamps are ISO-8601 in UTC (e.g. `2026-09-26T08:30:00Z`).
5. The schema changes only through a new Flyway migration file. A migration that has already run is never edited.
6. Controllers never touch the database. Only repositories run SQL.
7. Secrets (DB password etc.) live only in environment variables. `.env` is never committed; `.env.example` lists the variable names with fake values.
8. In production, CORS allows only the site's own frontend origin.
9. The frontend never inserts API data as raw HTML (no `innerHTML`, no `dangerouslySetInnerHTML`).
10. An endpoint is "done" only when its API test passes and its response matches section 6.

## 8. Design language

Same as the existing site. Full token table and component rules are in `CLAUDE.md` → "Design language". Summary: peach page, cream cards with a purple left border, indigo header/footer bands, purple headings and buttons, Libre Baskerville headings, Helvetica body, 800px centered column.

## 9. Non-functional requirements

- API responses under 300 ms on a local machine.
- Every form input has a real `<label>` (not only a placeholder), so screen readers can read it.
- Layout works down to 360 px wide (small phones) with no sideways scrolling.
- The site still shows its layout if the API is down, with a clear "couldn't load" message instead of empty sections.

## 10. Working agreement

| Phase | Who does what |
|---|---|
| B — Blueprint | Together. Claude drafts and asks questions, Praveen decides and approves. |
| L — Link | Claude sets up tools and explains each step; Praveen runs the key commands. |
| A — Architect | **Praveen writes the code.** Claude explains, gives steps and hints, reviews. |
| S — Stylize | Praveen leads the React work; Claude guides and reviews. |
| T — Trigger | Together. |

## 11. Open questions

1. **Project tags for the seed data.** Which skills does each project use? Today's text suggests: Flipkart → Java, Selenium, Cucumber · Autoscaling → AWS (+ language?) · FuelTrack AI → ? · Prashanthi Delights → WooCommerce. Tags not in today's Skills list (Cucumber, AWS, WooCommerce) would be added as skills.
2. **Category of each skill** (e.g. Git → TOOL, SQL → LANGUAGE or DATABASE?).
3. **Longer descriptions, GitHub/live links, featured flag** for each of the 4 projects: fill now, or leave empty for later?
4. Hosting provider and domain name — decided in Phase T.
5. E2E test tool — decided in Phase T.

## 12. Change log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-09-26 | First draft from discovery answers. |
