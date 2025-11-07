# Trip Wizards Runbooks

This directory contains operational runbooks for common maintenance and troubleshooting scenarios.

## Available Runbooks

### [Memory Troubleshooting](./memory-troubleshooting.md)

Comprehensive guide for diagnosing and resolving memory issues during development and builds.

**Use when:**
- Flutter builds run out of memory
- Backend tests crash with OOM errors
- IDE becomes sluggish or unresponsive
- Git operations hang or fail
- System swap is exhausted

**Quick Links:**
- [Flutter Build OOM](./memory-troubleshooting.md#issue-1-flutter-build-out-of-memory-oom)
- [Backend Memory Issues](./memory-troubleshooting.md#issue-2-backend-build-memory-issues)
- [IDE Performance](./memory-troubleshooting.md#issue-3-ide-memory-issues-vs-code--android-studio)
- [Emergency Procedures](./memory-troubleshooting.md#emergency-procedures)

### [ADK Submodule Updates](./adk-submodule-updates.md)

Step-by-step procedures for updating the ADK (AI Development Kit) submodule.

**Use when:**
- Updating ADK to latest version
- Resolving ADK integration issues
- Handling ADK breaking changes
- Rolling back problematic ADK updates
- Syncing ADK across team members

**Quick Links:**
- [Standard Update](./adk-submodule-updates.md#standard-update-procedure)
- [Specific Version Update](./adk-submodule-updates.md#update-to-specific-version)
- [Troubleshooting](./adk-submodule-updates.md#troubleshooting)
- [Rollback Procedure](./adk-submodule-updates.md#rollback-procedure)

## Runbook Structure

Each runbook follows this structure:

1. **Overview**: Brief description and when to use
2. **Prerequisites**: Requirements before starting
3. **Procedures**: Step-by-step instructions
4. **Troubleshooting**: Common issues and solutions
5. **Best Practices**: Recommendations and tips
6. **Related Documentation**: Links to relevant docs

## How to Use Runbooks

### For New Team Members

Start here to understand common operational procedures:

1. Read [Memory Troubleshooting](./memory-troubleshooting.md) to set up your dev environment
2. Review [ADK Submodule Updates](./adk-submodule-updates.md) to understand ADK integration

### During Incidents

1. **Identify the issue category** (memory, ADK, etc.)
2. **Open relevant runbook** and go to quick diagnosis section
3. **Follow procedures** in order listed
4. **Document outcomes** if issue not covered

### For Regular Maintenance

- **Weekly**: Check memory usage with `./tools/dev-memory-helper.sh`
- **Monthly**: Consider ADK updates if new features available
- **Before releases**: Run through [Memory Troubleshooting Pre-Build Checklist](./memory-troubleshooting.md#pre-build-checklist)

## Contributing to Runbooks

Found an issue or solution not documented? Please update the runbooks:

1. **Edit relevant runbook** with your findings
2. **Follow existing structure** for consistency
3. **Add to Quick Links** if it's a common scenario
4. **Commit with clear message**: `docs: update [runbook-name] with [issue/solution]`

### Runbook Guidelines

- **Be specific**: Include exact commands and file paths
- **Be comprehensive**: Cover symptoms, solutions, and prevention
- **Be practical**: Test all procedures before documenting
- **Be concise**: Use bullet points and clear headings
- **Be helpful**: Include context and explanations

## Request New Runbooks

Need a runbook for a new scenario? Open an issue with:

- **Title**: "Runbook Request: [Topic]"
- **Description**: What operational procedure needs documentation
- **Use Cases**: When this runbook would be helpful
- **Existing Knowledge**: Any solutions or procedures you already know

Common future runbook candidates:
- Database migration procedures
- Firebase security rules updates
- Stripe webhook testing and troubleshooting
- CI/CD pipeline maintenance
- Production deployment checklist

## Related Documentation

- [Development Tools](../../tools/README.md)
- [Backend Documentation](../../backend/README.md)
- [Project Tasks](../../specs/001-trip-wizards-app/tasks.md)
- [CI/CD Configuration](../../.github/workflows/ci.yml)

## Maintenance

Runbooks should be reviewed and updated:

- **After major updates**: Verify procedures still work
- **When tools change**: Update command syntax and paths
- **After incidents**: Add new troubleshooting sections
- **Quarterly**: Review for accuracy and completeness

Last reviewed: 2024-01-15
