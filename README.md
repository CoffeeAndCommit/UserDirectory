# User Directory Application

An advanced Flutter application that demonstrates proficiency in API integration, explicitly modeled state management, clean layered architecture, and scalable UI development.

## 🚀 Features

* **User Listing**: Fetches and displays a list of users from the JSONPlaceholder API.
* **State Management**: Explicitly handles and transitions between `Loading`, `Success`, `Error`, and `Empty` states without mixing logic into the UI.
* **Search & Filter**: Includes a debounced (300ms delay) search bar for responsive, case-insensitive filtering by name.
* **Client-Side Pagination**: Implements paginated scrolling, loading users in batches of 6, complete with a "Load More" trailing indicator.
* **Offline Handling & Caching (Bonus)**: Uses `SharedPreferences` to cache API responses locally. If a network request fails, the app seamlessly falls back to the local cache.
* **Robust Error Handling**: Network failures gracefully transition to an error state with a meaningful message and a manual retry mechanism.
* **User Profile Detailing**: tapping a user navigates to a detailed view of their full name, email, phone, website, company info, and formatted location.

## 🏛️ Architecture & State Management

The project strictly follows a **Clean Architecture with MVVM**, separating concerns into distinct layers:

1. **Domain Layer (`lib/domain`)**: Contains strictly business models (`User`, `Address`, `Company`) and abstraction interfaces (`UserRepository`). Completely decoupled from Flutter UI and third-party packages.
2. **Data Layer (`lib/data`)**: Implements the repositories and coordinates between the `UserRemoteDataSource` (HTTP API) and `UserLocalDataSource` (Offline Cache).
3. **Presentation Layer (`lib/presentation` & MVVM)**: Driven by the `provider` package and `ChangeNotifier`. The `UserViewModel` acts as the single source of truth for the UI, emitting concrete `UIState` wrappers to avoid implicit null checks.

### Why Provider?
`Provider` was chosen for its simplicity, stability, and excellent synergy with the standard `ChangeNotifier`. By pairing Provider with an explicitly defined `UIState` hierarchy (rather than just simple booleans like `isLoading`), the architecture perfectly mimics complex Bloc/Riverpod transitions while keeping boilerplate to an absolute minimum.

## 📂 Folder Structure

```text
lib/
├── core/
│   ├── error/
│   │   └── exceptions.dart     # Custom exception classes
│   └── state/
│       └── ui_state.dart       # Sealed-class like UI states (Loading, Success, Etc)
├── data/
│   ├── repositories/
│   │   └── user_repository_impl.dart  # Coordinates remote/local data
│   └── sources/
│       ├── user_local_data_source.dart
│       └── user_remote_data_source.dart
├── domain/
│   ├── models/
│   │   └── user_model.dart     # Entities
│   └── repositories/
│       └── user_repository.dart # Interface
├── presentation/
│   ├── viewmodels/
│   │   └── user_viewmodel.dart # ChangeNotifier ViewModel
│   ├── views/
│   │   ├── user_detail_screen.dart
│   │   └── user_list_screen.dart
│   └── widgets/
│       └── user_card.dart      # Reusable UI component
└── main.dart                   # Dependency Injection Setup
```

## 🛠️ Setup Instructions

1. Ensure you have the Flutter SDK installed on your machine.
2. Clone this repository and navigate to the root directory `userdirectory`.
3. Fetch the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```
