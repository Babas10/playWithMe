# Story 0.3: CI/CD Pipeline with GitHub Actions

## Overview

This document describes the implementation of the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the PlayWithMe project using GitHub Actions.

## Goal

Automate the process of testing and validating code every time a change is proposed, ensuring code quality and preventing broken code from reaching the main branch.

## Implementation

### Pipeline File Structure

```
.github/
└── workflows/
    └── main.yml    # Main CI/CD pipeline workflow
```

### Pipeline Triggers

The CI/CD pipeline triggers on:
- **Pull Requests** to `main` or `develop` branches
- **Push events** to `main` or `develop` branches

### Pipeline Jobs

#### 1. 📊 Analyze & Test Job

**Purpose**: Static analysis, dependency verification, and testing

**Steps**:
1. **Checkout Repository** - Downloads the source code
2. **Setup Flutter** - Configures Flutter SDK v3.24.0 (stable)
3. **Verify Flutter Installation** - Ensures Flutter is properly installed
4. **Get Dependencies** - Runs `flutter pub get`
5. **Verify Dependencies** - Runs `flutter pub deps` to ensure dependency resolution
6. **Static Analysis** - Runs `flutter analyze` (currently in warning-only mode)
7. **Code Formatting Check** - Runs `dart format` (currently informational)
8. **Run Tests** - Executes all unit and widget tests with coverage
9. **Upload Coverage** - Sends coverage reports to Codecov (optional)

#### 2. 🔨 Build Verification Job

**Purpose**: Verify builds work across multiple platforms and flavors

**Strategy**: Matrix build for:
- **Platforms**: Android, Web
- **Flavors**: dev, stg, prod

**Dependencies**: Only runs if `analyze_and_test` job passes

**Steps**:
1. **Checkout Repository**
2. **Setup Flutter**
3. **Setup Java** - For Android builds (Java 17)
4. **Get Dependencies**
5. **Build** - Platform-specific builds:
   - Android: `flutter build apk --flavor <flavor> -t lib/main_<flavor>.dart --debug`
   - Web: `flutter build web -t lib/main_<flavor>.dart --debug`

#### 3. 🔗 Integration Tests Job

**Purpose**: Run integration tests when available

**Dependencies**: Only runs if `analyze_and_test` job passes

**Steps**:
1. **Checkout Repository**
2. **Setup Flutter**
3. **Get Dependencies**
4. **Run Integration Tests** - Executes tests in `integration_test/` directory

#### 4. 🔒 Security Audit Job

**Purpose**: Security and dependency vulnerability checks

**Dependencies**: Only runs if `analyze_and_test` job passes

**Steps**:
1. **Checkout Repository**
2. **Setup Flutter**
3. **Get Dependencies**
4. **Security Audit** - Checks dependency vulnerabilities
5. **Secrets Detection** - Ensures no Firebase config files are committed

#### 5. ✅ CI Success Job

**Purpose**: Final status consolidation

**Dependencies**: Runs after all other jobs complete

**Steps**:
- **Success Report** - If all jobs pass
- **Failure Report** - If any job fails (exits with error code 1)

## Security Features

### Firebase Configuration Protection

The pipeline includes automated checks to prevent accidental commitment of sensitive Firebase configuration files:

- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

If these files are found in the repository, the pipeline will fail with clear error messages.

### Dependency Security

The pipeline performs basic security auditing of Flutter dependencies to identify known vulnerabilities.

## Current Configuration

### Analysis Mode

Currently configured in **warning-only mode** to establish CI/CD baseline:

- Static analysis runs but doesn't fail the build
- Code formatting is checked but informational only
- TODO: Enable strict mode (`--fatal-warnings`) in future iterations

### Test Requirements

- **Zero Tolerance**: All tests must pass for the pipeline to succeed
- **Coverage**: Coverage reports are generated and uploaded
- **Required Tests**: Unit tests, widget tests, and integration tests

## Usage

### For Developers

1. **Create Pull Request**: Pipeline automatically triggers
2. **Review Results**: Check GitHub Actions tab for detailed results
3. **Fix Issues**: Address any failing tests or build issues
4. **Merge**: Only allowed when all checks pass

### Pipeline Status Indicators

- ✅ **Green Check**: All pipeline jobs passed
- ❌ **Red X**: One or more pipeline jobs failed
- 🟡 **Yellow Circle**: Pipeline is currently running

## Testing the Pipeline

### Test Cases Verified

1. **Passing Tests**: Pipeline allows merge when all tests pass
2. **Failing Tests**: Pipeline blocks merge when tests fail
3. **Build Verification**: All platform/flavor combinations build successfully
4. **Security Checks**: Firebase config files are properly excluded

### Local Testing Commands

To test pipeline steps locally:

```bash
# Dependencies
flutter pub get
flutter pub deps

# Analysis (current warning-only mode)
flutter analyze

# Formatting check
dart format --set-exit-if-changed .

# Tests
flutter test --coverage

# Integration tests
flutter test integration_test/

# Build verification
flutter build apk --flavor dev -t lib/main_dev.dart --debug
flutter build web -t lib/main_dev.dart --debug
```

## Evolution Plan

### Phase 1 (Current): Baseline Establishment
- ✅ Pipeline infrastructure in place
- ✅ Basic testing automation
- ✅ Build verification across platforms
- ✅ Security checks implemented

### Phase 2 (Future): Quality Enforcement
- 🔄 Enable strict static analysis (`--fatal-warnings`)
- 🔄 Enforce code formatting requirements
- 🔄 Add performance testing
- 🔄 Implement automated deployment to staging

### Phase 3 (Future): Advanced Features
- 🔄 Automated deployment to production
- 🔄 Advanced security scanning
- 🔄 Performance regression testing
- 🔄 Automated release notes generation

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Flutter version compatibility
   - Verify dependency resolution with `flutter pub deps`

2. **Test Failures**
   - Run tests locally: `flutter test`
   - Check for environment-specific issues

3. **Security Check Failures**
   - Ensure Firebase config files are in `.gitignore`
   - Remove any accidentally committed config files

### Getting Help

- Check the GitHub Actions logs for detailed error messages
- Refer to the [CLAUDE.md](../../../CLAUDE.md) for project standards
- Contact the development team for pipeline-specific issues

## Conclusion

The CI/CD pipeline ensures code quality and prevents regression issues by automatically testing every change. It provides a foundation for safe, automated development practices while maintaining the high quality standards defined in the project's engineering guidelines.