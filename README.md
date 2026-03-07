# Gatherli

A Flutter mobile app that helps people organize and join sports games with their group.

## 🏐 Features

- Create and join private groups of friends
- Create games and notify group members
- RSVP to games and view an interactive court visualization
- Discover nearby courts on a map
- Track scores and maintain leaderboards

## 🏗️ Architecture

**Framework:** Flutter | **State Management:** BLoC | **Backend:** Firebase

```
UI Layer (Widgets) → BLoC Layer → Repository Layer → Firebase
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Firebase CLI
- Dart SDK

### Running the App

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

### Running Tests

```bash
# Unit and widget tests
flutter test test/unit/ test/widget/

# All tests
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## 🔧 Environments

| Environment     | Purpose                            |
| --------------- | ---------------------------------- |
| `gatherli-dev`  | Local development & integration tests |
| `gatherli-prod` | Production (live users)            |

## 📚 Documentation

See [`docs/`](./docs/) for full documentation organized by Epic and Story.

- [Project Standards (CLAUDE.md)](./CLAUDE.md)
- [Security Guidelines](./docs/security/FIREBASE_CONFIG_SECURITY.md)
- [Testing Guide](./docs/testing/LOCAL_TESTING_GUIDE.md)

## 🔒 Security

Never commit Firebase config files, API keys, or environment secrets.
See [Pre-Commit Security Checklist](./docs/security/PRE_COMMIT_SECURITY_CHECKLIST.md).
