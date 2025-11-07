# ADK Submodule Update Runbook

## Overview

The ADK (AI Development Kit) is integrated as a Git submodule at `backend/adk/`. This runbook covers procedures for updating the submodule, handling conflicts, and ensuring compatibility with the Trip Wizards backend.

## Submodule Information

- **Location**: `backend/adk/`
- **Repository**: (Specified in `.gitmodules`)
- **Current Submodule**: `travel-concierge` API
- **Integration**: Read-only, consumed by backend API

## Prerequisites

Before updating the ADK submodule:

1. **Check Current Status**:
   ```bash
   git submodule status backend/adk
   ```

2. **Ensure Clean Working Directory**:
   ```bash
   git status
   # Commit or stash any changes before proceeding
   ```

3. **Backup Current Configuration**:
   ```bash
   git rev-parse HEAD:backend/adk > /tmp/adk-current-commit.txt
   ```

## Standard Update Procedure

### Step 1: Update Submodule to Latest

```bash
# Navigate to project root
cd /path/to/TripWizards

# Update submodule to latest commit on tracked branch
git submodule update --remote backend/adk

# Check what changed
cd backend/adk
git log --oneline HEAD@{1}..HEAD
cd ../..
```

### Step 2: Test Integration

```bash
# Run backend tests to ensure compatibility
cd backend
poetry install
pytest tests/ -v

# Check if ADK endpoints are accessible
curl http://localhost:8001/health  # If ADK service is running
```

### Step 3: Commit the Update

```bash
# Return to project root
cd /path/to/TripWizards

# Stage the submodule update
git add backend/adk

# Commit with descriptive message
git commit -m "chore: update ADK submodule to latest version

- Updated travel-concierge API to commit abc123
- Verified compatibility with backend integration tests
- No breaking changes detected"
```

### Step 4: Push and Verify

```bash
# Push the update
git push origin 001-trip-wizards-app

# Verify CI passes
# Check GitHub Actions: .github/workflows/ci.yml
```

## Update to Specific Version

To update ADK to a specific commit or tag:

```bash
# Navigate to submodule
cd backend/adk

# Fetch latest changes
git fetch origin

# Checkout specific version (tag, branch, or commit)
git checkout v1.2.3  # Tag
# OR
git checkout feature/new-api  # Branch
# OR
git checkout abc123def456  # Commit hash

# Return to project root
cd ../..

# Stage and commit
git add backend/adk
git commit -m "chore: update ADK to version 1.2.3"
```

## Handling ADK API Changes

### Breaking Changes

If ADK update introduces breaking changes:

1. **Review ADK Changelog**:
   ```bash
   cd backend/adk
   git log --oneline HEAD@{1}..HEAD
   cat CHANGELOG.md  # If available
   cd ../..
   ```

2. **Update Backend Integration**:
   - Modify `backend/src/trip_wizards/main.py` ADK endpoints
   - Update request/response models in `backend/src/trip_wizards/models/`
   - Update ADK mock responses in `backend/tests/fixtures/adk_mock_responses.py`

3. **Run Full Test Suite**:
   ```bash
   cd backend
   pytest tests/ --cov=trip_wizards --cov-report=term-missing
   ```

4. **Update Documentation**:
   - Update API contracts in `specs/001-trip-wizards-app/contracts/`
   - Update integration notes in `backend/README.md`

### Non-Breaking Changes

For backward-compatible updates:

1. **Update and test** as per standard procedure
2. **No code changes required** if using optional new features
3. **Commit with `chore:` prefix** for version bumps

## Troubleshooting

### Issue 1: Submodule Not Initialized

**Symptom**: `backend/adk/` directory is empty

**Solution**:
```bash
git submodule update --init --recursive
```

### Issue 2: Submodule Detached HEAD

**Symptom**: Submodule shows "HEAD detached at abc123"

**Solution**:
```bash
cd backend/adk
git checkout main  # Or appropriate branch
cd ../..
git add backend/adk
git commit -m "chore: update ADK to track main branch"
```

### Issue 3: Merge Conflicts in Submodule Reference

**Symptom**: Git shows conflict in `backend/adk` during merge

**Solution**:
```bash
# Accept incoming changes (or resolve manually)
git checkout --theirs backend/adk
git submodule update --init backend/adk

# Or accept current version
git checkout --ours backend/adk

# Complete the merge
git add backend/adk
git commit -m "Merge: resolved ADK submodule conflict"
```

### Issue 4: ADK Update Breaks CI

**Symptom**: CI fails after ADK update

**Solution**:
```bash
# Revert to previous working version
cd backend/adk
git checkout $(cat /tmp/adk-current-commit.txt)
cd ../..
git add backend/adk
git commit -m "revert: rollback ADK update due to CI failures"

# Investigate and fix integration issues
# Then retry update
```

### Issue 5: ADK Submodule Out of Sync

**Symptom**: Different team members have different ADK versions

**Solution**:
```bash
# Everyone runs:
git submodule sync
git submodule update --init --recursive

# Ensure .gitmodules is committed and synchronized
```

## Best Practices

### Regular Updates

- **Schedule**: Update ADK monthly or when new features are needed
- **Timing**: Update during low-traffic development periods
- **Testing**: Always run full test suite after updates

### Version Pinning

- **Production**: Pin to specific ADK version (commit hash or tag)
- **Development**: Can track branch for latest features
- **Staging**: Update before production to catch integration issues

### Communication

When updating ADK:

1. **Notify Team**: Post in team chat about planned update
2. **Document Changes**: Update `CHANGELOG.md` or equivalent
3. **Share Testing Results**: Post test coverage and performance metrics

### CI/CD Integration

Ensure CI handles submodules correctly:

```yaml
# .github/workflows/ci.yml
- name: Checkout code with submodules
  uses: actions/checkout@v3
  with:
    submodules: 'recursive'
```

## Rollback Procedure

If ADK update causes issues in production:

### Emergency Rollback

```bash
# Revert to previous commit that changed submodule
git revert HEAD

# Or manually revert to specific version
cd backend/adk
git checkout <previous-working-commit>
cd ../..
git add backend/adk
git commit -m "hotfix: rollback ADK to stable version"
git push origin main --force-with-lease
```

### Post-Rollback

1. **Investigate root cause** of compatibility issue
2. **Create test cases** to prevent regression
3. **Plan controlled update** with fixes in place

## ADK Development Workflow

For developers working on ADK integration:

### Local ADK Development

```bash
# Clone ADK separately for development
git clone <adk-repo-url> ~/adk-dev

# Link to local ADK for testing
cd backend
export ADK_SERVICE_URL=http://localhost:8001

# Start local ADK service
cd ~/adk-dev/travel-concierge
python -m uvicorn main:app --port 8001

# Test backend with local ADK
cd /path/to/TripWizards/backend
pytest tests/integration/test_adk_integration.py
```

### Contributing ADK Changes

If Trip Wizards requires ADK changes:

1. **Create ADK fork** or branch
2. **Implement required changes** in ADK repo
3. **Submit PR to ADK maintainers**
4. **Once merged**, update submodule in Trip Wizards

## Monitoring and Health Checks

### Check ADK Status

Use the health check endpoint:

```bash
# Backend health check includes ADK status
curl http://localhost:8000/health

# Expected response:
{
  "status": "healthy",
  "services": {
    "adk": {
      "status": "healthy",
      "message": "ADK service reachable"
    }
  }
}
```

### ADK Version Tracking

Track ADK version in deployment:

```bash
# Check current ADK commit
git rev-parse HEAD:backend/adk

# View ADK version in logs
# Backend startup should log ADK version
```

## Related Documentation

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Backend Integration Guide](../../backend/README.md)
- [ADK API Contracts](../../specs/001-trip-wizards-app/contracts/)
- [CI/CD Pipeline](../../.github/workflows/ci.yml)

## Changelog

Keep track of ADK updates:

| Date       | ADK Version | Changes                            | Compatibility             |
| ---------- | ----------- | ---------------------------------- | ------------------------- |
| 2024-01-15 | abc123      | Initial integration                | ✅ Compatible              |
| 2024-02-01 | def456      | Added itinerary optimization API   | ✅ Compatible              |
| 2024-03-10 | ghi789      | Breaking change in response format | ⚠️ Requires backend update |

## Contact

For ADK-specific issues:
- **ADK Repository**: (Link to ADK repo)
- **ADK Maintainers**: (Contact information)
- **Integration Questions**: File issue in Trip Wizards repo with `adk-integration` label
