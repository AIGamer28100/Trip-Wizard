# Implementation Plan: Trip Wizards

**Branch**: `001-trip-wizards-app` | **Date**: November 6, 2025 | **Spec**: specs/001-trip-wizards-app/spec.md
**Input**: Feature specification from `/specs/001-trip-wizards-app/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Trip Wizards is a cross-platform Flutter app for collaborative trip planning with AI-assisted itineraries, integrated bookings, community sharing, gamification, and enterprise features. Technical approach uses Flutter frontend, FastAPI backend with Firebase, ADK submodule for AI, optimized for 16GB RAM development.

## Technical Context

**Language/Version**: Flutter (Dart), Python 3.11+
**Primary Dependencies**: FastAPI, Firebase SDK, ADK submodule
**Storage**: Firestore
**Testing**: flutter_test, pytest
**Target Platform**: iOS/Android
**Project Type**: Mobile app with backend API
**Performance Goals**: 60fps UI, <2s first actionable screen, <100ms itinerary render, <500ms API responses
**Constraints**: 16GB RAM dev machine, privacy-first, WCAG AA accessibility, no secrets in git
**Scale/Scope**: MVP for 1000 users, 50 screens, 10k trips, AI credits metering

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Purpose & Values**: Feature must prioritize UX, accessibility (WCAG AA), performance, privacy-first design, and respectful community features.
- **Architecture & Tech**: Must use Flutter for frontend with Material 3, FastAPI for backend, Firebase for DB/storage, ADK submodule for AI, Google Sign-In for auth.
- **Security**: No secrets committed, use env vars/GitHub Secrets.
- **Repo & Workflow**: Use specified repo, branching, conventional commits, PR reviews, CI.
- **ADK Submodule**: ADK must be read-only submodule, not modified.
- **Dev Environment**: Respect RAM policy, use specified optimizations.
- **Testing**: Must include unit/widget/integration tests, aim for 80% coverage.
- **Privacy & AI Ethics**: Obtain consent for access, redact PII, flag AI suggestions.
- **Open Source**: Prefer free/open-source libs, track licenses.
- **Governance**: Document decisions, require code review.

## Project Structure

### Documentation (this feature)

```text
specs/001-trip-wizards-app/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
frontend/                # Flutter app
├── lib/
│   ├── models/          # Data models
│   ├── services/        # API, Firebase, ADK clients
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable components
│   └── utils/           # Helpers
├── android/             # Android config
├── ios/                 # iOS config
└── test/                # Unit/widget tests

backend/                 # FastAPI server
├── app/
│   ├── models/          # Pydantic models
│   ├── routes/          # API endpoints
│   ├── services/        # Business logic
│   └── utils/           # Helpers
├── adk/                 # ADK submodule (read-only)
├── tests/               # Pytest tests
└── environment.yml      # Conda env

tools/                   # Dev tools
├── dev-memory-helper.sh # RAM monitoring
└── ...

.github/workflows/       # CI/CD
```

**Structure Decision**: Mobile-first with separate frontend/backend for scalability. ADK as submodule for AI integration without code modification.

## Project Overview

Trip Wizards is a cross-platform Flutter app for collaborative trip planning with AI-assisted itineraries, integrated bookings, community sharing, gamification, and enterprise features. Core differentiators include seamless AI chat for personalized recommendations, direct booking integration, and privacy-first design with WCAG AA accessibility.

## Goals by Phase

### Phase 0: Setup & Foundations (2 weeks)
- Goals: Initialize repo, FastAPI scaffold, Conda+Poetry, Firebase, ADK submodule, CI bootstrap, memory-helper.
- Dependencies: Firebase project setup, ADK repo access.
- Deliverables: Repo structure, backend skeleton, CI pipeline, dev tools.

### Phase 1: Core MVP (4 weeks)
- Goals: Trip CRUD, itinerary builder, trip chat, Google Calendar sync, basic ADK @agent flow, offline caching.
- Dependencies: Phase 0 complete.
- Deliverables: Functional MVP app, backend API, basic AI integration.

### Phase 2: Booking Layer (3 weeks)
- Goals: Search webview, manual booking input, integrate bookings into itinerary.
- Dependencies: MVP stable.
- Deliverables: Booking search/results, payment flow.

### Phase 3: Community & Gamification (3 weeks)
- Goals: Publish trips, community feed, save-as-template, likes/comments, badges, leaderboards.
- Dependencies: Bookings working.
- Deliverables: Community features, gamification system.

### Phase 4: Subscription & Billing (2 weeks)
- Goals: AI credits, Pro tier, Play/App Store + Stripe options.
- Dependencies: Community stable.
- Deliverables: Billing system, subscription management.

### Phase 5: Enterprise Mode (3 weeks)
- Goals: Org accounts, admin dashboard, SSO/domain restriction, pooled credits.
- Dependencies: Billing complete.
- Deliverables: Enterprise features.

### Phase 6: Optimization & Release (4 weeks)
- Goals: Performance polish, accessibility, QA, app store submission.
- Dependencies: All features complete.
- Deliverables: Production app, store listings.

## Team Roles

- Flutter Engineer: Frontend development, UI/UX implementation.
- Backend/FastAPI Engineer: API development, Firebase integration.
- ADK Integrator: ADK submodule management, AI flow integration (no code changes to ADK).
- UI/UX Designer: Screen designs, accessibility.
- QA Engineer: Testing, automation.
- DevOps/Release Manager: CI/CD, deployment.

For solo dev: Rotate roles, focus on MVP first.

## Sprint Breakdown

### Sprint 1: Foundations (Week 1)
- Objectives: Repo setup, backend scaffold.
- Tasks: Init repo, add ADK submodule, create FastAPI app, setup Conda/Poetry, Firebase config.
- Deliverables: Running backend skeleton.
- Dependencies: None.
- DoD: Backend starts, ADK submodule added.

### Sprint 2: Auth & Data (Week 2)
- Objectives: Google auth, Firestore models.
- Tasks: Implement auth, create user/trip collections, basic CRUD.
- Deliverables: Auth working, data persisted.
- Dependencies: Sprint 1.
- DoD: User login, trip creation.

### Sprint 3: Itinerary Core (Week 3)
- Objectives: Itinerary builder, basic UI.
- Tasks: Flutter screens for trip/itinerary, add/edit items.
- Deliverables: Trip planning UI.
- Dependencies: Sprint 2.
- DoD: Create trip, add activities.

### Sprint 4: Chat & AI (Week 4)
- Objectives: Trip chat, ADK integration.
- Tasks: Chat UI, @agent mentions, ADK calls.
- Deliverables: AI chat working.
- Dependencies: Sprint 3.
- DoD: Chat messages, AI responses.

### Sprint 5: Bookings MVP (Week 5)
- Objectives: Basic booking search.
- Tasks: Search UI, webview integration.
- Deliverables: Booking search.
- Dependencies: Sprint 4.
- DoD: Search results display.

### Sprint 6: Community (Week 6)
- Objectives: Publish trips, feed.
- Tasks: Publish flow, community screens.
- Deliverables: Trip sharing.
- Dependencies: Sprint 5.
- DoD: Publish and view trips.

### Sprint 7: Polish & Test (Week 7-8)
- Objectives: Testing, fixes.
- Tasks: Unit tests, integration, bug fixes.
- Deliverables: Stable MVP.
- Dependencies: Sprint 6.
- DoD: 80% coverage, no critical bugs.

## Environment Setup

### Gradle Properties
```
org.gradle.jvmargs=-Xmx1536m -Dorg.gradle.daemon=false
```

### FastAPI Local
```
uvicorn --workers 1 --reload
```

### Conda + Poetry
environment.yml:
```
name: tripwizards
channels:
  - conda-forge
dependencies:
  - python=3.11
  - pip
```

pyproject.toml:
```
[tool.poetry]
name = "tripwizards"
version = "0.1.0"
python = "^3.11"

[tool.poetry.dependencies]
fastapi = "^0.104.1"
uvicorn = "^0.24.0"
firebase-admin = "^6.2.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### Swapfile for Linux
```
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Emulator
```
flutter emulators --launch <emulator>
```

### Gradle Stop
```
./gradlew --stop
```

## CI/CD

Jobs: lint, test, build, deploy.

Sample GitHub Actions:
```yaml
- name: Lint
  run: flutter analyze
- name: Test
  run: flutter test --max-workers=2
- name: Build
  run: flutter build apk
```

Secrets: ADK_URL, ADK_API_KEY, FIREBASE_CREDENTIALS, STRIPE_KEY.

## Testing Strategy

Unit: flutter_test, pytest.

Widget: integration_test.

E2E: Manual flows.

Mock ADK: httpx for responses.

## Risk Management

OOM: dev-memory-helper.sh, single workers, swapfile.

ADK: Health check, mocks.

Secrets: pre-commit hooks.

Bookings: Deep links.

## Performance Targets

60fps UI, <3s cold start, <10GB build memory, <500MB runtime.

## Deliverables by Phase

Phase 0: Repo, backend scaffold, CI.

Phase 1: MVP app, API.

Phase 2: Booking features.

Phase 3: Community.

Phase 4: Billing.

Phase 5: Enterprise.

Phase 6: Production app.

## Monitoring & Logging

DevTools, Crashlytics, ADK logs, dev-memory-helper.sh.

## Release Criteria

Functional pass, ≥80% tests, no crashes, no secrets, ADK verified.

## Timeline Estimate

MVP: 8-10 weeks.

v1: 11-18 weeks.

v2: 19-26 weeks.

## Communication & Tools

Git + gh, Speckit docs, GitHub Issues, VS Code.

## Appendix: ADK Submodule

Repo: https://github.com/karthik-r14/Travel-agent-ADK

Commands:
```
git submodule add https://github.com/karthik-r14/Travel-agent-ADK ./backend/adk
git submodule update --init --recursive
```

ADK runs own server; start with docs instructions.

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation                  | Why Needed         | Simpler Alternative Rejected Because |
| -------------------------- | ------------------ | ------------------------------------ |
| [e.g., 4th project]        | [current need]     | [why 3 projects insufficient]        |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient]  |
