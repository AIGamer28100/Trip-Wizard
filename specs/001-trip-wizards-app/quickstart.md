# Quickstart: Trip Wizards

## Prerequisites

- Flutter 3.0+
- Python 3.11+
- Conda
- Git
- Android Studio or Xcode or VS Code with Flutter extension

## Setup

1. Clone repo and checkout branch:

   ```bash
   git clone https://github.com/AIGamer28100/Trip-Wizard.git
   cd Trip-Wizard
   git checkout 001-trip-wizards-app
   ```

2. Setup ADK submodule:

   ```bash
   git submodule update --init --recursive
   cd backend/adk
   # Follow ADK docs to start server
   ```

3. Setup backend:

   ```bash
   cd backend
   conda env create -f environment.yml
   conda activate tripwizards
   poetry install
   uvicorn app.main:app --reload
   ```

4. Setup frontend:

   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

## Environment Variables

- ADK_URL
- ADK_API_KEY
- FIREBASE_CREDENTIALS
- STRIPE_KEY

## Testing

- Backend: `pytest`
- Frontend: `flutter test`
