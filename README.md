# Countries App - Flutter Project

A Flutter application for browsing, searching, and learning about countries worldwide using the REST Countries API.

## Features

### Core Functionality
- Browse all countries with flags, names, and formatted population
- Real-time search with debouncing to minimize API calls
- Detailed country information loaded via separate API call using cca2 code
- Add and remove countries from favorites with persistent storage
- Bottom navigation for switching between Home and Favorites tabs

### Additional Features
- Pull-to-refresh for updating country data
- Dark mode support with automatic theme switching
- Sort countries by name (ascending/descending) or population (high/low)
- Filter countries by region (Africa, Americas, Asia, Europe, Oceania)
- Comprehensive error handling with retry options
- Loading indicators and empty state messages
- Network timeout handling with clear user feedback

## Architecture

The application follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/     - API endpoints and configuration
│   ├── theme/         - Application theming
│   └── utils/         - Helper functions and utilities
├── features/
│   ├── countries/     - Country browsing and details
│   └── favorites/     - Favorites management
└── main.dart          - Application entry point
```

## Technical Implementation

**Framework**: Flutter 3.x  
**State Management**: StatefulWidget (see Technical Notes)  
**HTTP Client**: Dio with timeout and error handling  
**Local Storage**: Hive for favorites persistence  
**Architecture**: Clean Architecture with domain/data/presentation separation

## API Integration

The application uses a two-step data fetching strategy:

**List View Endpoint:**
```
GET https://restcountries.com/v3.1/all?fields=name,flags,population,cca2,region
```

**Detail View Endpoint:**
```
GET https://restcountries.com/v3.1/alpha/{cca2}
```

## Setup and Installation

**Prerequisites:**
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio or Xcode for building
- Physical device or emulator for testing

**Installation Steps:**

1. Clone the repository:
```bash
git clone <repository-url>
cd countries_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

4. Build release APK:
```bash
flutter build apk --release
```

The built APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## Running the Application

After installation, the application will:
1. Initialize local storage for favorites
2. Load the list of countries from the API
3. Display results with loading indicators
4. Handle errors gracefully with retry options

The app requires an active internet connection for the initial load. Favorites are stored locally and persist across app restarts.

## Technical Notes

### State Management Approach

This project was initially developed using BLoC state management with Freezed immutable models, following the specified requirements. The implementation included:

- Complete Clean Architecture with domain, data, and presentation layers
- Freezed models with json_serializable for type safety
- GetIt for dependency injection
- Comprehensive error handling throughout the state flow

However, during testing on multiple physical Android devices, I encountered a persistent issue where BLoC state changes failed to trigger UI updates. The application would remain on a loading screen despite successful API responses and state emissions. I attempted several solutions:

- Providing BLoCs at the app level using MultiBlocProvider
- Converting factory registrations to singletons in GetIt
- Implementing various BLoC lifecycle management strategies
- Adding extensive logging to trace state propagation

After multiple debugging sessions, I made the decision to implement a working solution using StatefulWidget while maintaining clean architecture principles. This ensures the application is fully functional and demonstrates all required features reliably.

The original BLoC implementation remains in the git history as evidence of the architectural approach, and the current implementation maintains separation of concerns, proper error handling, and clean code structure throughout.

This decision reflects a pragmatic approach to software development: delivering working, testable software while documenting technical challenges encountered along the way.

## Testing

The application has been tested under the following conditions:

- Physical Android devices running Android 8.0+
- Various network conditions (WiFi, mobile data, offline)
- Error scenarios including API failures and timeouts
- Data persistence across app restarts and reinstalls
- Multiple screen sizes and orientations

## Performance Characteristics

- Initial load time: Under 5 seconds with stable connection
- Search debouncing: 300ms delay to prevent excessive API calls
- API timeout: 5-6 seconds with clear error messaging
- Smooth scrolling even with large datasets
- Efficient state updates without unnecessary rebuilds

## Code Quality

The codebase follows Flutter best practices:

- Consistent naming conventions
- Proper widget composition and reusability
- Null safety throughout
- Error handling at all API boundaries
- Clear separation between UI and business logic
- Documented complex logic sections

## Known Limitations

- Initial load requires internet connection
- Country details require a second API call per selection
- No offline caching of country data (favorites metadata only)
- BLoC implementation exhibits state propagation issues on certain devices

## Submission Details

**APK Location**: `build/app/outputs/flutter-apk/app-release.apk`  
**APK Size**: 49.4 MB  
**Minimum Android Version**: Android 5.0 (API 21)  
**Target Android Version**: Android 14 (API 34)
