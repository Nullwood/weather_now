# Weather Now - AI Coding Agent Instructions

## Project Overview

**weather_now** is a Flutter cross-platform weather application using the **Open-Meteo API**. Users authenticate locally, select a city, and view real-time weather data and hourly forecasts. No backend server—all data is client-side with SharedPreferences for persistence.

## Architecture

### Service Layer (Critical Data Flows)

- **AuthService** (`lib/services/auth_service.dart`): Static methods for user registration/login with SHA-256 password hashing via `crypto` package. Stores user credentials in SharedPreferences as JSON.
- **WeatherService** (`lib/services/weather_service.dart`): Fetches current weather and hourly forecasts from Open-Meteo API using city coordinates from CityStore.
- **CityStore** (`lib/services/city_store.dart`): Singleton-like in-memory state holding the currently selected city (defaults to first city in list).

### Models

- **City** (`lib/models/city_model.dart`): Name + latitude/longitude for API calls.
- **Weather** (`lib/models/weather_model.dart`): Maps JSON responses to Dart objects (currently partial implementation).
- **Cities Data** (`lib/data/cities.dart`): Hardcoded list of 8 Kazakhstan cities + 1 international city.

### UI Screens (lib/screens/)

- **LoginScreen**: Username/password entry, calls `AuthService.login()`.
- **RegisterScreen**: User registration with `AuthService.register()`.
- **HomeScreen**: Displays current weather using `WeatherService.fetchCurrentWeather()` in FutureBuilder.
- **ForecastScreen**: Shows hourly forecast via `fetchHourlyForecast()`.
- **SettingsScreen**: Likely for city selection and user preferences.

### Navigation Pattern

`main.dart` uses `FutureBuilder` with `AuthService.isLoggedIn()` to conditionally route to LoginScreen or HomeScreen on app startup.

## Key Implementation Patterns

### Async/Await Pattern

All service methods are `Future`-based. Screens wrap them in `FutureBuilder<T>` with three states:

```dart
FutureBuilder<Map<String, dynamic>>(
  future: WeatherService().fetchCurrentWeather(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) return const Center(child: Text('Error'));
    return YourWidget(data: snapshot.data!);
  },
)
```

### SharedPreferences Storage

- Login state: `_currentUserKey = 'current_user'` (string)
- User credentials: `_usersKey = 'users'` (JSON-encoded Map<String, String>)
- Follow this pattern when adding new persistent data.

### Static Service Methods

Services use `static` methods—no instantiation required. This is acceptable for simple apps but creates tight coupling (consider dependency injection for larger projects).

### API Integration

- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Parameters**: latitude, longitude, forecast types (current, hourly with temperature, wind, precipitation)
- **Response**: Nested JSON with `current` and `hourly` objects. Always parse `response.body` with `jsonDecode()`.

## Development Workflows

### Build & Run

```bash
flutter run                    # Debug mode (emulator/device)
flutter run --release         # Production build
```

### Testing & Analysis

```bash
flutter analyze               # Lint check (uses flutter_lints)
flutter test                  # Run widget tests (test/ dir)
```

### Android Build Issue (Current)

**Java 17 Required**: Android Gradle plugin requires Java 17+. Current environment has Java 11.

- Fix: Update `JAVA_HOME` or `org.gradle.java.home` in `android/gradle.properties`
- Reference: `pubspec.yaml` targets SDK `^3.9.2`

## Code Style & Conventions

- **Linting**: Enabled via `package:flutter_lints` in `analysis_options.yaml` (default Flutter rules).
- **Naming**: Follow Dart conventions (camelCase variables, PascalCase classes).
- **Strings**: Use single quotes (Flutter standard, though not enforced here).
- **Null Safety**: Project uses non-null-by-default—use `?` for nullable types and `!` sparingly.

## Common Tasks

### Adding a New Screen

1. Create file in `lib/screens/my_screen.dart` extending `StatelessWidget` (preferred for data display) or `StatefulWidget` (for user input).
2. Use FutureBuilder for service calls.
3. Add route in main.dart or a router if one exists.

### Adding Persistent Data

1. Add key constant to appropriate service (e.g., `AuthService._settingsKey`).
2. Use `SharedPreferences` getInstance → getString/setString for strings, jsonDecode/jsonEncode for complex objects.

### Fetching New Weather Parameters

1. Update `WeatherService.url` query string with new parameters (e.g., `&daily=...`).
2. Parse new fields in `fetchCurrentWeather()` or create `fetchDailyForecast()`.
3. Update model or response map structure.

### Adding Cities

1. Edit `lib/data/cities.dart`: append City object with name, lat, lon.
2. Implement city selection UI in SettingsScreen.
3. Update `CityStore.currentCity` when user selects a new city.

## Dependencies Overview

- **flutter**: UI framework (Material Design).
- **shared_preferences**: ^2.1.1 — Local persistence.
- **crypto**: ^3.0.7 — SHA-256 hashing for passwords.
- **http**: ^1.2.0 — HTTP requests to Open-Meteo API.
- **intl**: ^0.18.1 — Internationalization (prepared but not heavily used yet).

## Critical Notes

- **No Backend**: All auth is local; security relies on device storage security.
- **Global State**: CityStore uses static state—switching cities updates all screens automatically.
- **No State Management**: No Provider, Riverpod, or Bloc yet; direct service calls in screens.
- **Error Handling**: Minimal—add null checks and try-catch in production code.

---

_Last Updated: 2025-02-04 | Flutter 3.9.2+ | Dart 3.9.2+_
