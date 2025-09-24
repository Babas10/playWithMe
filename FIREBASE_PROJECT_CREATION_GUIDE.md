# Firebase Project Creation Guide - Story 0.2.1

This guide provides step-by-step instructions for creating the three required Firebase projects for the PlayWithMe app.

## Prerequisites

Before starting, ensure you have:
- [ ] A Google account with Firebase access
- [ ] Administrative permissions to create Firebase projects
- [ ] Access to the Firebase Console (https://console.firebase.google.com/)

## Required Projects

You need to create exactly **3 Firebase projects** with these specific names:

| Environment | Project ID | Purpose |
|-------------|------------|---------|
| Development | `playwithme-dev` | Local development and integration tests |
| Staging | `playwithme-stg` | Internal testing and QA environment |
| Production | `playwithme-prod` | Live application for end users |

## Step-by-Step Instructions

### Step 1: Access Firebase Console

1. Go to https://console.firebase.google.com/
2. Sign in with your Google account
3. You should see the Firebase Console dashboard

### Step 2: Create Development Project

1. **Click "Create a project" or "Add project"**
2. **Project name**: Enter `PlayWithMe Development`
3. **Project ID**: Ensure it shows `playwithme-dev`
   - If the ID is different, click the edit icon and change it to `playwithme-dev`
   - If `playwithme-dev` is taken, try `playwithme-dev-[your-suffix]`
4. **Location**: Select your preferred region (recommend US-Central or Europe-West)
5. **Google Analytics**:
   - Toggle OFF for development environment (recommended)
   - Or create a new Analytics account if you prefer
6. **Click "Create project"**
7. **Wait for project creation to complete**
8. **📝 Record the Project ID** in the tracking document (see Step 4)

### Step 3: Create Staging Project

1. **Return to Firebase Console home** (click Firebase logo)
2. **Click "Create a project" or "Add project"**
3. **Project name**: Enter `PlayWithMe Staging`
4. **Project ID**: Ensure it shows `playwithme-stg`
   - If the ID is different, edit it to `playwithme-stg`
   - If taken, try `playwithme-stg-[your-suffix]`
5. **Location**: Use the same region as development project
6. **Google Analytics**: Toggle OFF for staging (recommended)
7. **Click "Create project"**
8. **Wait for project creation to complete**
9. **📝 Record the Project ID** in the tracking document

### Step 4: Create Production Project

1. **Return to Firebase Console home**
2. **Click "Create a project" or "Add project"**
3. **Project name**: Enter `PlayWithMe Production`
4. **Project ID**: Ensure it shows `playwithme-prod`
   - If different, edit it to `playwithme-prod`
   - If taken, try `playwithme-prod-[your-suffix]`
5. **Location**: Use the same region as other projects
6. **Google Analytics**:
   - Toggle ON for production (recommended for analytics)
   - Create new Analytics account: `PlayWithMe Analytics`
7. **Click "Create project"**
8. **Wait for project creation to complete**
9. **📝 Record the Project ID** in the tracking document

## Step 5: Verify Project Creation

After creating all projects:

1. **Return to Firebase Console home**
2. **Verify you see all 3 projects** in your project list:
   - PlayWithMe Development (`playwithme-dev`)
   - PlayWithMe Staging (`playwithme-stg`)
   - PlayWithMe Production (`playwithme-prod`)

3. **Click into each project** and verify:
   - Project loads without errors
   - You have Owner/Editor permissions
   - Project dashboard displays correctly

## Step 6: Document Project IDs

Run the verification script to document your project IDs:

```bash
# Run from the project root
dart run tools/firebase_project_tracker.dart --record
```

This will create/update a secure tracking file with your project information.

## Troubleshooting

### Project ID Already Exists
If your preferred project ID is taken:
1. Try adding a suffix: `playwithme-dev-yourname`
2. Use a timestamp: `playwithme-dev-2024`
3. **Important**: Update the Flutter configuration to match your actual project IDs

### Permission Issues
- Ensure your Google account has Firebase project creation permissions
- If using a work/organization account, check with your admin
- You may need billing enabled for multiple projects

### Project Creation Fails
- Check internet connection
- Try a different browser or incognito mode
- Clear browser cache and cookies for Firebase Console
- Wait a few minutes and retry

### Region Selection
- Choose a region close to your target users
- Use the same region for all three projects for consistency
- Common choices: `us-central1`, `europe-west1`, `asia-southeast1`

## Security Considerations

- **Never share project IDs publicly** in code repositories
- Use environment variables or secure configuration for project IDs
- Set appropriate Firebase security rules for each environment
- Consider different Google accounts for production vs development

## Next Steps

After successfully creating all projects:

1. **✅ Mark Story 0.2.1 as complete**
2. **Move to Story 0.2.2**: Replace placeholder config files
3. **Configure Firebase services**: Authentication, Firestore, etc.
4. **Set up security rules** for each environment
5. **Test connectivity** from Flutter app

## Verification Checklist

- [ ] All 3 Firebase projects created successfully
- [ ] Project IDs documented securely
- [ ] All projects accessible from Firebase Console
- [ ] Consistent region selection across projects
- [ ] Appropriate analytics settings configured
- [ ] No errors when accessing project dashboards
- [ ] Ready to proceed with Story 0.2.2

---

## Need Help?

If you encounter issues during project creation:
1. Check the troubleshooting section above
2. Review Firebase Console documentation
3. Verify your Google account permissions
4. Consider reaching out for technical support

**Once you've completed these steps, all three Firebase projects will be ready for the next phase of configuration!**