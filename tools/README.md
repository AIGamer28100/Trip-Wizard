# Trip Wizards RAM Management Tools

Comprehensive memory management solution for Flutter development on resource-constrained machines (16GB RAM).

## Overview

This toolkit provides multiple tools to monitor, optimize, and enhance memory usage during Flutter development:

- **Memory Helper**: Comprehensive memory analysis and optimization
- **RAM Disk Manager**: High-speed RAM-based storage for build caches
- **Build Memory Monitor**: Real-time monitoring during builds

## Tools

### 1. Memory Helper (`dev-memory-helper.sh`)

Advanced memory analysis and optimization tool.

```bash
# Basic memory check
./tools/dev-memory-helper.sh

# Create swap file (requires sudo)
sudo ./tools/dev-memory-helper.sh --create-swap

# Memory optimization
./tools/dev-memory-helper.sh --optimize

# Continuous monitoring
./tools/dev-memory-helper.sh --monitor
```

**Features:**

- Real-time memory analysis
- Swap space management
- Process monitoring
- Disk usage analysis
- Memory optimization recommendations
- Automatic alerts for low memory

### 2. RAM Disk Manager (`ram-disk-manager.sh`)

Creates RAM-based storage for faster builds.

```bash
# Create 2GB RAM disk (requires sudo)
sudo ./tools/ram-disk-manager.sh --create

# Move build caches to RAM disk
./tools/ram-disk-manager.sh --setup-cache

# Check RAM disk status
./tools/ram-disk-manager.sh --status

# Remove RAM disk
sudo ./tools/ram-disk-manager.sh --remove
```

**Benefits:**

- Faster Flutter pub operations
- Quicker Gradle builds
- Reduced disk I/O
- Temporary high-speed storage

### 3. Build Memory Monitor (`build-memory-monitor.sh`)

Real-time memory monitoring during builds.

```bash
# Interactive monitoring
./tools/build-memory-monitor.sh --monitor

# Monitor during build
./tools/build-memory-monitor.sh --background flutter build apk

# View memory report
./tools/build-memory-monitor.sh --report

# Stop background monitoring
./tools/build-memory-monitor.sh --stop
```

**Features:**
- Real-time memory tracking
- Peak usage detection
- Build performance analysis
- Memory usage statistics
- Automated reporting

## Quick Start

### For Low Memory Issues

```bash
# 1. Check current memory status
./tools/dev-memory-helper.sh

# 2. Create swap space if needed
sudo ./tools/dev-memory-helper.sh --create-swap

# 3. Optimize memory
./tools/dev-memory-helper.sh --optimize
```

### For Faster Builds

```bash
# 1. Create RAM disk
sudo ./tools/ram-disk-manager.sh --create

# 2. Move caches to RAM
./tools/ram-disk-manager.sh --setup-cache

# 3. Monitor build performance
./tools/build-memory-monitor.sh --background flutter build apk --release
```

## Memory Optimization Tips

### System Level
- **Swap Space**: Use at least 4GB swap for 16GB RAM systems
- **RAM Disk**: 2GB RAM disk for build caches
- **Background Apps**: Close unnecessary applications during builds

### Flutter Specific
- **Gradle Daemon**: Stop with `./gradlew --stop` after builds
- **Flutter Clean**: Run `flutter clean` periodically
- **Build Monitoring**: Use build monitor to identify memory peaks

### Development Workflow
```bash
# Before starting development
./tools/dev-memory-helper.sh --optimize
sudo ./tools/ram-disk-manager.sh --create
./tools/ram-disk-manager.sh --setup-cache

# During builds
./tools/build-memory-monitor.sh --background flutter build apk

# After development
sudo ./tools/ram-disk-manager.sh --remove
```

## Troubleshooting

### Common Issues

**"No swap space configured"**
```bash
sudo ./tools/dev-memory-helper.sh --create-swap
```

**"Not enough RAM for RAM disk"**
- Close background applications
- Reduce RAM disk size in `ram-disk-manager.sh`
- Use swap space instead

**"Build fails with out of memory"**
```bash
./tools/dev-memory-helper.sh --optimize
./tools/build-memory-monitor.sh --background flutter build apk --debug
```

### Performance Tuning

**For 16GB RAM systems:**
- Use 4GB swap file
- 2GB RAM disk for caches
- Monitor builds regularly
- Clean caches weekly

**For 8GB RAM systems:**
- Use 8GB swap file
- 1GB RAM disk maximum
- Close all background apps
- Use debug builds for development

## Integration with CI/CD

Add to GitHub Actions workflow:

```yaml
- name: Memory Check
  run: ./tools/dev-memory-helper.sh

- name: Build with Memory Monitoring
  run: ./tools/build-memory-monitor.sh --background flutter build apk --release
```

## Contributing

When adding new memory management features:

1. Update the appropriate script
2. Add documentation to this README
3. Test on both high and low memory systems
4. Include error handling and user feedback

## Requirements

- Linux/macOS (primary support)
- Bash shell
- Sudo access for swap/RAM disk operations
- bc (basic calculator) for floating point math
- Flutter SDK for Flutter-specific features