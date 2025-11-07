# Research: Trip Wizards

## ADK Integration

**Decision**: Use ADK as read-only submodule at `/backend/adk/`, call endpoints directly from app/backend.

**Rationale**: ADK provides its own API server, no middleware needed. Submodule ensures version control without modification.

**Alternatives considered**: Proxy middleware for auth - rejected as unnecessary per ADK docs.

## Firebase Setup

**Decision**: Firebase Auth for Google Sign-In, Firestore for data, Storage for media.

**Rationale**: Free tier sufficient for MVP, integrates well with Flutter.

**Alternatives considered**: Supabase - rejected due to Google ecosystem preference.

## Flutter Architecture

**Decision**: Provider for state management, Material 3 with dynamic themes.

**Rationale**: Simple, official, supports accessibility.

**Alternatives considered**: Bloc - rejected for MVP simplicity.

## Backend Architecture

**Decision**: FastAPI with Pydantic, Conda + Poetry for deps.

**Rationale**: Fast development, type safety, reproducible env.

**Alternatives considered**: Django - rejected for overhead.

## Testing Strategy

**Decision**: 80% coverage with flutter_test, pytest, integration_test.

**Rationale**: Balances quality and speed.

**Alternatives considered**: 100% coverage - rejected for time constraints.

## Performance Optimizations

**Decision**: RAM limits with gradle flags, single workers, swapfile.

**Rationale**: Essential for 16GB machines.

**Alternatives considered**: More RAM - not feasible.

## CI/CD

**Decision**: GitHub Actions with Conda, skip ADK in CI.

**Rationale**: Free, integrates with repo.

**Alternatives considered**: GitLab CI - rejected for GitHub preference.
