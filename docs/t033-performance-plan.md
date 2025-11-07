# T033 Performance Profiling & Memory Fixes

**Task**: T033 - Performance profiling & memory fixes
**Started**: 2025-11-07
**Target**: Production-ready performance

## Objectives

1. **Memory Profile**: Identify and fix memory leaks or excessive usage
2. **App Performance**: Optimize startup time, frame rates, navigation
3. **Build Size**: Ensure APK/IPA size is reasonable (<50MB)
4. **Network Performance**: Test with various network conditions
5. **Backend Performance**: Basic load testing

## Baseline Measurements

### 1. Build Size Analysis

```bash
# Debug build size
flutter build apk --debug
# Check: build/app/outputs/flutter-apk/app-debug.apk

# Release build size (optimized)
flutter build apk --release
# Check: build/app/outputs/flutter-apk/app-release.apk

# Split APKs (per architecture - recommended)
flutter build apk --split-per-abi --release
```

**Target**: Release APK <50MB (per ABI)

### 2. App Performance Profiling

```bash
# Run app with performance overlay
flutter run --profile --trace-skia

# Profile specific screen
flutter run --profile --route=/organization-admin

# Memory profiling
flutter run --profile --trace-systrace
```

**Metrics to Track**:
- Startup time: <3 seconds (cold start)
- Frame rendering: 60fps maintained
- Memory footprint: <200MB typical usage
- Network requests: <500ms average latency

### 3. Development Build Performance

```bash
# Monitor memory during build
./tools/build-memory-monitor.sh

# Check build time
time flutter build apk --release
```

**Target**: Build completes without out-of-memory errors

## Performance Checklist

### App Performance

- [ ] **Startup Time**
  - [ ] Measure cold start time
  - [ ] Measure warm start time
  - [ ] Target: <3s cold, <1s warm

- [ ] **Frame Rate**
  - [ ] Test on complex screens (organization admin dashboard)
  - [ ] Test list scrolling (trip list, itinerary)
  - [ ] Test animations (page transitions)
  - [ ] Target: 60fps (16.6ms per frame)

- [ ] **Memory Usage**
  - [ ] Profile typical user session
  - [ ] Check for memory leaks
  - [ ] Test with multiple trips loaded
  - [ ] Target: <200MB for typical usage

- [ ] **Navigation Performance**
  - [ ] Test screen transitions
  - [ ] Test deep linking
  - [ ] Test back button navigation

### Build Performance

- [ ] **Build Size**
  - [ ] Measure debug APK size
  - [ ] Measure release APK size
  - [ ] Check split APK sizes (per ABI)
  - [ ] Analyze dependencies contributing to size

- [ ] **Build Time**
  - [ ] Measure full rebuild time
  - [ ] Measure incremental build time
  - [ ] Check for unnecessary rebuilds

- [ ] **Build Resources**
  - [ ] Monitor memory during build
  - [ ] Check for build failures
  - [ ] Verify swap usage acceptable

### Network Performance

- [ ] **API Latency**
  - [ ] Test Firebase operations
  - [ ] Test backend API calls
  - [ ] Test under slow network (3G simulation)
  - [ ] Test offline behavior

- [ ] **Caching**
  - [ ] Verify cache effectiveness
  - [ ] Test offline data access
  - [ ] Check cache size limits

### Backend Performance

- [ ] **Load Testing** (basic)
  - [ ] Test with 10 concurrent users
  - [ ] Test with 50 concurrent users
  - [ ] Monitor backend response times
  - [ ] Check database query performance

## Performance Optimization Opportunities

### Identified Issues

*(To be filled during profiling)*

1. **Memory Leaks**: None identified yet
2. **Slow Screens**: To be profiled
3. **Large Dependencies**: To be analyzed
4. **Network Issues**: To be tested

### Quick Wins

1. **Enable obfuscation** (release builds)
   ```yaml
   # android/app/build.gradle
   buildTypes {
     release {
       signingConfig signingConfigs.release
       minifyEnabled true
       shrinkResources true
     }
   }
   ```

2. **Optimize images**
   - Convert PNGs to WebP where possible
   - Use appropriate image resolutions
   - Implement lazy loading

3. **Reduce package size**
   - Review dependencies in pubspec.yaml
   - Remove unused packages
   - Use tree-shaking for web builds

4. **Improve caching**
   - Cache Firebase queries
   - Implement offline-first strategy
   - Use HTTP cache headers

### Advanced Optimizations

1. **Code splitting** (web only)
2. **Deferred loading** (lazy load screens)
3. **Database indexing** (Firestore)
4. **CDN for static assets** (images, videos)

## Tools & Commands

### Flutter Performance Tools

```bash
# DevTools (comprehensive profiling)
flutter pub global activate devtools
flutter pub global run devtools

# Performance overlay in app
flutter run --profile --trace-skia

# Memory profiling
flutter run --profile --dump-skp-on-shader-compilation

# Size analysis
flutter build apk --analyze-size
```

### Memory Monitoring

```bash
# Use project memory helper
./tools/dev-memory-helper.sh --monitor

# Build with monitoring
./tools/build-memory-monitor.sh
```

### Network Testing

```bash
# Chrome DevTools Network throttling for WebView testing
# Or use device network throttling for full app testing
```

## Success Criteria

- ✅ All builds complete without OOM errors
- ✅ Release APK <50MB (per ABI)
- ✅ App starts in <3 seconds (cold start)
- ✅ 60fps maintained on all screens
- ✅ Memory usage <200MB typical, <500MB peak
- ✅ Network requests complete in <500ms on good connection
- ✅ App functions offline for core features

## Timeline

**Estimated Duration**: 1 week

- Day 1: Baseline measurements + build size analysis
- Day 2: App performance profiling
- Day 3: Memory profiling + leak detection
- Day 4: Network performance testing
- Day 5: Optimization implementation
- Day 6: Re-testing + validation
- Day 7: Documentation + final commit

## Current Status

**Phase**: Baseline Measurements
**Progress**: 0%
**Next Step**: Measure debug/release build sizes

## Notes

- Development machine: 16GB RAM (resource-constrained)
- Using memory helper tools to prevent build failures
- Focus on practical, achievable optimizations
- Document all measurements for future reference
