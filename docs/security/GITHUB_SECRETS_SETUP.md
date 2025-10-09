# GitHub Secrets Setup for CI/CD Pipeline

This document explains how to set up GitHub Secrets for the PlayWithMe CI/CD pipeline to use real Firebase configurations in continuous integration.

## Overview

The CI/CD pipeline uses GitHub Secrets to securely provide Firebase configuration data to the build process. This approach ensures no sensitive Firebase API keys are committed to the repository while still allowing CI/CD to build and test with real Firebase projects.

## 🔒 Security Benefits

- **No secrets in repository**: Firebase API keys and configuration data are stored securely in GitHub Secrets
- **Environment isolation**: Each environment (dev/stg/prod) has separate secrets
- **Audit trail**: GitHub provides logging of secret access
- **Easy rotation**: Secrets can be updated without changing code

## Required GitHub Secrets

### Firebase Configuration Secrets

The following secrets are required for each environment (dev, stg, prod):

#### Development Environment (DEV)
- `FIREBASE_DEV_PROJECT_ID`
- `FIREBASE_DEV_STORAGE_BUCKET`
- `FIREBASE_DEV_ANDROID_APP_ID`
- `FIREBASE_DEV_IOS_APP_ID`
- `FIREBASE_DEV_API_KEY`
- `FIREBASE_DEV_MESSAGING_SENDER_ID`
- `FIREBASE_DEV_ANDROID_PACKAGE_NAME`
- `FIREBASE_DEV_IOS_BUNDLE_ID`

#### Staging Environment (STG)
- `FIREBASE_STG_PROJECT_ID`
- `FIREBASE_STG_STORAGE_BUCKET`
- `FIREBASE_STG_ANDROID_APP_ID`
- `FIREBASE_STG_IOS_APP_ID`
- `FIREBASE_STG_API_KEY`
- `FIREBASE_STG_MESSAGING_SENDER_ID`
- `FIREBASE_STG_ANDROID_PACKAGE_NAME`
- `FIREBASE_STG_IOS_BUNDLE_ID`

#### Production Environment (PROD)
- `FIREBASE_PROD_PROJECT_ID`
- `FIREBASE_PROD_STORAGE_BUCKET`
- `FIREBASE_PROD_ANDROID_APP_ID`
- `FIREBASE_PROD_IOS_APP_ID`
- `FIREBASE_PROD_API_KEY`
- `FIREBASE_PROD_MESSAGING_SENDER_ID`
- `FIREBASE_PROD_ANDROID_PACKAGE_NAME`
- `FIREBASE_PROD_IOS_BUNDLE_ID`

## 🔧 Setup Instructions

### Step 1: Extract Firebase Configuration Values

For each environment, you need to extract the configuration values from your Firebase project:

1. **Go to Firebase Console**: [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. **Select the project** (e.g., `playwithme-dev`)
3. **Navigate to Project Settings** → General tab
4. **Copy the project configuration**:
   - **Project ID**: Found in "Project settings" section
   - **Storage Bucket**: Usually `{project-id}.firebasestorage.app`
   - **Messaging Sender ID**: Found in "Cloud Messaging" tab
5. **Get App-specific values**:
   - **Android**: Download `google-services.json` and extract values
   - **iOS**: Download `GoogleService-Info.plist` and extract values

### Step 2: Add Secrets to GitHub Repository

1. **Go to your GitHub repository**
2. **Navigate to Settings** → Secrets and variables → Actions
3. **Add each secret individually**:
   - Click "New repository secret"
   - Enter the secret name (e.g., `FIREBASE_DEV_PROJECT_ID`)
   - Enter the corresponding value
   - Click "Add secret"

### Example Configuration Values

```bash
# Development Environment Example
FIREBASE_DEV_PROJECT_ID=playwithme-dev
FIREBASE_DEV_STORAGE_BUCKET=playwithme-dev.firebasestorage.app
FIREBASE_DEV_ANDROID_APP_ID=1:123456789:android:abcdef123456
FIREBASE_DEV_IOS_APP_ID=1:123456789:ios:abcdef123456
FIREBASE_DEV_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_DEV_MESSAGING_SENDER_ID=123456789
FIREBASE_DEV_ANDROID_PACKAGE_NAME=com.playwithme.play_with_me.dev
FIREBASE_DEV_IOS_BUNDLE_ID=com.playwithme.playWithMe.dev
```

### Step 3: Verify Secrets Setup

After adding all secrets, your repository should have 24 secrets total (8 secrets × 3 environments).

The CI/CD pipeline uses the secure script `tools/generate_firebase_config_from_secrets.dart` to generate configuration files from these secrets.

### Legacy: FIREBASE_SERVICE_ACCOUNT (Optional)

**Purpose**: Contains the Firebase service account JSON that allows CI/CD to authenticate with Firebase services.

**Setup Steps**:

1. **Generate Firebase Service Account Key**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (e.g., `playwithme-dev`)
   - Navigate to Project Settings → Service Accounts
   - Click "Generate new private key"
   - Download the JSON file

2. **Add Secret to GitHub Repository**:
   - Go to your GitHub repository
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `FIREBASE_SERVICE_ACCOUNT`
   - Value: Copy and paste the **entire contents** of the downloaded JSON file
   - Click "Add secret"

## Service Account JSON Structure

The service account JSON should look like this:

```json
{
  "type": "service_account",
  "project_id": "playwithme-dev",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "...",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

## Security Considerations

⚠️ **CRITICAL SECURITY NOTES**:

1. **Never commit service account files** to the repository
2. **Use repository secrets only** - never use environment variables in workflow files for sensitive data
3. **Limit service account permissions** to only what's needed for CI/CD
4. **Rotate service account keys** regularly (every 90 days recommended)
5. **Monitor service account usage** in Firebase Console

## How It Works in CI/CD

1. **Secret Injection**: GitHub Actions injects the `FIREBASE_SERVICE_ACCOUNT` secret into the workflow
2. **File Creation**: The secret content is written to `firebase-service-account.json`
3. **Environment Setup**: `GOOGLE_APPLICATION_CREDENTIALS` points to the service account file
4. **Config Generation**: The `generate_firebase_config.dart` script uses the service account to generate environment-specific configs
5. **Testing**: Tests run with real Firebase project configurations
6. **Cleanup**: The service account file is automatically removed when the job completes

## Required Firebase Permissions

The service account should have these minimal permissions:

- **Firebase Admin SDK Admin Service Agent**: For full Firebase access during testing
- **Service Account User**: To use the service account in CI/CD

## Troubleshooting

### Common Issues

1. **"Invalid service account" error**:
   - Verify the JSON format is correct
   - Ensure no extra spaces or formatting in the GitHub secret
   - Check that the service account is enabled in Firebase

2. **"Permission denied" error**:
   - Verify service account has required permissions
   - Check that the service account is associated with the correct Firebase project

3. **"Config generation failed" error**:
   - Ensure all three Firebase projects (dev, stg, prod) exist
   - Verify service account has access to all projects
   - Check that Firebase CLI tools are properly configured

### Validation

You can validate your setup by:

1. Running the CI/CD pipeline and checking the logs
2. Verifying that Firebase configs are generated successfully
3. Ensuring tests pass with real Firebase data

## Environment Isolation

The pipeline generates configurations for three environments:

- **dev**: `playwithme-dev` project
- **stg**: `playwithme-stg` project
- **prod**: `playwithme-prod` project

Each environment uses its own Firebase project to ensure proper isolation during testing and deployment.