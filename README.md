# Sky Sentinel – Weather Alerter App

A production-ready Flutter application that monitors weather data for the user's current location and sends notifications when specific weather conditions meet user-defined thresholds.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Architecture

### BLoC + Repository Pattern

Sky Sentinel follows **Clean Architecture** principles with a layered structure:

```
UI (Pages/Widgets)
    ↓
BLoC (Business Logic)
    ↓
Repository (Abstraction Layer)
    ↓
Data Sources (Remote API + Local Cache)
```

**BLoCs implemented:**
- **WeatherBloc** — Manages current weather and forecast data, handles loading/success/error states
- **LocationBloc** — Handles GPS permission requests and coordinate fetching
- **SettingsBloc** — Manages user-defined alert thresholds (temperature, rain toggle)

**Key patterns:**
- Repository pattern abstracts remote API and local cache behind a single interface
- If the API call fails, the repository automatically falls back to cached data
- Dependency injection via `get_it` service locator
- Equatable for value equality in BLoC states and events

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, initialization
├── app.dart                           # App shell with navigation
├── injection_container.dart           # Dependency injection setup
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # OpenWeatherMap API URLs
│   │   └── app_constants.dart         # App-wide constants & keys
│   ├── errors/
│   │   ├── exceptions.dart            # Custom exception types
│   │   └── failures.dart              # Failure types for error handling
│   ├── theme/
│   │   ├── app_colors.dart            # Dark theme color palette
│   │   └── app_theme.dart             # Material theme configuration
│   └── utils/
│       ├── logger.dart                # App-wide logger
│       └── weather_icon_helper.dart   # Weather condition → icon mapping
│
├── features/
│   ├── weather/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── weather_model.dart    # Current weather data model
│   │   │   │   └── forecast_model.dart   # 5-day forecast data model
│   │   │   ├── datasources/
│   │   │   │   ├── weather_remote_datasource.dart   # Dio-based API calls
│   │   │   │   └── weather_local_datasource.dart    # SharedPreferences cache
│   │   │   └── repositories/
│   │   │       └── weather_repository_impl.dart     # Repository implementation
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── weather_repository.dart          # Repository interface
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── weather_bloc.dart
│   │       │   ├── weather_event.dart
│   │       │   └── weather_state.dart
│   │       ├── pages/
│   │       │   ├── dashboard_page.dart     # Main weather dashboard
│   │       │   └── forecast_page.dart      # Weekly forecast view
│   │       └── widgets/
│   │           ├── alert_banner.dart        # Threshold alert banner
│   │           ├── alert_modal.dart         # Full-screen alert overlay
│   │           ├── hourly_outlook_section.dart
│   │           └── weather_info_card.dart
│   │
│   ├── location/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── location_datasource.dart
│   │   │   └── repositories/
│   │   │       └── location_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── location_repository.dart
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── location_bloc.dart
│   │           ├── location_event.dart
│   │           └── location_state.dart
│   │
│   ├── settings/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── alert_settings.dart
│   │   │   ├── datasources/
│   │   │   │   └── settings_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── settings_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── settings_bloc.dart
│   │       │   ├── settings_event.dart
│   │       │   └── settings_state.dart
│   │       └── pages/
│   │           └── settings_page.dart
│   │
│   ├── notifications/
│   │   └── notification_service.dart     # Local notification management
│   │
│   └── background/
│       └── background_worker.dart        # WorkManager background tasks
```

---

## Features

- **Real-time Weather** — Current weather data fetched from OpenWeatherMap API
- **5-Day Forecast** — Daily forecast with high/low temperatures and conditions
- **Smart Alerts** — User-configurable temperature threshold and rain detection
- **Background Monitoring** — Periodic weather checks every 15 minutes via WorkManager
- **Push Notifications** — High-priority local notifications when conditions are met
- **Offline Support** — Last fetched data cached locally via SharedPreferences
- **Alert Highlights** — Opening the app from a notification highlights the triggered condition
- **Pull-to-Refresh** — Swipe down to refresh weather data on Dashboard and Forecast
- **Dark UI** — Premium dark theme inspired by atmospheric monitoring interfaces

---

## Generative AI Usage

This project was developed with the assistance of **Claude (Anthropic)** via GitHub Copilot.

### How AI was used:

1. **Architecture Design** — AI helped design the Clean Architecture folder structure and the BLoC + Repository pattern implementation
2. **Code Generation** — Full project code was generated based on detailed technical requirements
3. **UI Implementation** — Dark-themed UI was built following provided design mockups
4. **Integration Logic** — Background worker, notification service, and caching logic were designed and implemented

### Sample Prompts Used:

- *"You are a senior Flutter engineer. Build a complete production-ready Flutter application called Sky Sentinel that monitors weather data and sends notifications when conditions meet user-defined thresholds."*
- *"Implement WeatherBloc with flutter_bloc that fetches current weather and 5-day forecast, handles loading/success/error states, and falls back to cached data on failure."*
- *"Create a background worker using workmanager that runs every 15 minutes, fetches weather data, compares against user thresholds, and triggers flutter_local_notifications."*
- *"Build a dark-themed dashboard UI matching the provided design screenshots with temperature display, info cards, hourly outlook, and alert banners."*

---

## How to Run

### Prerequisites

- Flutter SDK 3.x+ (stable channel)
- Dart SDK 3.8+
- Android Studio or VS Code with Flutter extensions
- An OpenWeatherMap API key ([Get one free here](https://openweathermap.org/api))

### Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd intlmachines
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app** (pass your API key via `--dart-define`):
   ```bash
   flutter run --dart-define=OWM_API_KEY=your_api_key_here
   ```

### For Release Build:
```bash
flutter build apk --release --dart-define=OWM_API_KEY=your_api_key_here
```

---

## Screenshots

| Dashboard | Weekly Forecast | Alert Modal |
|:---------:|:--------------:|:-----------:|
| ![Dashboard](screenshots/dashboard.png) | ![Forecast](screenshots/forecast.png) | ![Alert](screenshots/alert.png) |

| Settings |
|:--------:|
| ![Settings](screenshots/settings.png) |

> Add screenshots to a `screenshots/` directory in the project root.

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x |
| State Management | flutter_bloc 9.x |
| Networking | Dio 5.x |
| Location | geolocator 13.x |
| Local Storage | shared_preferences 2.x |
| Background Tasks | workmanager 0.5.x |
| Notifications | flutter_local_notifications 18.x |
| DI | get_it 8.x |
| Logging | logger 2.x |

---

## Error Handling

- **Network failures** — Falls back to cached data with user-friendly error message
- **API errors** — Displays error state with retry option
- **Invalid JSON responses** — Caught in model parsing with CacheException
- **Location permission denied** — Shows dedicated permission denied state with instructions
- **Location services disabled** — Prompts user to enable GPS

---

## License

This project is for educational and assessment purposes.
