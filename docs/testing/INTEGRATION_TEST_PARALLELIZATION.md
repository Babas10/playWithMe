# Integration Test Parallelization Guide

This document explains how to parallelize integration tests using GitHub Actions matrix strategy for faster CI execution.

## Current Setup (Sequential)

Currently, integration tests run sequentially in a single job:

```yaml
- name: 🧪 Run Integration Tests
  run: |
    for test_file in integration_test/*_test.dart; do
      flutter drive --target="$test_file" ...
    done
```

**Time**: ~8-12 minutes (4 tests × 2-3 min each)

---

## Parallelized Setup (Matrix Strategy)

### Benefits

- **Faster CI**: Tests run in parallel across multiple runners
- **Scalable**: Easily add more tests without increasing total runtime
- **Isolated**: Each test runs in its own clean environment
- **Better debugging**: Failed tests don't block other tests

### Implementation

Replace the current `.github/workflows/integration-tests.yml` with this matrix-based version:

```yaml
name: Integration Tests (Firebase Emulator)

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  # Job 1: Discover test files dynamically
  discover-tests:
    name: 🔍 Discover Integration Tests
    runs-on: ubuntu-latest
    outputs:
      test-files: ${{ steps.discover.outputs.test-files }}
    steps:
      - name: 📥 Checkout Repository
        uses: actions/checkout@v4

      - name: 🔍 Discover Test Files
        id: discover
        run: |
          # Find all integration test files
          TEST_FILES=$(find integration_test -name "*_test.dart" | jq -R -s -c 'split("\n")[:-1]')
          echo "test-files=$TEST_FILES" >> $GITHUB_OUTPUT
          echo "Found tests: $TEST_FILES"

  # Job 2: Run tests in parallel using matrix
  integration-tests:
    name: 🔥 Test ${{ matrix.test-file }}
    runs-on: ubuntu-latest
    needs: discover-tests

    # Matrix strategy: run one job per test file
    strategy:
      fail-fast: false  # Continue other tests even if one fails
      matrix:
        test-file: ${{ fromJson(needs.discover-tests.outputs.test-files) }}

    env:
      CI: true
      FIRESTORE_EMULATOR_HOST: localhost:8080
      FIREBASE_AUTH_EMULATOR_HOST: localhost:9099

    steps:
      # Step 1: Checkout
      - name: 📥 Checkout Repository
        uses: actions/checkout@v4

      # Step 2: Setup Flutter
      - name: 🔧 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.6'
          channel: 'stable'
          cache: true

      # Step 3: Setup Node.js for Firebase CLI
      - name: 🟢 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      # Step 4: Install Firebase CLI
      - name: 🔥 Install Firebase CLI
        run: npm install -g firebase-tools

      # Step 5: Setup Java for Firestore Emulator
      - name: ☕ Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'

      # Step 6: Get Flutter dependencies
      - name: 📦 Get Flutter Dependencies
        run: flutter pub get

      # Step 7: Generate Mock Firebase Configs
      - name: 🔧 Generate Mock Firebase Configs
        run: dart run tools/generate_mock_firebase_configs.dart

      # Step 8: Setup ChromeDriver
      - name: 🌐 Setup ChromeDriver
        run: |
          chromedriver --port=4444 &
          echo "CHROMEDRIVER_PID=$!" >> $GITHUB_ENV
          sleep 2

      # Step 9: Start Firebase Emulators
      - name: 🚀 Start Firebase Emulators
        run: |
          firebase emulators:start --only auth,firestore --project playwithme-dev &
          EMULATOR_PID=$!
          echo "EMULATOR_PID=$EMULATOR_PID" >> $GITHUB_ENV

          # Wait for emulators
          for i in {1..60}; do
            if curl -s http://localhost:4000 > /dev/null 2>&1; then
              echo "✅ Emulators ready!"
              break
            fi
            sleep 1
          done

      # Step 10: Smoke Check
      - name: 🔍 Verify Emulator Health
        run: |
          curl -s -f http://localhost:8080 || exit 1
          curl -s -f http://localhost:9099 || exit 1
          echo "✅ Emulators healthy!"

      # Step 11: Run THIS test file only
      - name: 🧪 Run Integration Test
        run: |
          echo "Running ${{ matrix.test-file }}..."
          flutter drive \
            --driver=test_driver/integration_test.dart \
            --target="${{ matrix.test-file }}" \
            -d web-server \
            --web-port=7357 \
            --web-browser-flag="--disable-gpu" \
            --web-browser-flag="--no-sandbox" \
            --web-browser-flag="--headless"

      # Step 12: Cleanup
      - name: 🛑 Stop Emulators
        if: always()
        run: |
          kill $EMULATOR_PID || true
          kill $CHROMEDRIVER_PID || true
          pkill -f "firebase emulators" || true
          pkill -f "chromedriver" || true

      # Step 13: Upload logs on failure
      - name: 📤 Upload Logs
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: logs-${{ hashFiles(matrix.test-file) }}
          path: |
            firestore-debug.log
            firebase-debug.log
          retention-days: 7

  # Job 3: Aggregate results
  integration-tests-summary:
    name: 📊 Integration Tests Summary
    runs-on: ubuntu-latest
    needs: integration-tests
    if: always()

    steps:
      - name: 📋 Check Test Results
        run: |
          if [ "${{ needs.integration-tests.result }}" == "failure" ]; then
            echo "❌ Some integration tests failed"
            exit 1
          else
            echo "✅ All integration tests passed!"
          fi
```

---

## Performance Comparison

| Setup      | Runtime | Cost (minutes) | Notes                              |
| ---------- | ------- | -------------- | ---------------------------------- |
| Sequential | 12 min  | 12 min         | Current setup                      |
| Parallel   | 3 min   | 12 min (4×3)   | Same cost, 4× faster wall-clock time |

**Note**: GitHub Actions charges for total compute time (12 min), but parallelization reduces wait time from 12 min to 3 min.

---

## When to Use Matrix Strategy

**Use Matrix When:**
✅ You have 4+ integration test files
✅ Each test takes 2+ minutes to run
✅ Tests are independent (no shared state)
✅ You need faster feedback loops

**Stick with Sequential When:**
❌ You have < 4 test files
❌ Tests are very fast (< 1 minute each)
❌ GitHub Actions minute quotas are limited
❌ Tests require shared state/setup

---

## Current Status

As of now (Story 2.3 completion), we have **4 integration test files**:
- `invitation_acceptance_test.dart` (6 tests)
- `invitation_creation_test.dart` (4 tests)
- `invitation_decline_test.dart` (5 tests)
- `invitation_security_rules_test.dart` (10 tests)

**Recommendation**: Continue with sequential execution for now. Switch to matrix when we have 8+ test files or tests take > 15 minutes total.

---

## Migration Steps

If you decide to parallelize in the future:

1. **Backup current workflow**:
   ```bash
   cp .github/workflows/integration-tests.yml .github/workflows/integration-tests.sequential.yml
   ```

2. **Replace with matrix version** (shown above)

3. **Test in a feature branch**:
   ```bash
   git checkout -b test/parallel-integration-tests
   # Update workflow
   git push origin test/parallel-integration-tests
   ```

4. **Verify all tests pass** in parallel mode

5. **Merge to main** after validation

---

## Advanced: Dynamic Port Allocation

If tests conflict on ports, use dynamic port allocation:

```yaml
strategy:
  matrix:
    test-file: [...]
    port: [7357, 7358, 7359, 7360]  # One port per test

steps:
  - name: Start Emulators
    run: |
      firebase emulators:start \
        --only auth,firestore \
        --project playwithme-dev \
        --port=${{ matrix.port }} &

  - name: Run Test
    run: |
      flutter drive --web-port=${{ matrix.port }} ...
```

---

## Monitoring Parallelization

After enabling matrix strategy, monitor:

1. **Total runtime**: Should decrease to ~1/N of sequential time (N = number of test files)
2. **Flakiness**: Parallel tests may expose race conditions
3. **Cost**: GitHub Actions charges for total runner minutes (not wall-clock time)

---

**Last Updated**: October 26, 2025
**Next Review**: When integration test suite exceeds 8 files or 15 minutes runtime
