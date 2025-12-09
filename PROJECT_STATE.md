# PlayWithMe - Project State & Architecture

This document provides a comprehensive overview of the current state of the PlayWithMe project, including its architecture, key components, and implemented features.

## 🏗️ Architecture

The project follows a **Clean Architecture** approach using the **BLoC (Business Logic Component)** pattern with a **Repository** layer for data access.

### Layered Structure

1.  **Presentation Layer (`lib/features/*/presentation/`)**:
    *   **Pages**: Screens (e.g., `ProfilePage`, `GameDetailsPage`). Responsible for building the UI structure.
    *   **Widgets**: Reusable UI components (e.g., `StatCard`, `GameHistoryCard`).
    *   **BLoC**: State management logic. Handles events from UI and emits states (e.g., `PlayerStatsBloc`, `GameHistoryBloc`).

2.  **Domain Layer (`lib/core/domain/` & `lib/features/*/domain/`)**:
    *   **Entities**: Pure Dart objects representing business concepts (e.g., `UserEntity`).
    *   **Repositories (Interfaces)**: Abstract definitions of data operations (e.g., `UserRepository`, `GameRepository`).
    *   **Services (Interfaces)**: Domain-specific services (e.g., `StatisticsService` - planned).

3.  **Data Layer (`lib/core/data/` & `lib/features/*/data/`)**:
    *   **Models**: Data transfer objects (DTOs) with JSON serialization (using `freezed`), often extending Entities or mapping to them (e.g., `UserModel`, `GameModel`).
    *   **Repositories (Implementations)**: Concrete implementations interacting with data sources (e.g., `FirestoreUserRepository`, `FirestoreGameRepository`).
    *   **Data Sources**: Firebase (Firestore, Auth, Functions, Storage).

### Dependency Injection

*   **`get_it`**: Used for service locator (`sl`).
*   **`lib/core/services/service_locator.dart`**: Registers all Repositories, BLoCs, and Services as singletons or factories.

## 🧩 Key Features & Modules

### 1. Authentication (`lib/features/auth`)
*   **State Management**: `AuthenticationBloc` (global), `LoginBloc`, `RegistrationBloc`.
*   **Functionality**: Email/Password login, Registration, Password Reset, Anonymous Login.
*   **Data**: `FirebaseAuthRepository` maps Firebase Users to `UserEntity`.

### 2. User Profile (`lib/features/profile`)
*   **Viewing**: `ProfilePage` uses `AuthenticationBloc` for basic info and `PlayerStatsBloc` for statistics.
*   **Stats**: Real-time ELO rating, Win Rate, Streak, and ELO History Chart (`fl_chart`).
*   **Editing**: `ProfileEditPage` allows updating details and avatar.
*   **Settings**: Locale/Language preferences.

### 3. Friends & Community (`lib/features/friends`)
*   **Social Graph**: `MyCommunityPage` lists friends and requests.
*   **Logic**: `FriendBloc` handles adding, removing, and accepting friends.
*   **Backend**: Cloud Functions manage the bidirectional friendship logic.

### 4. Groups (`lib/features/groups`)
*   **Management**: Create, Join, Leave, Edit groups.
*   **Discovery**: `GroupListPage` shows user's groups.
*   **Logic**: `GroupBloc`, `GroupMemberBloc`.

### 5. Games (`lib/features/games`)
*   **Lifecycle**: Create -> Schedule -> RSVP -> Play -> Record Results -> Complete.
*   **Listing**: `GamesListPage` separates Upcoming and Past games.
*   **Details**: `GameDetailsPage` manages RSVP status (`GameDetailsBloc`) and real-time updates.
*   **History**: `GameHistoryScreen` shows completed games with results (`GameHistoryBloc`).
*   **Scoring**: `ScoreEntryPage` and `RecordResultsPage` for game conclusion.

### 6. Notifications (`lib/features/notifications`)
*   **Settings**: `NotificationSettingsPage` controls push/email preferences.
*   **Service**: `NotificationService` handles FCM token management.

## ☁️ Backend (Serverless)

The backend logic is split between TypeScript (Node.js) and Python Cloud Functions.

### TypeScript Functions (`functions/src/`)
*   **Social Graph**: `inviteToGroup`, `acceptInvitation`, `declineInvitation`, `friendships`.
*   **Users**: `searchUsers`, `getUsersByIds`.
*   **Games**: `getGamesForGroup`, `getCompletedGames`.
*   **Notifications**: Triggers for game creation/updates.

### Python Functions (`functions/python/`)
*   **ELO Calculation**: `rating/handler.py` implements Weak-Link ELO algorithm.
*   **Stats**: Automatically updates player stats (streak, win/loss) and `ratingHistory` on game completion.

## 🧪 Testing Strategy

The project mandates **100% test pass rate**.

1.  **Unit Tests (`test/unit/`)**:
    *   Focus: BLoCs, Repositories (logic), Services.
    *   Tools: `bloc_test`, `mocktail`.
    *   **Rule**: Never test Firestore queries here (mock the repository interface).

2.  **Widget Tests (`test/widget/`)**:
    *   Focus: UI rendering, Widget interactions.
    *   Tools: `flutter_test`, fake repositories/BLoCs.

3.  **Integration Tests (`test/integration/`)**:
    *   Focus: End-to-end flows, Real Firestore queries.
    *   Tools: `integration_test`, Firebase Emulator.

## 📂 Key Directories

*   `lib/core`: Shared code (Config, Models, Repositories, Widgets).
*   `lib/features`: Feature-specific code (Auth, Games, Profile, etc.).
*   `functions`: Cloud Functions code.
*   `test`: Test suites.

## 🚀 Current Status

*   **Foundation**: Solid (Arch, CI/CD, Testing).
*   **Auth**: Complete.
*   **Social**: Functional (Friends/Groups).
*   **Games**: Core flow complete (Create to Result).
*   **Stats**: ELO Calculation (Backend) and Display (Frontend) implemented.
*   **History**: Game History view implemented.

**Recent Work:**
*   Implemented `PlayerStatsBloc` and `ProfilePage` stats visualization.
*   Implemented `GameHistoryScreen`.
*   Added `getCompletedGames` Cloud Function.
