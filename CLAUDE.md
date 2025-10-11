# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GlucoUS is a personalized blood glucose meal recommendation app. It's a Flutter mobile app with a FastAPI backend that uses machine learning models to predict blood glucose responses to meals and recommend foods based on user profiles.

**Key Technologies:**
- Frontend: Flutter (Dart)
- Backend: FastAPI (Python)
- Database: MySQL
- ML Models: XGBoost (glucose prediction), BM25CosSim (food recommendation)
- External API: FatSecret API (food search and nutrition data)

## Common Commands

### Flutter App

```bash
# Install dependencies
flutter pub get

# Run on specific platform
flutter run -d linux
flutter run -d chrome
flutter run -d android

# Run with custom API base URL
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Build for release
flutter build apk  # Android
flutter build ios  # iOS

# Run tests
flutter test

# Check for issues
flutter doctor

# Analyze code
flutter analyze
```

### FastAPI Backend

```bash
# Start the server (from project root)
python -m uvicorn main:app --reload

# Or using fastapi CLI
fastapi dev main.py

# The API will be available at http://127.0.0.1:8000
# API documentation: http://127.0.0.1:8000/docs
```

### Environment Setup

The backend requires a `.env` file with database credentials and API keys:
```
DB_HOST=your_host
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=your_database
GEMINI_API_KEY=your_gemini_api_key  # Required for image analysis feature
```

### Python Dependencies

```bash
# Install required packages
pip install fastapi uvicorn mysql-connector-python python-dotenv \
            requests pydantic joblib pandas scikit-learn xgboost \
            google-generativeai pillow
```

## Architecture

### Application Flow

1. **Splash Screen** (`splash_screen.dart`): App entry point that checks user authentication via UUID
   - If user exists → navigate to Main screen
   - If user doesn't exist → navigate to Onboarding screen

2. **Authentication**: UUID-based, no traditional login
   - Device UUID is generated once and stored in SharedPreferences (`uuid_service.dart`)
   - UUID is sent via `X-Device-ID` header for all authenticated requests

3. **Main Screen** (`screens/main.dart`): Primary interface with three modes
   - Glucose Input Mode: Enter nutrition values to predict blood glucose
   - Food Detail Mode: View detailed food information from search
   - Profile Mode: View/edit user profile

### Backend Architecture

**Main Endpoints** (`main.py`):
- `POST /register`: Register new user with profile
- `GET /user/exists`: Check if user exists (by UUID)
- `GET /user`: Get user profile
- `PUT /user`: Update user profile
- `DELETE /user`: Delete user account
- `POST /predict`: Predict glucose response from nutrition input (requires user profile)
- `POST /recommend`: Get meal recommendations based on user profile
- `GET /search`: Search foods via FatSecret API
- `GET /food`: Get detailed food info including nutrition, ingredients, and images
- `POST /analyze-image`: AI-powered food image analysis using Google Gemini (detects multiple foods, estimates nutrition)

**Machine Learning Pipeline**:
1. Food recommendation uses BM25CosSim model (`MODEL_PATH`)
2. Glucose prediction uses two XGBoost models:
   - `XGB_g_max.pkl`: Predicts maximum glucose level
   - `XGB_delta_g.pkl`: Predicts glucose change (delta)
3. Both models use meal features (carbs, calories, protein, fat) + user features (age, BMI, weight, height, gender, baseline glucose)
4. Image analysis uses Google Gemini 2.0 Flash (via `google-generativeai` SDK):
   - Detects multiple foods in single image
   - Provides Korean language food names and descriptions
   - Estimates nutrition per food item with confidence levels

### Data Models

**UserProfile** (`lib/models/models.dart` and `main.py`):
- Basic info: name, age, gender, height, weight, BMI
- Health: diabetes type, average_glucose, activity_level, goal
- Dietary: meals (Breakfast/Lunch/Dinner), meal_method, dietary_restrictions, allergies

**Database Schema**:
- `users`: Core user information
- `user_meals`: Many-to-many relationship (user → meals)
- `user_dietary_restrictions`: Many-to-many relationship (user → restrictions)
- Meal IDs: {"Breakfast": 1, "Lunch": 2, "Dinner": 3}
- Restriction IDs: {"Vegetarian": 1, "Halal": 2, "Gluten-free": 3, "None": 0}

### Key Services

**ApiService** (`lib/services/api_service.dart`):
- Handles all HTTP communication with backend
- Implements LRU caching for search results and food details
- Uses compute() for offloading JSON parsing to background isolates
- Base URL: `http://127.0.0.1:8000` (configurable via dart-define)

**UUIDService** (`lib/services/uuid_service.dart`):
- Generates and persists device UUID for authentication
- UUID stored in SharedPreferences with key 'device_uuid'

**UserProvider** (`lib/services/user_provider.dart`):
- ChangeNotifier-based state management for user profile
- Not currently integrated into main app (direct API calls used instead)

## Important Patterns

### Error Handling

- Frontend: Uses try-catch with SnackBar notifications for user feedback
- Backend: FastAPI HTTPException with appropriate status codes
- FatSecret API calls have timeout protection and fallback logic

### Image Handling

- Configured for 100MB image cache to prevent buffer overflow on Android (see `lib/main.dart:9-10`)
- FatSecret images: Tries food.get.v4 first (with images), falls back to food.get, then recipe images
- Gemini image analysis: Supports multi-food detection with individual nutrition estimates (see `main.py:analyze_food_image_with_gemini`)

### Search Optimization

- Debouncing implemented via `Debouncer` class for search queries
- LRU cache prevents duplicate API calls
- Token-based request cancellation drops stale search results
- JSON decoding offloaded to compute() isolate

### Data Deduplication

- `_dedup_by_normalized_name()`: Removes duplicate foods (Generic type prioritized)
- `_dedup_str_list()`: Removes duplicate ingredients with normalization

## Testing

- Test directory exists at `/test` but is currently empty
- Flutter test framework is configured in `pubspec.yaml`

## Development Notes

- The app uses Korean language for UI text
- Server and app must be on same network for mobile testing (replace 127.0.0.1 with PC IP)
- Backend requires saved ML models in `./saved_models/` directory
- FatSecret API requires valid OAuth token (obtained via `fat_secret.py`)
- Database columns defined in `DB_COLUMNS` constant in main.py

## File Organization

```
lib/
├── main.dart                           # App entry point with image cache config
├── screens/                            # UI screens
│   ├── main.dart                      # Main screen with glucose prediction
│   ├── splash_screen.dart             # Initial loading screen
│   ├── onboarding_screen.dart         # Original onboarding (legacy)
│   ├── unified_onboarding_screen.dart # Unified onboarding flow
│   ├── user_profile_details_screen.dart # Profile view/edit
│   ├── food_detail_screen.dart        # Food information display
│   ├── account_settings_screen.dart   # Account management
│   ├── subscription_offer_screen.dart # Subscription/payment
│   └── *_test_screen.dart            # Various testing screens
├── services/                           # Business logic
│   ├── api_service.dart               # HTTP client with LRU cache
│   ├── user_provider.dart             # State management (unused)
│   ├── uuid_service.dart              # Device identification
│   └── debouncer.dart                 # Search debouncing
└── models/
    └── models.dart                    # Data models (UserProfile, Recommendation)

Backend:
├── main.py                            # FastAPI app with all endpoints
├── model.py                           # ML model loading/prediction
├── query.py                           # SQL query builders
├── preprocess.py                      # Data normalization
├── fat_secret.py                      # FatSecret OAuth token management
├── crawl.py                           # Data collection utilities
└── saved_models/                      # Trained ML models (BM25, XGBoost)
```
