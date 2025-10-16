# Story 1.4.5: Account Settings & Preferences

## 📋 Overview

This story implements a comprehensive account settings and preferences system for the PlayWithMe app. Due to the breadth of functionality and different technical concerns, this story has been decomposed into **5 focused substories** to ensure maintainability, clear testing boundaries, and manageable implementation scope.

**Parent Story**: #[Story 1.4.5]
**Epic**: User Profile Management (Epic 1.4)
**Status**: 🔄 In Progress (Decomposed into substories)

---

## 🎯 Rationale for Decomposition

The original Story 1.4.5 combined five distinct areas of concern:

1. **User Preferences** (notifications, theme, language)
2. **Privacy & Visibility** (profile visibility, contact preferences)
3. **Security** (password change, sessions, 2FA)
4. **Data Management** (export, delete, cache)
5. **UI/UX** (settings shell, search, navigation)

Each area touches different parts of the stack:
- Firebase (security & user data)
- SharedPreferences (local storage)
- Cloud sync logic (Firestore)
- System integrations (notifications, themes)
- Platform APIs (mobile vs web)

Combining all of these into a single story would:
- ❌ Blow up implementation scope
- ❌ Create overly complex test coverage requirements
- ❌ Make code review extremely difficult
- ❌ Introduce too many dependencies at once
- ❌ Risk integration issues between unrelated features

---

## 🧩 Substories

### Implementation Order & Dependencies

| Order | Story | Focus Area | Depends On | Complexity |
|-------|-------|------------|------------|------------|
| 1 | **[1.4.5.1](./story-1.4.5.1/README.md)** | Account Preferences | — | 🟢 Low |
| 2 | **[1.4.5.2](./story-1.4.5.2/README.md)** | Privacy & Visibility | User Repository | 🟡 Medium |
| 3 | **[1.4.5.3](./story-1.4.5.3/README.md)** | Security Settings | Firebase Auth | 🔴 High |
| 4 | **[1.4.5.4](./story-1.4.5.4/README.md)** | Data Management | Cloud Functions | 🟡 Medium |
| 5 | **[1.4.5.5](./story-1.4.5.5/README.md)** | Settings Shell | All above | 🟢 Low |

---

## 📖 Substory Details

### 🟢 Story 1.4.5.1 — Account Preferences

**Focus**: User personalization (theme, language, notifications)

**Key Features**:
- Light / Dark / System theme toggle
- Language, region, and time zone selection
- Notification type preferences (email, push, in-app)
- Local persistence with optional cloud sync

**Tech Stack**: AccountPreferencesBloc, SharedPreferences, ThemeMode

[➡️ Full Details](./story-1.4.5.1/README.md)

---

### 🟡 Story 1.4.5.2 — Privacy & Visibility Settings

**Focus**: Profile visibility and contact controls

**Key Features**:
- Profile visibility levels (Public / Friends / Private)
- Contact preference toggles
- Data-sharing opt-in/out for analytics
- Cloud sync with UserRepository

**Tech Stack**: PrivacySettingsBloc, UserRepository, Firestore

[➡️ Full Details](./story-1.4.5.2/README.md)

---

### 🔴 Story 1.4.5.3 — Security Settings

**Focus**: Secure account management

**Key Features**:
- Change password with re-authentication
- Active sessions management (view/sign out)
- Account deactivation and deletion
- Security activity log
- 2FA toggle (stub for future)

**Tech Stack**: SecuritySettingsBloc, Firebase Auth, Rate Limiting

[➡️ Full Details](./story-1.4.5.3/README.md)

---

### 🟡 Story 1.4.5.4 — Data Management

**Focus**: User data control and transparency

**Key Features**:
- Export user data (JSON/ZIP via cloud function)
- Display data usage and cache size
- Clear cache functionality
- Privacy Policy and Terms links
- Confirmation dialogs for destructive actions

**Tech Stack**: DataManagementBloc, Cloud Functions, path_provider

[➡️ Full Details](./story-1.4.5.4/README.md)

---

### 🟢 Story 1.4.5.5 — Settings Shell & Navigation

**Focus**: Unified settings UI and navigation

**Key Features**:
- Tabbed/sectioned UI for all settings modules
- In-page search functionality
- Deep linking to specific sections
- Persistent scroll position
- Accessibility compliance

**Tech Stack**: MultiBlocProvider, Material 3, Deep Links

[➡️ Full Details](./story-1.4.5.5/README.md)

---

## 🏗️ Architecture Overview

### BLoC Layer
```
AccountPreferencesBloc    // Theme, language, notifications
PrivacySettingsBloc       // Visibility, contact preferences
SecuritySettingsBloc      // Password, sessions, account
DataManagementBloc        // Export, cache, data control
```

### Repository Layer
```
AccountPreferencesRepository  // Local storage (SharedPreferences)
UserRepository               // Cloud sync (Firestore)
SecurityRepository           // Firebase Auth operations
DataManagementRepository     // Cloud Functions, local cache
```

### UI Layer
```
AccountSettingsScreen        // Main settings shell
├── PreferencesSection       // Story 1.4.5.1
├── PrivacySection          // Story 1.4.5.2
├── SecuritySection         // Story 1.4.5.3
└── DataManagementSection   // Story 1.4.5.4
```

---

## 🧪 Testing Strategy

Each substory maintains **90%+ test coverage** across:

### Unit Tests
- BLoC state transitions
- Repository operations
- Data persistence logic
- Error handling

### Widget Tests
- UI component rendering
- User interactions (toggles, buttons)
- Dialog confirmations
- Accessibility

### Integration Tests
- End-to-end flows
- Cloud sync verification
- Platform-specific behaviors

---

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web

Each substory includes platform-specific considerations where applicable.

---

## 🔒 Security Considerations

### Story 1.4.5.1 (Preferences)
- No sensitive data
- Local storage only

### Story 1.4.5.2 (Privacy)
- Profile visibility enforcement
- Server-side validation of privacy settings

### Story 1.4.5.3 (Security)
- **Critical**: Re-authentication required
- Rate limiting on sensitive operations
- Secure token handling
- Audit logging for security events

### Story 1.4.5.4 (Data Management)
- Export data must be encrypted
- Deletion is irreversible (requires confirmation)
- Compliance with GDPR/CCPA

---

## 🔄 Implementation Status

| Substory | Status | Completion |
|----------|--------|------------|
| 1.4.5.1 | ⏳ Not Started | 0% |
| 1.4.5.2 | ⏳ Not Started | 0% |
| 1.4.5.3 | ⏳ Not Started | 0% |
| 1.4.5.4 | ⏳ Not Started | 0% |
| 1.4.5.5 | ⏳ Not Started | 0% |

---

## 📚 Related Documentation

- [Epic 1.4: User Profile Management](../README.md)
- [Story 1.4.4: Email Verification](../story-1.4.4/README.md)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [CLAUDE.md Project Standards](../../CLAUDE.md)

---

## 🎯 Success Criteria

Story 1.4.5 is considered **complete** when:

✅ All 5 substories are implemented and tested
✅ Each substory maintains 90%+ test coverage
✅ Settings screen is accessible and intuitive
✅ All security requirements are met
✅ Cross-platform functionality verified
✅ Documentation is comprehensive
✅ Code follows CLAUDE.md standards

---

## 👥 Notes

- Start with Story 1.4.5.1 (simplest, no dependencies)
- Story 1.4.5.3 requires extra security review
- Story 1.4.5.5 should be implemented last (integrates all)
- Each substory can be reviewed and merged independently
