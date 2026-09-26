# Progress Log

Newest entry on top. One entry per working session.
Template: **Done** · **Errors** (exact message → fix) · **Learned** · **Next**

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
