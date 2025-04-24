# DumpShine Flutter Project Structure
## 1. Overview
This document outlines the architecture and code structure of the DumpShine Flutter application. The application follows a Domain-Driven Design (DDD) approach with a clear separation of concerns, organized into features and layers.

## 2. Project Architecture
The project follows a layered architecture with feature-based organization:

```
lib/
├── app.dart                 # Application entry point with ProviderScope and MaterialApp configuration
├── config.dart              # Environment-specific configuration (API URLs, feature flags, etc.)
├── auth/                    # Authentication feature
│   ├── domain/              # User, Driver entities and authentication business logic
│   ├── infrastructure/      # Authentication implementation with remote/local data sources
│   └── presentation/        # Sign-in screens, profile screens, and auth state providers
├── core/                    # Core functionality shared across features
│   ├── core_features/       # Cross-cutting application features
│   │   ├── locale/          # Internationalization system with locale storage and switching
│   │   ├── theme/           # App theming with light/dark mode, custom colors and styles
│   │   ├── local_storage/   # Type-safe key-value storage with SharedPreferences and secure storage
│   │   └── pip_service.dart # Picture-in-picture handling for background operation
│   ├── infrastructure/      # Foundation services and implementations
│   │   ├── error/           # Structured error handling with domain-specific exceptions
│   │   ├── local/           # Local storage facades and persistence utilities
│   │   ├── network/         # API clients, interceptors, connection checking
│   │   └── services/        # Core services (caching, logging, initialization)
│   └── presentation/        # UI foundation elements
│       ├── components/      # Shared UI components (drawers, errors, etc.)
│       ├── helpers/         # UI helper functions (platform, theme, localization)
│       ├── routing/         # Go Router configuration with auth-aware navigation
│       ├── screens/         # Base screens (splash, error, etc.)
│       ├── styles/          # Design system foundation (sizes, typography, borders)
│       └── widgets/         # Reusable widgets (platform-adaptive, responsive, etc.)
├── features/                # Main application features (vertically sliced)
│   ├── home/                # Home feature with trip management
│   │   ├── domain/          # Trip, Site, and other business entities
│   │   ├── infrastructure/  # Data sources and repositories for trips, sites, etc.
│   └── presentation/        # Home UI components and state management
│   ├── map/                 # Map feature for location tracking and navigation
│   ├── home_shell/         # Shell navigation for bottom tabs and nested routing
│   └── settings/           # Application settings and user preferences
└── utils/                   # Shared utility functions and extensions
    └── logger.dart          # Application logging configuration
```

### Key Architectural Points

1. **Feature-First Organization**: The codebase is organized around business features rather than technical layers, allowing each feature to be self-contained.

2. **Clean Architecture Principles**: Each feature follows Domain-Driven Design with clear separation between:
   - Domain layer: Pure business logic and entities
   - Infrastructure layer: Technical implementations and external integrations
   - Presentation layer: UI components and state management

3. **Core Module**: The `core/` directory houses shared functionality used throughout the application:
   - Core features: Cross-cutting concerns like theming and localization
   - Infrastructure: Low-level technical services such as network and storage
   - Presentation: Framework for UI elements and patterns

4. **Navigation Structure**: The application uses Go Router with a stateful shell route pattern that enables:
   - Bottom navigation with preserved state across tabs
   - Deep linking capability
   - Authentication-aware routing with guards
   - Type-safe routes with code generation

5. **State Management**: The application uses Riverpod throughout with:
   - Providers organized by feature
   - Functional programming principles with Option types for nullability
   - AsyncValue for handling loading/error states
   - Code generation with @riverpod annotations

## 3. Layer Organization
Each feature follows a consistent layer organization:
```
feature/
├── domain/                  # Business objects and logic
├── infrastructure/          # Implementation details
│   ├── data_sources/        # Data sources (remote/local)
│   ├── dtos/                # Data Transfer Objects
│   └── repos/               # Repositories
└── presentation/           
    ├── providers/           # State management
    ├── screens/             # UI screens
    └── widgets/             # Reusable UI components
```

### Domain Layer
The domain layer contains the core business objects, rules, and logic of the application:
- **Entities**: Business objects like `Driver`, `User`, `Site`, `Trip` that represent the core domain concepts
- **Value Objects**: Immutable objects that describe characteristics of entities
- **Logic**: Business rules that operate on domain objects
- **Interfaces**: Defines contracts for repositories that will be implemented in the infrastructure layer

Example from Auth feature:
```
auth/domain/
├── driver.dart         # Core entity representing a driver
├── user.dart           # Base user entity
└── sign_in_with_vehicle_info.dart  # Value object for sign-in data
```

### Infrastructure Layer
This layer handles all external interactions and implements the interfaces defined in the domain layer:
- **Data Sources**: Classes that handle direct communication with external systems
  - **Remote Data Sources**: API clients for server communication
  - **Local Data Sources**: Storage implementations for device persistence
- **DTOs (Data Transfer Objects)**: Objects that map external data to domain entities and vice versa
- **Repositories**: Implementations of domain interfaces that coordinate between data sources

Example from Home feature:
```
infrastructure/
├── data_sources/
│   ├── sites_remote_data_source.dart  # Handles API calls for sites data
│   └── gps_local_data_source.dart     # Manages local GPS data
├── dtos/
│   └── site_dto.dart                  # Maps API response to domain Site entity
└── repos/
    └── orders_repo.dart               # Coordinates between data sources
```

### Presentation Layer
The presentation layer handles all UI-related concerns and state management:
- **Providers**: Riverpod-based state management
  - State classes with clear lifecycle management
  - AsyncValue wrappers for loading/error states
  - Feature-specific state management logic
- **Screens**: Full pages or major UI components in the application
  - Each screen composes multiple widgets
  - Handles layout and screen-specific logic
- **Widgets**: Reusable UI components specific to a feature
  - Modular, composable pieces that make up screens
  - Feature-specific UI interactions

Example from Auth feature:
```
presentation/
├── providers/
│   ├── auth_state_provider.dart      # Manages authentication state
│   └── sign_in_provider.dart         # Handles sign-in process
├── screens/
│   └── sign_in_screen/              # Complete sign-in page
└── components/
    └── login_form_component.dart    # Reusable form widget
```

This organization ensures separation of concerns, testability, and maintainability across the application.

## 4. State Management
The application uses Riverpod for state management:

```dart
@Riverpod(keepAlive: true)
class SiteState extends _$SiteState {
  @override
  Option<Site> build() => const None();
  
  // ...methods
}

@riverpod
Future<List<Site>> listSiteState(Ref ref) async {
  // ...implementation
}
```

## 5. Key Features
### 5.1. Authentication

#### Structure overview
```
auth/
├── domain/             # Business objects and interfaces
│   ├── driver.dart     # Core driver entity
│   ├── sign_in_with_vehicle_info.dart
│   └── user.dart       # Generic user entity
├── infrastructure/     # Implementation details
│   ├── repos/
│   │   └── auth_repo.dart
│   ├── data_sources/
│   │   ├── auth_local_data_source.dart
│   │   └── auth_remote_data_source.dart
│   └── dtos/
│       ├── driver_dto.dart
│       └── user_dto.dart
└── presentation/      # User interface
    ├── providers/     # State management
    │   ├── auth_state_provider.dart
    │   ├── check_auth_provider.dart
    │   ├── sign_in_provider.dart
    │   └── sign_out_provider.dart
    ├── screens/       # UI screens
    │   ├── sign_in_screen/
    │   ├── profile_screen/
    │   └── policy_screen/
    └── components/    # Reusable UI components
        ├── login_form_component.dart
        ├── login_content_component.dart
        └── welcome_component.dart
```

The authentication feature follows Clean Architecture principles with clear separation of concerns:

**Domain Layer:**
- `driver.dart`: Defines the `Driver` entity class with properties like id, name, phoneNumber, and vehicleNumber.
- `user.dart`: Base generic user entity that can be extended.
- `sign_in_with_vehicle_info.dart`: Value object containing sign-in credentials (name, phoneNumber, vehicleNumber).

**Infrastructure Layer:**
- **Repositories**:
  - `auth_repo.dart`: Orchestrates data flow between sources, implements network checks, and handles persistence logic.
  
- **Data Sources**:
  - `auth_remote_data_source.dart`: Communicates with the backend API using Chopper client for driver authentication.
  - `auth_local_data_source.dart`: Manages local persistence of driver data using SharedPreferences.
  
- **DTOs**:
  - `driver_dto.dart`: Maps between API JSON data and domain Driver entities with `toDomain()` and `fromDomain()` methods.

**Presentation Layer:**
- **Providers**:
  - `auth_state_provider.dart`: Global singleton provider (keepAlive) that maintains current authentication state using Option<Driver>.
  - `check_auth_provider.dart`: Provides routing decisions based on auth state.
  - `sign_in_provider.dart`: Manages sign-in process state (loading, success, error).
  - `sign_out_provider.dart`: Handles sign-out operations.
  
- **Screens and Components**:
  - UI representation of auth flows with form validation and user feedback.

#### Authentication Flow

```
App Launch → AuthStateProvider.build() → Checks for cached Driver data → 
If found → Automatic login → Main Screen
If not found → Policy/SignIn Screen
```

#### Authentication Data Flow
```
UI Input → Domain Model → Repository → Remote Data Source → API
                                     → Local Data Source → SharedPreferences
      ↑                    ↑                                      ↓
      └────────────────────┴──────────────────────────────────────┘
```

### 5.2. Core
```
lib/core/
├── core_features/             # Core app-wide features
│   ├── locale/                # Localization system
│   ├── theme/                 # Theming system
│   ├── local_storage/         # Storage management
│   └── pip_service.dart       # Picture-in-picture service
│
├── infrastructure/            # Low-level services and implementation
│   ├── error/                 # Error handling and exceptions
│   │   └── app_exception.dart
│   ├── local/                 # Local storage implementations
│   │   └── shared_preferences_facade.dart
│   ├── network/               # Network-related code
│   │   ├── apis/              # API service definitions
│   │   └── data_connection_checker.dart
│   └── services/              # Core services
│       ├── cache_service.dart # Caching service
│       ├── logger.dart        # Logging service
│       └── main_initializer.dart  # App initialization
│
└── presentation/             # UI layer components
    ├── components/           # Reusable UI components
    ├── extensions/           # Extension methods
    ├── helpers/              # Helper functions
    ├── hooks/                # Flutter Hooks
    ├── providers/            # Riverpod providers
    ├── routing/              # Navigation system
    ├── screens/              # Base screens
    ├── styles/               # Design system
    │   ├── styles.dart
    │   ├── sizes.dart
    │   └── text_styles.dart
    ├── utils/                # Utilities
    │   ├── fp_framework.dart # Functional programming utilities
    │   └── riverpod_framework.dart
    └── widgets/              # Reusable widgets
        ├── platform_widgets/ # Platform-specific implementations
        ├── responsive_widgets/ # Responsive design widgets
        └── ...
```

### 5.3. Home Feature
#### Overview
The Home feature is the central operational component of the DumpShine app, handling trip management, location tracking, and data synchronization between construction sites, loading areas, and unloading areas. This feature enables drivers to:

- View and select construction sites and projects
- Choose loading and unloading areas for materials
- Track ongoing trips with real-time GPS data
- View trip histories and operation status


```
features/home/
├── domain/
│   ├── site.dart
│   ├── trip.dart
│   └── history_trip.dart
├── infrastructure/
│   ├── data_sources/
│   │   ├── areas_remote_data_source.dart
│   │   ├── gps_local_data_source.dart
│   │   ├── projects_remote_data_source.dart
│   │   ├── sites_remote_data_source.dart
│   │   └── trips_remote_date_source.dart
│   ├── dtos/
│   │   ├── area_dto.dart
│   │   ├── project_dto.dart
│   │   └── site_dto.dart
│   └── repos/
│       └── orders_repo.dart
└── presentation/
    └── providers/
        └── site_provider/
            └── site_provider.dart
```

1. Domain Layer

The domain layer defines the core business entities and logic

Key `domain` entities:

- **Site**: Represents a headquarters location (top-level organization)
- **Project**: Construction project belonging to a site
- **Area**: Geographical zone for loading or unloading operations
- **Trip**: Core entity that tracks a complete transport operation
- **HistoryTrip**: Simplified representation of past trips for history display

2. Infrastructure Layer

Manages data acquisition and persistence

Key features:

- **Offline-first architecture**: GPS data is stored locally before syncing
- **Cached trips**: Latest trip information is cached for offline startup
- **Background sync**: Coordinates are sent to server periodically

3. Presentation Layer

User interface and state management:

The state management uses Riverpod with:

- **Option-based nullable state**: `Option<Site>` for optional entities
- **Async state management**: Loading, error, and data states
- **Provider organization**: Area, Project, Site, and Trip providers with notifier classes

#### Workflows

1. Trip Creation Flow
```
Site Selection → Project Selection → Loading Area Selection → Unloading Area Selection 
→ Material Selection → Trip Confirmation → Start Location Tracking
```

2. Background Location Process
```
Background Service Initialization → Periodic GPS Collection → Local Storage 
→ Server Synchronization → Distance & ETA Calculation → UI Updates
```

3. Home Screen Components
- **Action Panels**: Cards for selecting sites/projects and viewing history
- **Status Message Section**: Real-time trip status information
- **Distance UI**: Shows distance to destinations and total trip distance
- **Material Selection**: Cargo type selection (dirt, concrete, etc.)

### 5.4. Map Feature (Unused)

The Map feature in the DumpShine app appears to be in a transitional state - most of its functionality is commented out or disabled, indicating it was either:
1. A feature under development that was paused
2. A legacy component being replaced by a different approach
3. A placeholder for future implementation

#### Structure Analysis

The code structure reveals a comprehensive mapping solution that was designed but not fully implemented:

```
features/map/
├── domain/                           # Business entities
│   ├── place_autocomplete.dart       # Place search suggestion model
│   ├── place_details.dart            # (Disabled) Detailed location information
│   └── place_directions.dart         # (Disabled) Routing information
├── infrastructure/                   # Technical implementation
│   ├── data_sources/
│   │   └── map_remote_data_source.dart  # (Mostly disabled) Google Maps API client
│   ├── dtos/                         # Data transfer objects
│   │   ├── place_autocomplete_dto.dart  # Conversion between API and domain models
│   │   ├── place_details_dto.dart    # (Disabled) Location detail converters
│   │   └── place_directions_dto.dart # (Disabled) Route data converters
│   └── repos/
│       ├── gps_repo.dart             # Minimal implementation 
│       └── map_repo.dart             # (Disabled) Map service coordinator
└── presentation/                     # UI Components
    ├── providers/                    # State management
    │   ├── map_controller_provider.dart       # (Disabled) Map control logic
    │   ├── map_confirm_order_provider.dart    # Delivery confirmation
    │   ├── map_overlays_providers/            # (Disabled) Map visual elements
    │   ├── my_location_providers/             # (Disabled) User location tracking
    │   └── session_token_provider.dart        # API session management
    ├── screens/
    │   └── map_screen/                        # Screen implementations
    │       ├── map_screen.dart                # Main entry point
    │       └── map_screen_compact.dart        # Lightweight implementation
    ├── utils/                                 # Helper utilities
    │   ├── constants.dart                     # (Disabled) Map configuration 
    │   ├── move_status.dart                   # Movement state tracking
    │   └── moving_state.dart                  # Position tracking model
    └── widgets/                               # UI components
        └── map_search_menu_item.dart          # Search result item
```

#### Current Functionality

While most map features are disabled, the active components serve a minimal but important role:

1. **Trip Creation**: `map_screen_compact.dart` handles creating new trips based on selected sites, projects, and areas
2. **Movement Tracking**: `move_status.dart` and `moving_state.dart` provide basic state tracking for driver movements
3. **Picture-in-Picture Support**: The screen enables PiP mode for background location tracking
4. **Notifications**: Sends system notifications when movement status changes

#### Technical Notes

1. **Disabled Google Maps Integration**: The code shows remnants of Google Maps integration through:
   - DTO conversions for map data
   - Controller providers for map manipulation
   - Polylines, markers, and circles overlays

2. **Current Implementation**: The active code takes a simpler approach:
   - Creates trips using the Home feature's providers
   - Enables background tracking and notifications
   - Provides immediate feedback and returns to the main screen

3. **Interface Structure**: The UI was likely designed as a full map experience with:
   - Search functionality (`MapSearchMenuItem`)
   - Visual route display (commented polyline providers)
   - Current location indicators (commented marker providers)

This suggests the app may be using a different mapping solution or simplifying its approach to focus on the core trip tracking functionality rather than visual map representation.

### 5.5. Profile Feature

#### Overview
The Profile feature provides user profile management capabilities, allowing drivers to view and update their personal information. This feature is currently partially implemented, with several components commented out in preparation for future development.

#### Structure Analysis

```
features/profile/
├── domain/                          # Business entities
│   └── profile_details.dart         # Profile entity with validation logic
├── infrastructure/                  # Implementation details
│   ├── data_sources/
│   │   └── profile_remote_data_source.dart  # API communications for profile data
│   ├── dtos/
│   │   └── profile_details_dto.dart  # Transfer objects for profile data
│   └── repos/
│       └── profile_repo.dart         # Repository for coordinating profile operations
└── presentation/                    # User interface
    ├── components/                  # Reusable UI components
    │   ├── profile_form_component.dart       # (Disabled) Profile editing form
    │   ├── profile_header_component.dart     # Header with user info
    │   ├── user_details_component.dart       # Displays driver name and details
    │   └── user_image_component.dart         # (Disabled) Profile image with edit capability
    ├── providers/                   # State management
    │   ├── pick_profile_image_provider.dart  # (Disabled) Image picking logic
    │   ├── profile_details_provider.dart     # (Disabled) Profile data management
    │   └── update_profile_image_provider.dart # (Disabled) Image update logic  
    ├── screens/                     # UI screens
    │   └── profile_screen/
    │       ├── profile_screen.dart            # (Disabled) Responsive layout wrapper
    │       ├── profile_screen_compact.dart    # Mobile layout (simplified)
    │       └── profile_screen_medium.dart     # Tablet layout (simplified)
    └── widgets/                     # Reusable UI widgets
        └── titled_text_field_item.dart        # Field with title for forms
```

#### Domain Layer
The domain layer defines the core profile entities and validation rules:

- **ProfileDetails**: Immutable data class representing user profile information
  - Contains essential fields: name, phone
  - Provides validation methods for form fields
  - Uses `freezed` for immutable data modeling

#### Infrastructure Layer
Handles external data interactions:

- **ProfileRemoteDataSource**: API communication for profile data (currently minimally implemented)
- **ProfileDetailsDto**: Maps between domain entities and external data formats
- **ProfileRepo**: Coordinates data access between sources and implements business operations

#### Presentation Layer
User interface components and state management:

1. **Providers**:
   - Follow Riverpod patterns with AsyncValue for handling loading/error states
   - Option type to represent nullable states

2. **Components and Screens**:
   - Responsive design with different layouts for different screen sizes
   - Clear separation between screens, components, and widgets
   - Currently displays minimal user information from AuthState

#### Workflow Design
The profile feature appears designed to support the following workflows (partially implemented):

1. **View Profile**: Display current user information from authentication state
2. **Edit Profile**: Form-based editing of name and contact information

### 5.6. Utilities

The `utils` directory contains cross-cutting utility functions and helper classes that are used throughout the application. These utilities provide common functionality without being tied to specific features.

```
utils/
├── constant.dart            # Application-wide constants
├── distance_compute.dart    # Geographic distance calculation utilities
├── helper.dart              # String manipulation helpers (disabled)
├── logger.dart              # Structured logging system
├── mertial-v.dart           # Material type enumerations with display names
├── setup_job_step.dart      # Trip setup workflow steps
└── style.dart               # Text styling helpers
```

#### Logging System
The application uses a structured logging system built on top of the `logger` package:

- **LoggerPretty**: Customized logger implementation with:
  - Colored console output for better readability
  - Different log levels (debug, info, warning, error)
  - Pretty-printing for JSON payloads
  - Method trace capture for debugging
  
- **LogColor**: Utility class for terminal color formatting:
  - Color constants for various logging levels
  - Wrapper methods for colorized output
  - Semantic helper methods (error, success, warning, info)

#### Distance Calculation
Geographic distance utilities for location tracking:

- **Haversine Formula**: Implementation of the haversine formula for calculating the great-circle distance between two points on Earth
  - Takes latitude and longitude pairs as input
  - Returns distance in meters
  - Used for calculating distances to loading/unloading zones

#### UI Utilities
Several utilities assist with consistent UI presentation:

- **Text Styling**: The `gpsTextStyle` function provides a standardized way to create TextStyle objects with consistent:
  - Font weights
  - Font sizes
  - Line heights
  - Colors

- **Constants**: Shared UI constants like `defaultPadding` ensure consistent spacing throughout the app

#### Workflow Helpers
Enums and utilities to manage application flows:

- **SetupInfoStep**: Enum defining the steps in trip setup flow:
  - Site selection
  - Project selection
  - Loading area selection
  - Unloading area selection

- **MaterialV**: Enum for different material types being transported with localized display names:
  - Soil ("토사")
  - Cancer/Rock ("암") 
  - Waste ("폐기물")

This utilities layer demonstrates the DRY (Don't Repeat Yourself) principle by centralizing common functionality that would otherwise be duplicated across features.

## 6. Data Flow

The application implements a robust bidirectional data flow architecture that handles both online and offline scenarios effectively. The general flow pattern follows:

```
User Interaction → Presentation Layer → Provider State Management → Repository Layer → Data Sources → External/Local Storage
```

### 6.1. Core Data Flow Patterns

#### Repository Pattern Implementation

The repository layer acts as the central coordinator for data operations:

```dart
class AuthRepo {
  AuthRepo({
    required this.networkInfo,
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  // Repository coordinates between data sources based on network status
  Future<Driver?> signInWithVehicleInfo(SignInWithVehicleInfo params) async {
    final data = await remoteDataSource.signInWithVehicleInfo(params);
    if (data != null) {
      await localDataSource.cacheDriverData(data.toDomain());
      return data.toDomain();
    }
    return null;
  }
}
```

#### DTO Conversion Flow

All data undergoes transformation between external and domain representations:

```
API JSON Data → DTO Objects → Domain Entities → UI Display
```

Example from SiteDto:
```dart
// From DTO to Domain conversion
Site toDomain() {
  return Site(
    id: id,
    name: name,
    phone: phone,
    address: address,
  );
}
```

### 6.2. Key Data Flows

#### Authentication Data Flow

1. **Sign-in Input → Validation → API → Local Storage**:
   ```
   UI Input → SignInProvider → AuthRepo → AuthRemoteDataSource → API
                                       → AuthLocalDataSource → SharedPreferences 
   ```

   - User credentials (name, phone, vehicle number) are captured in the UI
   - `SignInProvider` validates and processes this input
   - `AuthRepo` coordinates the authentication attempt
   - `AuthRemoteDataSource` communicates with the server using Chopper client
   - On success, `AuthLocalDataSource` caches the driver data in SharedPreferences
   - `AuthStateProvider` updates global authentication state

2. **App Startup → Auth Check → Automated Login**:
   ```
   App Launch → AuthStateProvider → AuthLocalDataSource → Cached Data Check → Main/Login Screen
   ```

#### GPS and Location Tracking Flow

1. **GPS Collection → Local Storage → Server Synchronization**:
   ```
   Location Updates → GpsLocalDataSource → SQLite Database
                    → Batch Collection → GpsRemoteDataSource → Server
   ```

   Implementation in `GpsRemoteDataSource`:
   ```dart
   Future<bool> syncUnsentGpsData(int tripId, {bool isFull = false}) async {
     // Get unsynced data from local database
     final unsyncedData = await localDataSource.getUnsyncedGpsData(tripId);
     // Try to send to server
     final success = await _uploadGps(tripId, unsyncedData, isFull: isFull);
     if (success) {
       // Mark records as synced
       await localDataSource.markDataAsSynced(
         unsyncedData.map((data) => data.timeStamp).toList(),
       );
     }
     return success;
   }
   ```

2. **Background-to-Foreground Data Flow**:
   - Background location service collects data even when app is minimized
   - Data points are accumulated in local storage
   - Periodic sync operations send data to server in batches
   - UI is updated when app returns to foreground

#### Trip Management Flow

1. **Trip Creation Flow**:
   ```
   UI Selections → State Providers → TripsRemoteDataSource → API
                                  → TripsLocalDataSource → SharedPreferences
   ```

   As seen in `TripsRemoteDataSource`:
   ```dart
   Future<Trip?> createNewTrip({/*...*/}) async {
     // API call to create trip
     final response = (await tripService.createTrip(/*...*/)).body;
     final trip = response?.data;
     // Cache locally for offline access
     if (trip != null) {
       final latestTrip = convertTripToLatestTrip(trip);
       await _saveLatestTripLocally(driver.id, latestTrip);
       logger.log('Trip created and cached locally', color: LogColor.green);
     }
     return trip;
   }
   ```

2. **Ongoing Trip Synchronization**:
   - Device continuously sends location updates
   - Periodic server polling checks for remote trip status changes
   - Force-ended trips trigger local cleanup operations

### 6.3. Offline-First Architecture

The application implements an offline-first approach with:

1. **Local Caching Strategy**:
   - All critical data is cached locally (trips, driver info)
   - Data entry can continue without immediate server connection

2. **Background Synchronization**:
   - Network state is monitored by `ConnectionStreamService`
   - When connectivity is restored, pending data is synchronized
   - Batch operations optimize network usage

3. **Conflict Resolution**:
   - Server-side timestamps determine data precedence
   - Force-ended trips from server override local state

4. **Manual Intervention**:
   - UI indicators show sync status with `UnsyncedDataBanner`
   - Manual sync triggers are provided for user control

This multi-layered data flow ensures robust operation in variable network conditions while maintaining data integrity between device and server.

## 7. Dependencies & Services
- State Management: Riverpod
- API Client: Chopper
- Local Storage: SharedPreferences, SQLite
- Navigation: Go Router
- Location Services: Geolocator
- Maps: TMap SDK (iOS)
- Firebase: Analytics, Crashlytics