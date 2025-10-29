# PlayWithMe Cloud Functions

This directory contains Firebase Cloud Functions for the PlayWithMe app.

## Functions

### searchUserByEmail

Secure Cloud Function for searching users by email address.

**Purpose:** Allows authenticated users to search for other users without exposing the `/users` collection to direct client queries.

**Parameters:**
- `email` (string): Email address to search for

**Returns:**
```typescript
{
  found: boolean;
  user?: {
    uid: string;
    displayName: string | null;
    email: string;
    photoUrl?: string | null;
  };
}
```

**Security:**
- Requires authentication
- Validates email format
- Returns only non-sensitive user data
- Respects Firestore security rules

## Development

### Setup

```bash
cd functions
npm install
```

### Build

```bash
npm run build
```

### Local Testing with Emulator

```bash
# From project root
firebase emulators:start --only functions,auth,firestore

# In another terminal, run the Flutter app
flutter run --flavor dev -t lib/main_dev.dart
```

### Deploy

```bash
# Deploy all functions
npm run deploy

# Deploy specific function
firebase deploy --only functions:searchUserByEmail
```

### Testing

```bash
npm test
```

## File Structure

```
functions/
├── src/
│   ├── index.ts              # Entry point
│   └── searchUserByEmail.ts  # User search function
├── test/
│   └── searchUserByEmail.test.ts
├── lib/                      # Compiled output (gitignored)
├── package.json
├── tsconfig.json
└── README.md
```

## Error Codes

| Code | Description |
|------|-------------|
| `unauthenticated` | User is not authenticated |
| `permission-denied` | User doesn't have permission |
| `invalid-argument` | Invalid email format or missing parameter |
| `internal` | Server error |

## Best Practices

1. **Security First**: Always validate input and check authentication
2. **Error Handling**: Use proper HttpsError codes
3. **Testing**: Maintain 80%+ code coverage
4. **Documentation**: Update this README when adding new functions
5. **Logging**: Use console.log/error for debugging (visible in Functions logs)
