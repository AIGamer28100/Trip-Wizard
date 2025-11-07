# Tasks: Trip Wizards App

**Input**: Design documents from `/specs/001-trip-wizards-app/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are MANDATORY per constitution - include unit, widget, and integration tests for all major features, aiming for 80% coverage.

**Organization**: Tasks are grouped by Phase and Sprint to enable iterative delivery and testing.

## Phase 0 – Setup & Foundations

 [X] T001 Initialize Git repo and set remote `AIGamer28100/Trip-Wizard`. (Est: 2h)
 [X] T002 Add ADK as submodule at `/backend/adk/`:
       `git submodule add https://github.com/karthik-r14/Travel-agent-ADK backend/adk`
       `git submodule update --init --recursive`
       Acceptance: submodule present and not tracked for changes in CI. (Est: 1h)
- [x] T003 Create `backend/environment.yml` and `backend/pyproject.toml` (Poetry). (Est: 1 day)
- [x] T004 Add FastAPI skeleton (`/backend/app/main.py`, `/backend/app/routes/*`). (Est: 2 days)
- [x] T005 Add Dockerfile for backend. (Est: 1 day)
- [x] T006 Add `.gitignore` entries for secrets and ADK local env files. (Est: 1h)
- [x] T007 Add pre-commit hooks for secrets scanning. (Est: 2h)
- [x] T008 Add `dev-memory-helper.sh` to `/tools` and document usage. (Est: 4h)
- [x] T009 Setup GitHub Actions CI skeleton with Conda + Poetry; mark ADK submodule folder as excluded from lint/tests. (Est: 1 day)

## Phase 1 – Core MVP

### Sprint A (2 weeks)

- [x] T010 Implement user Google Sign-In and onboarding (Firebase Auth). (Est: 2 days)
- [x] T011 Create Trips list and Trip create/join flows. (Est: 3 days)
- [x] T012 Create Itinerary model and Day view with add/edit. (Est: 3 days)
- [x] T013 Backend Firestore wiring (Python service to verify tokens and apply server-side logic). (Est: 2 days)
- [x] T014 Memory/CI check: run `dev-memory-helper.sh` during Flutter dev and confirm build <10GB. (Est: 1 day)

**Definition of Done**: all stories above pass unit tests and manual device test; no secrets in repo.

### Sprint B (2 weeks)

- [x] T015 Implement Trip Chat (Firestore streams). (Est: 3 days)
- [x] T016 Implement `@agent` mention flow (app calls ADK server directly OR via backend for extra validation). (Est: 4 days)
- [x] T017 Calendar sync: push itinerary items to Google Calendar (one-way). (Est: 2 days)
- [x] T018 Offline caching and basic conflict resolution. (Est: 3 days)

**Definition of Done**: Chat & AI flows functional; ADK responses produce actionable cards.

## Phase 2 – Booking Layer

- [X] T019 Booking search UI (webview deep link integration). (Est: 1 week)
- [X] T020 Manual booking input + attach to itinerary. (Est: 3 days)
- [X] T021 Validate memory impact on builds. (Est: 1 day)

## Phase 3 – Community & Gamification

- [x] T022 Publish trip as sanitized community trip. (Est: 4 days)
- [x] T023 Community feed UI and save-as-template. (Est: 5 days)
- [x] T024 Likes/comments and basic moderation. (Est: 5 days)
- [x] T025 Badges and leaderboard backend. (Est: 4 days)

## Phase 4 – Subscription & Billing

- [X] T026 Implement AI credit meter and gating UI. (Est: 4 days)
- [X] T027 Integrate Stripe for web & plan for Play/App Store in-app purchases. (Est: 1-2 weeks)
- [X] T028 Add billing records and entitlements validation. (Est: 3 days)

## Phase 5 – Enterprise Mode

- [x] T029 Org model and admin dashboard basics. (Est: 1 week)
- [x] T030 Employee invite flows and SSO/domain restriction logic. (Est: 1 week)
  - Implemented invite acceptance screen with organization details display
  - Created domain service with auto-join functionality and domain whitelist management
  - Built domain management widget for admin UI (add/remove domains, toggle auto-join, bulk import)
  - Added SSO service with Google Workspace integration
  - Created SSO settings widget for admin configuration
  - Updated Organization model with domain and SSO fields
  - Added domain and SSO tabs to organization admin dashboard
  - Unit tests: 11/11 passing for domain validation methods
  - Note: Azure AD/Microsoft 365 SSO marked as coming soon (requires additional OAuth setup)
- [x] T031 Pooled credits & admin reporting. (Est: 1 week)
  - Extended Organization model with creditPool and memberCreditLimits fields
  - Created OrganizationCreditUsage model for tracking member AI credit usage
  - Added MemberCreditSummary model for usage analytics
  - Implemented repository methods for credit pool management (add/deduct credits)
  - Built per-member credit limit system with usage tracking
  - Created OrganizationCreditsWidget with credit pool management UI
  - Added member usage summary with progress indicators and limit warnings
  - Implemented real-time credit usage history stream
  - Added Credits tab to organization admin dashboard
  - Tests: Organization model tests passing (11/11)

## Phase 6 – Optimization & Release

- [ ] T032 Full QA & accessibility sweep. (Est: 1 week)
- [ ] T033 Performance profiling & memory fixes identified by `dev-memory-helper.sh`. (Est: 1 week)
- [ ] T034 Internal beta and store submission. (Est: 1 week)

## Cross-cutting tasks

- [x] T035 Add automated secrets scanning in CI. (Est: 1 day)
- [x] T036 Add health-check endpoints for ADK and backend. (Est: 1 day)
- [x] T037 Create sample data and fixtures for testing (ADK mock responses). (Est: 2 days)
- [x] T038 Document runbooks for memory issues and ADK submodule updates. (Est: 1 day)

## Notes & Constraints

- All tasks that touch credentials must read from env vars; no secrets in Git.
- ADK submodule is read-only: do not edit its files. CI will skip formatting/linting on `/backend/adk/**`.
- Use `gh` CLI for repo operations where applicable.
- Always run `./gradlew --stop` after Android builds to free memory.

## Definition of Done

- Code reviewed and approved
- Unit tests written and passing
- Integration tests written and passing
- Manual testing completed
- Documentation updated
- No lint errors
- Performance targets met
