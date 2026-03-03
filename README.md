# Countries App

A Flutter mobile application for browsing and exploring information about countries around the world. The app fetches data from the REST Countries API and provides an intuitive interface for users to search, view details, and save their favorite countries.

## Features

The application includes the following functionality:

- View a scrollable list of all countries with their flags, names, and populations
- Search for countries by name with debounced input
- View detailed information about each country including capital, region, subregion, area, and timezones
- Mark countries as favorites and persist selections locally
- Navigate between Home and Favorites screens using bottom navigation
- Pull-to-refresh to update country data
- Hero animations for smooth transitions between screens
- Loading states with shimmer effects
- Error handling with retry options
- Support for both light and dark themes

## Architecture

The project follows Clean Architecture principles with clear separation between layers:

**Presentation Layer**
- UI components (pages and widgets)
- BLoC for state management
- User interaction handling

**Domain Layer**
- Business entities
- Repository interfaces
- Use cases containing business logic

**Data Layer**
- API datasources
- Repository implementations
- Data models with JSON serialization

This architecture provides maintainability, testability, and scalability.

## Technology Stack

### Core Dependencies
- flutter_bloc (^8.1.6) - State management using the BLoC pattern
- equatable (^2.0.5) - Value equality for state objects
- get_it (^8.0.2) - Dependency injection and service location

### Networking
- dio (^5.7.0) - HTTP client for API calls
- dio_cache_interceptor (^3.5.0) - Caching layer for API responses
- dio_cache_interceptor_hive_store (^3.2.2) - Hive storage for cached data

### Storage
- hive (^2.2.3) - Local key-value database
- hive_flutter (^1.1.0) - Flutter integration for Hive
- path_provider (^2.1.5) - Access to file system paths

### UI Components
- cached_network_image (^3.4.1) - Efficient image loading and caching
- shimmer (^3.0.0) - Loading placeholder animations

### Utilities
- dartz (^0.10.1) - Functional programming utilities (Either type for error handling)

### Development Tools
- build_runner (^2.4.13) - Code generation
- freezed (^2.5.2) - Data class generation
- json_serializable (^6.8.0) - JSON serialization
- hive_generator (^2.0.1) - Hive adapter generation

## Setup Instructions

### Prerequisites
- Flutter SDK 3.11.1 or higher
- Dart SDK 3.11.1 or higher
- Android Studio or VS Code with Flutter extensions
- An Android or iOS emulator, or a physical device

### Installation Steps

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

### Building for Release

To generate a release APK:
```bash
flutter build apk --release
```

The APK file will be located at `build/app/outputs/flutter-apk/app-release.apk`

## API Integration

The application uses the REST Countries API (https://restcountries.com) with an optimized two-step fetching strategy:

**Step 1 - List View (Minimal Data)**
```
GET https://restcountries.com/v3.1/all?fields=name,flags,population,cca2
GET https://restcountries.com/v3.1/name/{name}?fields=name,flags,population,cca2
```

**Step 2 - Detail View (Full Data)**
```
GET https://restcountries.com/v3.1/alpha/{code}?fields=name,flags,population,capital,region,subregion,area,timezones
```

This approach minimizes data transfer and improves performance by fetching only required fields for each screen.

## Project Structure

```
lib/
├── core/
│   ├── constants/         # API endpoints and app constants
│   ├── di/               # Dependency injection configuration
│   ├── errors/           # Error types and failure classes
│   ├── theme/            # App theme configuration
│   └── utils/            # Helper functions and extensions
├── features/
│   ├── countries/
│   │   ├── data/         # API implementation and models
│   │   ├── domain/       # Entities, repositories, and use cases
│   │   └── presentation/ # UI and BLoC
│   ├── favorites/
│   │   ├── data/         # Local storage implementation
│   │   ├── domain/       # Business logic for favorites
│   │   └── presentation/ # Favorites UI
│   └── home/
│       └── presentation/ # Navigation and main screens
└── main.dart             # Application entry point
```

## Design Decisions

**State Management - BLoC Pattern**

I chose BLoC for state management because it provides clear separation between business logic and UI, makes the app more testable, and handles complex state scenarios predictably. The pattern works well for this app's requirements of managing country lists, search results, and favorites.

**Architecture - Clean Architecture**

Clean Architecture was selected to ensure the codebase remains maintainable as it grows. The separation of concerns makes it easier to test individual components, swap implementations (like changing from Hive to SQLite), and onboard new developers. Each layer has a single responsibility and dependencies flow inward.

**Networking - Dio**

Dio was chosen over the basic HTTP package because it provides built-in support for interceptors (essential for caching), better error handling, request cancellation, and convenient features like automatic retry logic. The caching interceptor significantly improves performance by storing API responses.

**Local Storage - Hive**

Hive is a lightweight, fast NoSQL database that doesn't require native dependencies. It's perfect for storing favorites since the data structure is simple key-value pairs. The API is straightforward and type-safe when using generated adapters.

**Error Handling - Either Type**

Using the Either type from the dartz package provides explicit error handling without throwing exceptions. This makes error cases part of the function signature, forcing proper handling at compile time and improving code reliability.

## Running Tests

Execute the test suite with:
```bash
flutter test
```

## Configuration

No additional configuration or environment variables are required. The app connects directly to the public REST Countries API.

## Author

BAHATI Steven
