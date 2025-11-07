# Memory Issues Troubleshooting Runbook

## Overview

Trip Wizards targets 16GB RAM development environments with a <10GB build artifact constraint. This runbook provides systematic troubleshooting steps for memory-related issues during development and builds.

## Quick Diagnostics

### Check Current Memory Usage

```bash
# Run the memory helper script
./tools/dev-memory-helper.sh

# Or manually check
free -h
df -h /tmp
```

### Check Build Artifact Size

```bash
# Check Flutter build size
du -sh build/

# Check backend artifacts
du -sh backend/.venv backend/__pycache__
```

## Common Issues and Solutions

### Issue 1: Flutter Build Out of Memory (OOM)

**Symptoms:**
- `flutter build` crashes with OOM error
- System becomes unresponsive during build
- Build process killed by system

**Solutions:**

1. **Clean and Rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --split-per-abi
   ```

2. **Use RAM Disk (if available)**
   ```bash
   ./tools/ram-disk-manager.sh create
   # Build will use faster RAM-based storage
   ```

3. **Reduce Build Concurrency**
   ```bash
   # Limit Gradle workers
   echo "org.gradle.workers.max=2" >> android/gradle.properties
   echo "org.gradle.daemon=false" >> android/gradle.properties
   ```

4. **Split APK by ABI**
   ```bash
   # Instead of universal APK, build for specific architectures
   flutter build apk --split-per-abi
   # Produces smaller arm64-v8a, armeabi-v7a, x86_64 APKs
   ```

5. **Disable Debug Symbols**
   ```bash
   # For testing only - reduces memory usage
   flutter build apk --no-tree-shake-icons --release
   ```

### Issue 2: Backend Build Memory Issues

**Symptoms:**
- Poetry install fails with memory error
- Conda environment creation crashes
- Python tests OOM during execution

**Solutions:**

1. **Use Conda for Environment Isolation**
   ```bash
   cd backend
   conda env create -f environment.yml
   conda activate trip-wizards
   poetry install --no-dev  # Skip dev dependencies initially
   ```

2. **Install Dependencies in Batches**
   ```bash
   # If poetry install fails, install core deps first
   poetry install --only main
   poetry install --only dev
   ```

3. **Reduce Test Parallelism**
   ```bash
   # Instead of default parallel execution
   pytest -n 1  # Run tests serially
   pytest --maxfail=1  # Stop on first failure
   ```

4. **Clear Python Cache**
   ```bash
   find . -type d -name __pycache__ -exec rm -rf {} +
   find . -type f -name "*.pyc" -delete
   ```

### Issue 3: IDE Memory Issues (VS Code / Android Studio)

**Symptoms:**
- IDE becomes sluggish
- Dart Analysis Server crashes
- Frequent freezes

**Solutions:**

1. **VS Code Settings**

   Add to `.vscode/settings.json`:
   ```json
   {
     "dart.maxLogLineLength": 2000,
     "dart.analysisServerFolding": false,
     "dart.previewFlutterUiGuides": false,
     "editor.codeLens": false
   }
   ```

2. **Exclude Build Directories**

   Add to `.vscode/settings.json`:
   ```json
   {
     "files.watcherExclude": {
       "**/build/**": true,
       "**/.dart_tool/**": true,
       "**/backend/.venv/**": true,
       "**/backend/adk/**": true
     }
   }
   ```

3. **Increase Dart Analysis Server Memory**

   Add to `.vscode/settings.json`:
   ```json
   {
     "dart.additionalAnalyzerFileExtensions": [],
     "dart.vmAdditionalArgs": ["--old_gen_heap_size=4096"]
   }
   ```

4. **Restart Analysis Server**
   - VS Code: Command Palette → "Dart: Restart Analysis Server"
   - Or: Close and reopen workspace

### Issue 4: Git Operations Memory Issues

**Symptoms:**
- `git status` slow or crashes
- `git add` fails with memory error
- Repository operations hang

**Solutions:**

1. **Configure Git for Large Repos**
   ```bash
   git config core.preloadindex true
   git config core.fscache true
   git config gc.auto 256
   git config pack.threads 1  # Reduce parallelism
   ```

2. **Use Sparse Checkout for ADK Submodule**
   ```bash
   cd backend/adk
   git config core.sparseCheckout true
   echo "travel-concierge/*" >> .git/info/sparse-checkout
   git read-tree -mu HEAD
   ```

3. **Run Git Garbage Collection**
   ```bash
   git gc --aggressive --prune=now
   ```

## Memory Monitoring and Prevention

### Automated Monitoring

Use the provided memory monitor script during builds:

```bash
# Monitor memory during Flutter build
./tools/build-memory-monitor.sh flutter build apk

# Monitor memory during backend tests
./tools/build-memory-monitor.sh pytest
```

### Pre-Build Checklist

Before starting a build, run:

```bash
# Clean previous builds
flutter clean
rm -rf backend/.pytest_cache backend/__pycache__

# Check available memory
free -h | grep "Mem:"
# Ensure at least 4GB available

# Check disk space
df -h /tmp
# Ensure at least 5GB available in /tmp

# Optionally: Create RAM disk
./tools/ram-disk-manager.sh create
```

### Build Configuration Best Practices

1. **Gradle Settings** (`android/gradle.properties`):
   ```properties
   org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
   org.gradle.workers.max=2
   org.gradle.daemon=true
   org.gradle.parallel=false
   ```

2. **Flutter Settings**:
   - Use `--release` for production builds
   - Use `--split-per-abi` for smaller artifacts
   - Avoid `--verbose` unless debugging

3. **Backend Settings** (`pyproject.toml`):
   ```toml
   [tool.pytest.ini_options]
   # Limit parallel workers
   addopts = "-n 2"
   ```

## Emergency Procedures

### System Completely Out of Memory

If system becomes unresponsive:

1. **Switch to TTY** (Ctrl+Alt+F2)
2. **Identify memory-hogging processes**:
   ```bash
   ps aux --sort=-%mem | head -n 10
   ```
3. **Kill offending processes**:
   ```bash
   killall -9 dart
   killall -9 gradle
   killall -9 python
   ```
4. **Clear system cache**:
   ```bash
   sudo sync
   sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
   ```

### Persistent Memory Issues

If memory issues persist across builds:

1. **Increase System Swap**:
   ```bash
   # Create 4GB swap file
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

2. **Use Remote Build Server**:
   - Consider using CI/CD for builds
   - GitHub Actions, GitLab CI, or dedicated build machines

3. **Upgrade Development Environment**:
   - Target recommendation: 32GB RAM for comfortable development
   - Minimum: 16GB with optimizations from this runbook

## Metrics and Targets

### Build Size Targets

- **Flutter APK (split per ABI)**: <50MB per architecture
- **Flutter APK (universal)**: <150MB
- **Backend Docker image**: <500MB
- **Backend .venv**: <2GB
- **Total build/ directory**: <10GB

### Memory Usage Targets

- **Peak Flutter build**: <8GB
- **Peak backend tests**: <2GB
- **IDE (VS Code)**: <2GB
- **Total development session**: <14GB (leaving 2GB for system)

## Related Documentation

- [Development Memory Helper](../tools/README.md#dev-memory-helper)
- [RAM Disk Manager](../tools/README.md#ram-disk-manager)
- [Build Memory Monitor](../tools/README.md#build-memory-monitor)
- [CI/CD Pipeline](.github/workflows/ci.yml)

## Feedback and Updates

If you encounter memory issues not covered in this runbook, please:

1. Document the issue and solution
2. Update this runbook
3. Commit changes: `docs: update memory troubleshooting runbook`
