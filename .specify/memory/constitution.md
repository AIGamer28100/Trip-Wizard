<!-- Sync Impact Report
Version change: new → 1.0.0
List of modified principles: All new principles added
Added sections: 10 core principles
Removed sections: None
Templates requiring updates: ✅ .specify/templates/plan-template.md (Constitution Check updated), ✅ .specify/templates/tasks-template.md (mandatory testing note added)
Follow-up TODOs: None
-->
# Trip Wizards Constitution

## Core Principles

### I. Purpose & Values

Build delightful, privacy-first travel planning tools. Prioritize UX, accessibility (WCAG AA), performance, and respectful community features.

### II. Architecture & Tech Principles

Frontend: Flutter (Material 3, dynamic color, dual themes). Backend: Python 3.11+ with FastAPI (Conda environment + Poetry for dependency management). Database & Realtime: Firebase Firestore and Firebase Storage (no paid Google billing required for MVP). AI: Use Google ADK (Agent Development Kit) shipped as a read-only submodule at `/backend/adk/` from `https://github.com/karthik-r14/Travel-agent-ADK`. ADK runs its own API server (per `https://google.github.io/adk-docs/`) and should be started/managed independently; backend or app may call ADK endpoints directly. **Do not modify any files inside the ADK submodule.** Auth: Google Sign-In only, via Firebase Authentication.

### III. Security & Secrets

**Never** commit API keys, credentials, `.env`, `*.pem`, or Google service account JSON to Git. All sensitive config must be provided via environment variables or GitHub Secrets. Enforce `.gitignore` and pre-commit hooks that block secrets from being added. CI must use GitHub Secrets (names like `ADK_API_KEY`, `FIREBASE_CREDENTIALS`, etc).

### IV. Repo & Workflow

Remote repository: `AIGamer28100/Trip-Wizard`. Use Git for source control and GitHub CLI (`gh`) for PRs, releases, issues. Branching: `main` (protected), `dev`, feature branches as `feature/<short-desc>`. Commit style: Conventional Commits. Mandatory PR reviews and automated CI checks before merge.

### V. ADK Submodule Policy

Add ADK as submodule:

```bash
git submodule add https://github.com/karthik-r14/Travel-agent-ADK ./backend/adk
git submodule update --init --recursive
```

Mark `/backend/adk/` as read-only in docs and `.gitattributes` for CI exclusion. CI should **not** attempt to lint/modify ADK files. Any update to ADK must come from its upstream repo.

### VI. Developer Environment & RAM Policy

Primary dev machine: **16 GB RAM** — optimize workflows to avoid OOM:

- Gradle/Android: `android/gradle.properties` should include `org.gradle.jvmargs=-Xmx1536m -Dorg.gradle.daemon=false`.
- Use VS Code over heavy IDEs for everyday work.
- Prefer testing on a physical device or lightweight emulator images. Avoid multiple emulator instances.
- Create a 4 GB swap on Linux if needed (documented script available).
- Use `./gradlew --stop` after builds to free Java/Gradle daemons.
- Use `uvicorn --workers 1` during local FastAPI dev; use `--reload` only in dev.
- Never auto-kill Chrome; the helper script must default to prompt mode.
- Include `dev-memory-helper.sh` in `/tools` for interactive monitoring and safe cleanup (must be run manually by the developer).

### VII. Testing, CI & Quality

Unit, widget, and integration tests required for all major features. Minimum test coverage goal: 80% across unit+widget tests. CI gates: format → lint → tests → build → security scan.

### VIII. Privacy & AI Ethics

Obtain explicit consent for Calendar and People access. Redact unnecessary PII from any data sent to ADK. Agent suggestions must be editable by users and flagged as suggestions, not actions.

### IX. Open Source & Dependencies

Prefer free/open-source libs and free Google Suite APIs that do not require billing. Track external licenses and acknowledge contributors.

### X. Governance

Document decisions, keep changelog, and require at least one approving code review for production changes.

## Governance

Constitution supersedes all other practices; Amendments require documentation, approval, migration plan. All PRs/reviews must verify compliance; Complexity must be justified; Use runtime guidance docs for development guidance.

**Version**: 1.0.0 | **Ratified**: 2025-11-06 | **Last Amended**: 2025-11-06
