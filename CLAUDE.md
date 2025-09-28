Of course. Here is a comprehensive `CLAUDE.md` file tailored for Claude, based on our entire conversation. This file acts as a project brief and set of coding instructions, providing all the context and standards needed to start development.

You can create a file named `CLAUDE.md` in the root of your repository and paste the following content into it.

---

# Claude Project Brief: PlayWithMe Beach Volleyball App

Welcome, Claude. You are the AI engineer for the "PlayWithMe" project. This document outlines the project's vision, architecture, technology stack, and the standards you must follow. Your goal is to implement the features defined in the GitHub Issues, adhering strictly to the guidelines below.

## 📚 **Documentation**

Comprehensive documentation is organized by Epic and Story in the [`docs/`](./docs/) directory. Each completed story includes detailed implementation guides, setup instructions, and completion summaries.

**Current Documentation:**
- **[Epic 0: Project Setup](./docs/epic-0/)** - Infrastructure and development environment
  - **[Story 0.2.1: Firebase Multi-Environment Setup](./docs/epic-0/story-0.2.1/)** - Complete Firebase configuration guide

---
## 1. Project Vision 🏐

**PlayWithMe** is a Flutter mobile app designed to help people organize beach volleyball games.

### Core Functionality:
* Users can create and join private groups of friends.
* Users can create games, notifying group members of the time and place.
* Members can RSVP to games.
* A visual, interactive "court" view shows who has joined and claimed a spot.
* The app will include a map to find and add volleyball courts.
* A scoring and leaderboard system will add a competitive element.

---
## 2. Technology Stack & Architecture 🏗️

### **Frontend (Mobile App):**
* **Framework:** **Flutter**
* **Architecture:** **BLoC (Business Logic Component) with a Repository Pattern**. This is a critical requirement. You must maintain a strict separation of concerns:
    * **UI Layer (Presentation):** "Dumb" widgets that only display state and forward user events to the BLoC.
    * **Business Logic Layer (BLoC):** Manages state. It receives events, interacts with repositories, and emits new states for the UI to consume.
    * **Data Layer (Repository):** Abstracts the data source. The BLoC communicates with the repository, which in turn communicates with Firebase.
* **State Management:** `flutter_bloc`
* **Models:** Use the `freezed` package for creating immutable data models.
* **Service Location:** Use `get_it` for dependency injection.

### **Backend (BaaS):**
* **Provider:** **Firebase**
* **Database:** **Cloud Firestore** for real-time data synchronization.
* **Authentication:** **Firebase Authentication** for user management.
* **Serverless Logic:** **Firebase Cloud Functions written in Python**. All business logic that needs to be secure or centralized (e.g., sending notifications, calculating leaderboard stats) **must** be implemented here.

### **Development Environments:**
The project uses three distinct Firebase environments for safety and testing:
1.  `playwithme-dev` (for local development and integration tests)
2.  `playwithme-stg` (for staging and internal testing)
3.  `playwithme-prod` (for the live application)

---
## 3. Coding Standards & Best Practices ✍️

Your primary directive is to produce **clean, high-quality, and maintainable code**.

### **General:**
* **Single Responsibility:** Every file, class, and function should have a single, well-defined purpose.
* **DRY (Don't Repeat Yourself):** Abstract and reuse code where appropriate. Avoid duplicated logic.
* **Clarity over Cleverness:** Write code that is easy for another engineer (or AI) to understand. Add comments only for complex or non-obvious logic.
* **Error Handling:** Gracefully handle potential errors, especially from network and Firebase calls. The BLoC should emit specific `Error` states that the UI can respond to.

### **Testing (Non-Negotiable):**
Every feature must be accompanied by comprehensive tests. Follow the testing pyramid.
* **Unit Tests:** All BLoCs and Repository logic **must** be unit tested. Mock all external dependencies.
* **Widget Tests:** All UI screens and complex widgets **must** be widget tested. Provide mock BLoCs to test how the UI reacts to different states.
* **Integration Tests:** Write end-to-end tests for critical user flows (e.g., user login, creating a group, RSVPing to a game). These tests will run against the `dev` Firebase environment.
* **Backend Tests:** Python Cloud Functions must be unit tested using the Firebase Local Emulator Suite.

### **Git Workflow:**
* You will work on features defined in GitHub Issues.
* Create a new branch for each issue you work on. Name branches clearly (e.g., `feature/story-1.1-user-model`).
* Commit your work with clear, descriptive messages following the conventional commit format (e.g., `feat: implement user model and repository`).
* When a story is complete, create a Pull Request for review.

---
## 4. Instructions for Getting Started 🚀

Your first task is to begin implementing the stories from **Epic 0** and **Epic 1**. Always refer to the GitHub Issues for the specific requirements of each story.

### **Your First Task: Story 0.1 - Initialize Flutter Project**

1.  **Analyze the Goal:** The goal is to create the initial Flutter project with the correct architecture and dependencies.
2.  **Execute Commands:**
    * Run `flutter create play_with_me` to create the project.
    * Use `git init` and `git remote add origin` to connect to the `Babas10/playWithMe` repository.
3.  **Set Up Directory Structure:**
    * Create the following directories inside `lib/`:
        * `app/` (for app-level widgets and configuration)
        * `core/` (for shared services, models, repositories)
        * `features/` (for feature-specific code, e.g., `features/auth/`)
4.  **Add Dependencies:**
    * Modify the `pubspec.yaml` file to include the required packages: `flutter_bloc`, `equatable`, `get_it`, `freezed`, `firebase_core`, `cloud_firestore`, `firebase_auth`.
    * Also, add `build_runner` and `freezed_annotation` to `dev_dependencies`.
5.  **Commit Your Work:**
    * Stage the new files.
    * Commit with the message: `feat(setup): initialize flutter project with bloc architecture`.

Proceed with the next stories in the backlog in order. Always read the issue description carefully to understand the implementation details and testing requirements. Let's build a great app.