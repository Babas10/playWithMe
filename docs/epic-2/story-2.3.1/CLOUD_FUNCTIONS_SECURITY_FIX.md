# Cloud Functions Security Fix - User Search

## Problem

The original implementation of user search in the "Invite Member" flow queried Firestore's `/users` collection directly from the Flutter client:

```dart
// INSECURE - Direct Firestore query from client
final results = await _userRepository.searchUsers(query, limit: 20);
```

This approach had a **critical security flaw**:

### Firestore Security Rules

```
match /users/{userId} {
  allow read, update, delete: if request.auth.uid == userId;
  allow create: if request.auth != null;
}
```

- Users can only read their own document
- No global read access
- **No search or list operations allowed**

### The Issue

When the client tried to search users, it resulted in:
```
permission-denied: Missing or insufficient permissions
```

We could NOT loosen the security rules to allow global read access because:
1. **Privacy violation**: Would expose all user data
2. **Security risk**: Any authenticated user could scrape the entire user database
3. **Best practice violation**: Client-side queries should not have blanket access to sensitive collections

## Solution: Cloud Functions

We implemented a **secure Cloud Function** that acts as a trusted intermediary:

### Architecture

```
Flutter Client
    ↓ (HTTPS callable)
Cloud Function (searchUserByEmail)
    ↓ (Admin SDK - bypass rules)
Firestore /users collection
    ↓
Cloud Function (filter sensitive data)
    ↓
Flutter Client (receives safe data)
```

### Implementation

#### 1. Cloud Function (`functions/src/searchUserByEmail.ts`)

```typescript
export const searchUserByEmail = functions.https.onCall(
  async (data, context) => {
    // ✅ Authentication check
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '...');
    }

    // ✅ Input validation
    const email = data.email.toLowerCase().trim();

    // ✅ Query Firestore (using Admin SDK - bypasses security rules)
    const querySnapshot = await db.collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    // ✅ Return only non-sensitive data
    return {
      found: true,
      user: {
        uid: userDoc.id,
        displayName: userData.displayName,
        email: userData.email,
        photoUrl: userData.photoUrl,
        // ❌ No passwords, roles, or private data
      }
    };
  }
);
```

#### 2. Flutter Client (`lib/features/groups/presentation/pages/invite_member_page.dart`)

```dart
// Call Cloud Function securely
final callable = FirebaseFunctions.instance.httpsCallable('searchUserByEmail');
final result = await callable.call({
  'email': query.trim(),
});

// Handle response
if (result.data['found'] == true) {
  final user = UserModel.fromJson(result.data['user']);
  // Display user...
}
```

## Security Benefits

### 1. **Zero Trust Architecture**
- Firestore rules remain strict (only owner can read)
- Cloud Function uses Admin SDK (trusted server-side)
- Client has no direct access to user collection

### 2. **Data Filtering**
- Cloud Function returns ONLY necessary fields
- Sensitive data never leaves Firestore
- No accidental data exposure

### 3. **Audit Trail**
- All searches logged in Cloud Functions
- Can track who searched for whom
- Can add rate limiting if needed

### 4. **Input Validation**
- Email format validation
- Prevents injection attacks
- Normalizes input (trim, lowercase)

### 5. **Authentication Required**
- Only logged-in users can search
- Can add additional authorization logic
- Can restrict to admins only if needed

## Comparison

| Aspect | Direct Query (❌) | Cloud Function (✅) |
|--------|------------------|-------------------|
| **Security Rules** | Must be loosened | Remain strict |
| **Privacy** | All users exposed | Filtered response |
| **Validation** | Client-side only | Server-side enforced |
| **Logging** | Not available | Full audit trail |
| **Scalability** | Limited by rules | Unlimited (Admin SDK) |
| **Cost** | Firestore reads | Firestore + Functions |

## Testing

### Local Development (Emulator)

```bash
# Terminal 1: Start emulators
firebase emulators:start --only auth,firestore,functions

# Terminal 2: Run Flutter app
flutter run --flavor dev -t lib/main_dev.dart -d chrome
```

The app automatically connects to `localhost:5001` for functions in dev mode.

### Testing Flow

1. Register two users (user1@test.com, user2@test.com)
2. User1 creates a group
3. User1 navigates to group details → Invite Member
4. User1 searches for "user2@test.com"
5. ✅ Cloud Function returns user2's data
6. User1 sends invitation
7. User2 receives invitation

### Error Handling

```dart
try {
  final result = await callable.call({'email': email});
} on FirebaseFunctionsException catch (e) {
  switch (e.code) {
    case 'unauthenticated':
      // User not logged in
    case 'permission-denied':
      // No permission (shouldn't happen)
    case 'invalid-argument':
      // Bad email format
    case 'not-found':
      // User doesn't exist
  }
}
```

## Deployment

### Dev Environment
```bash
# Functions run in emulator
firebase emulators:start --only functions
```

### Production
```bash
# Build and deploy
cd functions
npm run build
firebase deploy --only functions:searchUserByEmail --project playwithme-prod
```

## Performance

- **Latency**: ~100-300ms (acceptable for search)
- **Cost**: ~$0.40 per 1M invocations
- **Scalability**: Auto-scales with Firebase

## Future Enhancements

1. **Caching**: Add Redis/Memcache for frequently searched emails
2. **Rate Limiting**: Prevent abuse (e.g., 10 searches/minute)
3. **Full-Text Search**: Use Algolia for name-based search
4. **Batch Search**: Search multiple users at once
5. **Analytics**: Track search patterns

## Files Changed

### New Files
- `functions/src/searchUserByEmail.ts` - Cloud Function
- `functions/src/index.ts` - Functions entry point
- `functions/test/searchUserByEmail.test.ts` - Unit tests
- `functions/package.json` - Dependencies
- `functions/tsconfig.json` - TypeScript config

### Modified Files
- `lib/features/groups/presentation/pages/invite_member_page.dart` - Use Cloud Function
- `lib/core/services/firebase_service.dart` - Configure emulator
- `firebase.json` - Add functions config
- `pubspec.yaml` - Add cloud_functions package

## Firestore Rules (Unchanged)

```
match /users/{userId} {
  allow read, update, delete: if request.auth.uid == userId;
  allow create: if request.auth != null;
  // ❌ NO global read access
  // ❌ NO search queries
}
```

**Rules remain strict - security maintained!**

## Conclusion

This refactoring:
- ✅ Fixes the permission-denied error
- ✅ Maintains strict security rules
- ✅ Protects user privacy
- ✅ Follows Firebase best practices
- ✅ Provides foundation for future features

The Cloud Function acts as a **secure API gateway** between the client and sensitive data, ensuring that only authorized, validated, and filtered information is ever exposed.
