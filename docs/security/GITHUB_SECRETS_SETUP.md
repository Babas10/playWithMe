# GitHub Secrets Setup for CI/CD Pipeline

This document explains how to set up GitHub Secrets for the PlayWithMe CI/CD pipeline to use real Firebase configurations in continuous integration.

## Overview

The CI/CD pipeline uses a Firebase service account to authenticate with Firebase services during testing and building. This approach allows the pipeline to use real Firebase project configurations instead of mock data, providing more accurate testing.

## Required GitHub Secret

### FIREBASE_SERVICE_ACCOUNT

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