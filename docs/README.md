# PlayWithMe Documentation

This directory contains comprehensive documentation organized by Epic and Story.

## 📁 **Documentation Structure**

```
docs/
├── epic-0/           # Project Setup and Infrastructure
│   └── story-0.2.1/  # Create Real Firebase Projects
│       ├── README.md                    # Story completion summary
│       ├── FIREBASE_CONFIG_SETUP.md     # Firebase multi-environment setup
│       └── IOS_FLAVOR_SETUP.md          # iOS flavor configuration guide
└── epic-1/           # Core Features (future stories)
```

## 🎯 **Epic Overview**

### **Epic 0: Project Setup and Infrastructure**
Foundation setup for the PlayWithMe app including development environment, Firebase integration, and multi-environment configuration.

**Completed Stories:**
- ✅ **Story 0.2.1**: [Create Real Firebase Projects](./epic-0/story-0.2.1/) - Multi-environment Firebase setup with secure configuration management

**Upcoming Stories:**
- 📋 **Story 0.2.2**: Replace Placeholder Config Files (if needed)
- 📋 **Story 0.3.x**: Additional infrastructure setup

### **Epic 1: Core Features**
Implementation of core PlayWithMe functionality including user management, groups, and game organization.

**Upcoming Stories:**
- 📋 **Story 1.1**: User Authentication and Profile Management
- 📋 **Story 1.2**: Group Creation and Management
- 📋 **Story 1.3**: Game Creation and RSVP System

## 🛠 **Tools and Resources**

### **Development Tools**
- [`../tools/generate_firebase_config.dart`](../tools/generate_firebase_config.dart) - Dynamic Firebase configuration generation
- [`../tools/build_runner_config.dart`](../tools/build_runner_config.dart) - Pre-build configuration script

### **Project Configuration**
- [`../CLAUDE.md`](../CLAUDE.md) - Main project brief and coding standards
- [`../.gitignore`](../.gitignore) - Configured for secure Firebase setup

## 📋 **Quick Reference**

### **Development Commands**
```bash
# Firebase config generation
dart tools/generate_firebase_config.dart dev
dart tools/generate_firebase_config.dart stg
dart tools/generate_firebase_config.dart prod

# Flutter builds
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor stg -t lib/main_stg.dart
flutter run --flavor prod -t lib/main_prod.dart

# Android builds
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build apk --flavor stg -t lib/main_stg.dart
flutter build apk --flavor prod -t lib/main_prod.dart
```

### **Environment Verification**
```bash
# Check development environment
flutter doctor

# List available devices
flutter devices

# Verify Firebase setup
dart tools/generate_firebase_config.dart dev
```

## 🔗 **Navigation**

- **[Project Root](../README.md)** - Main project README
- **[Epic 0 Documentation](./epic-0/)** - Project setup and infrastructure
- **[Story 0.2.1](./epic-0/story-0.2.1/)** - Firebase multi-environment setup

---

**Note**: This documentation structure will grow as new epics and stories are completed. Each story folder contains comprehensive documentation for that specific implementation.