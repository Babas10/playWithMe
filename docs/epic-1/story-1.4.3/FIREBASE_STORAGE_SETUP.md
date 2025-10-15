# Firebase Storage Setup for Avatar Upload

## Problem
If you're seeing the error `[firebase_storage/object-not-found] No object exists at the desired reference`, it's likely due to missing or incorrect Firebase Storage security rules.

## Solution

### 1. Deploy Firebase Storage Rules

The project includes a `storage.rules` file in the root directory. You need to deploy these rules to your Firebase project.

#### Option A: Using Firebase CLI (Recommended)

```bash
# Make sure you're in the project root
cd /path/to/playWithMe

# Deploy storage rules to dev environment
firebase deploy --only storage:rules --project playwithme-dev

# Deploy to staging (when ready)
firebase deploy --only storage:rules --project playwithme-stg

# Deploy to production (when ready)
firebase deploy --only storage:rules --project playwithme-prod
```

#### Option B: Manual Deployment via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (e.g., `playwithme-dev`)
3. Navigate to **Storage** → **Rules**
4. Copy the content from `storage.rules` file
5. Paste it into the rules editor
6. Click **Publish**

### 2. Verify Storage Rules Are Active

After deploying, verify the rules are active:

1. Go to Firebase Console → Storage → Rules
2. You should see rules for `/avatars/{userId}/{fileName}`
3. Test by uploading an avatar through the app

### 3. Storage Rules Explanation

The rules allow:
- ✅ **Read**: Any authenticated user can read avatars (to display other users' profile pictures)
- ✅ **Write**: Users can only upload/update their own avatars
- ✅ **Delete**: Users can only delete their own avatars
- ✅ **Validation**: Images must be < 5MB and in JPEG/PNG/WebP format

### 4. Testing Storage Upload

After deploying the rules, test the avatar upload:

1. Run the app in dev environment
2. Navigate to Profile → Edit Profile
3. Tap the camera icon on the avatar
4. Select an image from gallery or camera
5. Crop the image
6. Tap "Upload"
7. Verify the avatar appears in the profile

### 5. Troubleshooting

If you still encounter errors:

#### Check Firebase Storage is Enabled
```bash
# View your Firebase project status
firebase projects:list

# Check storage configuration
firebase storage:get
```

#### Check Authentication
- Make sure the user is authenticated before uploading
- The error might occur if `request.auth.uid` is null

#### Check File Permissions
- Ensure the app has permission to read the selected image file
- On Android: Check `READ_EXTERNAL_STORAGE` permission
- On iOS: Check photo library usage description in `Info.plist`

#### View Firebase Storage Logs
1. Go to Firebase Console → Storage
2. Click on "Files" tab
3. Check if any files were uploaded to `avatars/{userId}/`
4. If files exist but can't be read, it's a rules issue

### 6. Development vs Production Rules

The current rules are suitable for development and production. However, you may want to add additional restrictions for production:

```javascript
// Example: Limit upload frequency (requires Firestore)
function hasNotUploadedRecently() {
  return !exists(/databases/$(database)/documents/users/$(request.auth.uid)/lastAvatarUpload)
      || get(/databases/$(database)/documents/users/$(request.auth.uid)/lastAvatarUpload).data.timestamp
         < request.time - duration.value(1, 'm'); // 1 minute cooldown
}
```

## Firebase Storage Structure

After successful uploads, your storage will look like this:

```
gs://playwithme-dev.appspot.com/
└── avatars/
    └── {userId}/
        └── avatar_1634567890123.jpg
        └── avatar_1634567891234.png
```

## Related Documentation

- [Firebase Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Story 1.4.3 README](./README.md)
- [Firebase Config Security](../../security/FIREBASE_CONFIG_SECURITY.md)
