# Praveen's Portfolio

Personal portfolio site, being turned into a hosted site with a separate frontend and backend. The backend is Praveen's hands-on project for learning backend development from start to finish.

Built with the B.L.A.S.T. framework (Blueprint → Link → Architect → Stylize → Trigger).

## Source of truth

- `blueprint.md` — schema, endpoints, invariants, rules. **If code and blueprint disagree, the blueprint wins.** To change behavior, update the blueprint first (and its change log), then the code.
- `task_plan.md` — current phase and checklist. Tick items as they are done.
- `progress.md` — add one entry per working session (newest on top): what was done, exact errors hit and their fixes, what was learned, what's next.

Do not start a phase before the previous one is checked off and Praveen has approved moving on.

## Structure

```
praveen-website/
├── CLAUDE.md, blueprint.md, task_plan.md, progress.md
├── frontend/          vanilla HTML/CSS/JS today; becomes a React (Vite) app in Phase S
│   ├── index.html
│   ├── css/styles.css
│   └── js/main.js
└── backend/           Spring Boot (Java 25, Maven) — created in Phase L
```

## Commands

- Frontend (current): open `frontend/index.html` in a browser. No build step.
  To serve over http: `cd frontend; python -m http.server 5500` → http://localhost:5500
- Backend: filled in during Phase L.
- React dev server: filled in during Phase S.

## Working agreement (learning mode)

Praveen is learning backend development and has never built a backend before.

- **Backend code is written by Praveen.** Claude explains the concept first with a concrete example, breaks the work into small steps, gives hints before full answers, and reviews Praveen's code as if a stranger wrote it (most serious problems first).
- Claude writes backend code only when Praveen explicitly asks for it in that moment.
- Setup/tooling (Phase L, run scripts, config) Claude may do, explaining each step; Praveen runs the key commands.
- Frontend: in Phase S Praveen leads the React work with Claude guiding. Small frontend fixes outside Phase S Claude may make directly.
- After each step, point out what concept was just learned and how it connects to the bigger picture (request → controller → service → repository → database → response).

## Design language

Keep every page consistent with the existing look.

Colors — always use the CSS variables in `frontend/css/styles.css`, never raw hex values:

| Token | Value | Used for |
|---|---|---|
| `--peach` | `#FFDAB9` | page background |
| `--cream` | `#FFE4B5` | card background, nav link text |
| `--sand` | `#FFDEAD` | input background, text on dark bands, section dividers |
| `--purple` | `#800080` | headings, buttons, card left border |
| `--indigo` | `#4B0082` | body text, header/footer bands, input border, button hover |

Typography: headings `h1–h3` use "Libre Baskerville" (Google Fonts), Georgia, serif. Body uses Helvetica, Arial, sans-serif. Line height 1.6.

Layout and components:
- `.container`: max-width 800px, centered, 20px side padding.
- Header and footer: full-width indigo band with sand text.
- Sections: 30px vertical padding, 1px sand bottom border.
- `.card-list li`: cream background, 4px purple left border, 10px padding, no bullets.
- Buttons: flat purple with sand text, no border, indigo on hover.
- Inputs/textareas: full width, sand background, 1px indigo border.

Do not add new colors, fonts, or UI libraries without asking.

## Known issues to fix later

- `frontend/js/main.js` builds project cards with `innerHTML` and a template string. Safe while the data is hard-coded, but an XSS (cross-site scripting) hole once data comes from the API. In React, render text normally and never use `dangerouslySetInnerHTML`.
- The contact form only validates in the browser and sends nothing (fixed by `POST /api/contact` in Phase A/S).
