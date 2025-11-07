# T034 Internal Beta & Store Submission

**Task**: T034 - Internal beta and store submission
**Started**: 2025-11-07
**Target**: App ready for public beta/release

## Objectives

1. **Prepare Release Builds**: Configure signing, build optimized APK/AAB
2. **Beta Testing Setup**: Configure internal testing channels
3. **Store Listing**: Create Play Store and App Store metadata
4. **Compliance**: Privacy policy, terms of service, data handling
5. **Beta Distribution**: Distribute to internal testers
6. **Feedback Collection**: Track and address beta feedback

## Phase 1: Release Build Preparation

### Android Release Build

#### 1. Verify Signing Configuration

File: `android/app/build.gradle.kts`

```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("../upload-keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(...)
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

**Status**: ✅ Already configured (upload-keystore.jks exists)

#### 2. Build Release APK/AAB

```bash
# For Play Store (Android App Bundle - recommended)
flutter build appbundle --release

# For direct distribution (APK)
flutter build apk --release --split-per-abi

# Check outputs
ls -lh build/app/outputs/bundle/release/
ls -lh build/app/outputs/apk/release/
```

**Target Size**: <50MB per APK, <100MB for AAB

#### 3. Version Management

File: `pubspec.yaml`

```yaml
version: 1.0.0+1  # version+buildNumber
```

**Beta versioning**: 1.0.0-beta.1+1, 1.0.0-beta.2+2, etc.

### iOS Release Build

#### 1. Configure Xcode Project

```bash
cd ios
open Runner.xcworkspace
```

- Set team and bundle identifier
- Configure code signing (automatic)
- Set deployment target (iOS 14.0+)
- Configure capabilities (Push Notifications, Sign in with Apple)

#### 2. Build Release IPA

```bash
flutter build ipa --release

# Or build in Xcode for TestFlight
# Product > Archive
```

### Version Codes

**Version Naming Scheme**:
- Public Beta: 1.0.0-beta.1, 1.0.0-beta.2
- Release Candidate: 1.0.0-rc.1
- Production: 1.0.0

## Phase 2: Beta Testing Setup

### Android (Google Play Console)

#### Internal Testing Track

1. **Create Internal Testing Release**
   - Go to Play Console > Testing > Internal testing
   - Upload AAB (app bundle)
   - Add release notes
   - Roll out to internal testers

2. **Tester Email List**
   - Create tester list in Play Console
   - Add team email addresses
   - Send invite links

3. **Feedback Collection**
   - Enable crash reporting (Firebase Crashlytics)
   - Monitor Play Console feedback
   - Set up feedback form (Google Forms)

#### Closed Testing Track (Alpha)

1. Create closed testing release
2. Invite wider group (50-100 testers)
3. Collect structured feedback
4. Iterate based on feedback

### iOS (TestFlight)

#### Internal Testing

1. **Upload Build to App Store Connect**
   - Use Xcode Archive > Distribute
   - Or use Transporter app

2. **Add Internal Testers**
   - Up to 100 testers
   - No review required
   - Instant distribution

3. **Beta Testing Period**
   - 90 days per build
   - Collect crash reports
   - Review feedback

#### External Testing

1. Submit for Beta App Review
2. Add external testers (up to 10,000)
3. Collect public beta feedback

## Phase 3: Store Listing Metadata

### Google Play Store

#### Required Assets

1. **App Icon**
   - 512x512 PNG (Google Play)
   - Must match in-app icon

2. **Screenshots**
   - Phone: 2-8 screenshots (JPEG/PNG)
   - Tablet: 2-8 screenshots (optional)
   - Sizes: Min 320px, Max 3840px

3. **Feature Graphic**
   - 1024x500 PNG
   - Displayed in Play Store

4. **Short Description**
   - 80 characters max
   - "Plan perfect trips with AI-powered travel planning"

5. **Full Description**
   - 4000 characters max
   - Describe features, benefits

6. **App Category**
   - Primary: Travel & Local
   - Secondary: None

7. **Content Rating**
   - Fill IARC questionnaire
   - Expected: ESRB Everyone, PEGI 3

#### Store Listing Text

**App Name**: Trip Wizards

**Short Description**:
> AI-powered travel planning. Create itineraries, discover destinations, collaborate with friends.

**Full Description**:
```
Trip Wizards is your intelligent travel companion, helping you plan perfect trips with ease.

KEY FEATURES:
✈️ Smart Itinerary Builder
   • Create day-by-day travel plans
   • Add activities, accommodations, transportation
   • Drag-and-drop reordering

🤝 Collaborative Trip Planning
   • Invite friends and family
   • Real-time collaboration
   • Share itineraries instantly

🏢 Enterprise Features
   • Organization accounts
   • Pooled AI credits
   • SSO integration
   • Admin reporting

🎯 Gamification & Community
   • Earn badges for travel achievements
   • Share trips with community
   • Discover popular destinations
   • Like and clone public trips

🔒 Secure & Private
   • Firebase authentication
   • Encrypted data storage
   • Privacy-first design

💳 Flexible Pricing
   • Free tier with basic features
   • AI-powered upgrades available
   • Organization plans for businesses

Download Trip Wizards and start planning your next adventure today!
```

### Apple App Store

#### Required Assets

1. **App Icon**
   - 1024x1024 PNG (no transparency)

2. **Screenshots**
   - 6.5" display: 2-10 screenshots
   - 5.5" display: 2-10 screenshots
   - iPad Pro: 2-10 screenshots (optional)

3. **App Preview Video** (optional)
   - 15-30 seconds
   - Showcase key features

4. **App Description**
   - Same as Play Store (with adjustments for Apple guidelines)

5. **Keywords**
   - 100 characters max
   - "travel,planning,itinerary,trip,vacation,collaborate,AI"

6. **Support URL**
   - Required: https://tripwizards.app/support

7. **Privacy Policy URL**
   - Required: https://tripwizards.app/privacy

## Phase 4: Compliance & Legal

### Privacy Policy

**Required Sections**:
1. Data Collection
   - User account info (email, name)
   - Trip data (destinations, dates)
   - Usage analytics (Firebase Analytics)

2. Data Usage
   - Service provision
   - Feature improvement
   - Analytics

3. Data Sharing
   - Firebase/Google services
   - No third-party marketing

4. User Rights
   - Access data
   - Delete account
   - Export data

5. Contact Information

**Tool**: Use privacy policy generator (e.g., PrivacyPolicies.com)

### Terms of Service

**Required Sections**:
1. Service Description
2. User Responsibilities
3. Content Ownership
4. Liability Limitations
5. Termination Conditions
6. Dispute Resolution

### Data Handling Declarations

**Google Play Data Safety**:
- Declare all data collected
- Specify usage purposes
- Indicate if data is shared
- Explain security measures

**Apple App Store Privacy Nutrition Label**:
- Similar to Google Play
- More prominent display
- User reviews if incomplete

## Phase 5: Beta Distribution

### Internal Beta (Week 1)

**Testers**: Core team (5-10 people)

**Testing Focus**:
- Critical bugs
- Core functionality
- Authentication flows
- Payment integration
- Crash stability

**Criteria for Alpha**:
- Zero crashes in critical flows
- All core features functional
- Authentication working reliably

### Closed Alpha (Week 2-3)

**Testers**: Extended team + trusted users (50-100 people)

**Testing Focus**:
- All features
- Edge cases
- Performance issues
- Usability feedback
- Feature requests

**Criteria for Public Beta**:
- <1% crash rate
- All major features complete
- Positive feedback from alpha testers
- Performance acceptable

### Public Beta (Week 4+)

**Testers**: General public (1000+ users)

**Testing Focus**:
- Real-world usage
- Scale testing
- Feature validation
- Market fit
- Onboarding experience

**Criteria for Production**:
- <0.5% crash rate
- Positive user feedback (>4.0 rating)
- All blocking bugs fixed
- Store review guidelines met

## Phase 6: Feedback Collection & Iteration

### Feedback Channels

1. **In-App Feedback**
   - "Send Feedback" button
   - Links to feedback form

2. **Beta Tester Emails**
   - Weekly check-in emails
   - Survey after 1 week of use

3. **Analytics**
   - Firebase Analytics events
   - Crash reporting (Crashlytics)
   - User flow analysis

4. **Direct Communication**
   - Beta tester Slack/Discord
   - Email support responses

### Metrics to Track

**Technical Metrics**:
- Crash rate (target: <1%)
- ANR rate (target: <0.5%)
- App startup time (target: <3s)
- API error rate (target: <1%)

**User Metrics**:
- User retention (D1, D7, D30)
- Feature adoption rates
- Session length
- User satisfaction (NPS)

### Iteration Plan

**Week 1** (Internal Beta):
- Fix critical bugs
- Improve stability
- Polish core features

**Week 2-3** (Closed Alpha):
- Address alpha feedback
- Add minor features
- Improve UX based on feedback

**Week 4+** (Public Beta):
- Monitor metrics
- Fix reported bugs
- Prepare for production

## Checklist

### Pre-Beta Release
- [ ] Release build successfully created
- [ ] App signed with production certificate
- [ ] All core features functional
- [ ] Critical bugs fixed
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] Store listing prepared
- [ ] Beta tester list ready
- [ ] Feedback forms created
- [ ] Analytics configured

### Beta Testing
- [ ] Internal beta distributed
- [ ] Initial feedback collected
- [ ] Critical issues fixed
- [ ] Closed alpha distributed
- [ ] Alpha feedback incorporated
- [ ] Public beta submitted for review
- [ ] Public beta approved
- [ ] Public beta feedback collected

### Store Submission
- [ ] App Store review guidelines checked
- [ ] Play Store policies reviewed
- [ ] All required metadata uploaded
- [ ] Screenshots prepared
- [ ] Privacy labels completed
- [ ] Content rating obtained
- [ ] Beta testing complete
- [ ] Production build submitted
- [ ] Store review passed

## Timeline

**Week 1**: Release build prep + Internal beta
**Week 2**: Closed alpha testing
**Week 3**: Alpha feedback + iterations
**Week 4**: Public beta submission
**Week 5+**: Public beta testing + final polish
**Week 6-7**: Production submission + review

**Total Duration**: 6-8 weeks from start to production release

## Current Status

**Phase**: Planning
**Progress**: 0%
**Next Step**: Prepare release builds

## Notes

- Beta testing is iterative - expect 2-3 beta versions
- Store review can take 1-7 days (Apple), instant-3 days (Google)
- Privacy policy and TOS are legal requirements - consult lawyer if needed
- Beta feedback is critical - allocate time for iterations
- Consider using Firebase App Distribution for flexible beta distribution
