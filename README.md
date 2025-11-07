# Trip Wizards

An AI-powered travel planning app built with Flutter, featuring trip planning, community sharing, subscription management, and enterprise organization tools.

## Features

- **AI-Powered Trip Planning**: Generate personalized itineraries using advanced AI
- **Community Features**: Share trips, connect with travelers, earn achievements
- **Subscription Management**: Multiple tiers with credit-based billing
- **Enterprise Mode**: Organization management, team collaboration, analytics
- **Cross-Platform**: iOS, Android, and Web support

## Tech Stack

- **Frontend**: Flutter (Dart) with Provider state management
- **Backend**: FastAPI (Python) with Firebase integration
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **AI Integration**: ADK submodule for travel assistance

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase project with Firestore and Auth enabled
- Python 3.11+ for backend

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd trip_wizards_app
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - Update Firebase configuration in `lib/services/firebase_service.dart`

4. Run the app:

   ```bash
   flutter run
   ```

### Backend Setup

1. Navigate to backend directory:

   ```bash
   cd backend
   ```

2. Install Python dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Run the backend server:

   ```bash
   uvicorn main:app --reload
   ```

## Beta Testing

### Installation Instructions

1. Download the APK from the releases section
2. Enable "Install from unknown sources" in Android settings
3. Install the APK and grant requested permissions

### Testing Checklist

- [ ] User registration and login
- [ ] Trip creation and planning
- [ ] Community features (sharing, comments)
- [ ] Subscription purchase flow
- [ ] Organization creation and management
- [ ] Offline functionality
- [ ] Performance on various devices

### Known Issues

- Firebase testing environment may show connection warnings (expected in test mode)
- Some features require backend server to be running

## Building for Production

### Android APK

```bash
flutter build apk --release
```

### iOS (requires macOS)

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Project Structure

```text
lib/
├── models/          # Data models
├── repositories/    # Data access layer
├── services/        # Business logic services
├── screens/         # UI screens
├── widgets/         # Reusable components
└── utils/           # Utility functions

backend/
├── src/
│   └── trip_wizards/  # FastAPI application
└── tests/            # Backend tests
```

## Contributing

1. Follow the Speckit development methodology
2. Ensure all tests pass
3. Run `flutter analyze` before committing
4. Update documentation as needed

## License

This project is proprietary software.

---

## Development Credits

This project was built entirely using **GitHub Copilot** with the assistance of **SPECKIT** in VS Code. The entire development process, from initial setup to feature implementation, security hardening, and deployment preparation, was accomplished through AI-powered development tools and methodologies.
