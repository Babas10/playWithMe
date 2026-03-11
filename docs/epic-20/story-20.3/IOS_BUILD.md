# Story 20.3 — iOS Signing & Release Build Configuration

## Overview

The iOS release build uses **Automatic Signing** with an **App Store Connect API key**
for authentication. This avoids managing certificates and provisioning profiles manually
in CI — Xcode resolves them from Apple's servers at build time using the API key.

---

## Xcode Project Configuration

File: `ios/Runner.xcodeproj/project.pbxproj`

| Setting | Value |
|---------|-------|
| `CODE_SIGN_STYLE` | `Automatic` |
| `DEVELOPMENT_TEAM` | `2FN99DA6RR` |
| `PRODUCT_BUNDLE_IDENTIFIER` (prod) | `org.gatherli.app` |
| `PRODUCT_BUNDLE_IDENTIFIER` (dev) | `org.gatherli.app.dev` |

No manual certificate or provisioning profile management is needed.

---

## ExportOptions.plist

File: `ios/ExportOptions.plist`

Configures the IPA export for App Store upload:

- `method`: `app-store` — targets the App Store (not ad-hoc or enterprise)
- `destination`: `upload` — uploads directly to App Store Connect
- `signingStyle`: `automatic` — lets Xcode manage signing
- `uploadSymbols`: `true` — enables crash symbolication in App Store Connect
- `uploadBitcode`: `false` — bitcode is deprecated as of Xcode 14

---

## Required GitHub Secrets

| Secret Name | Description |
|-------------|-------------|
| `APP_STORE_CONNECT_API_KEY_ID` | 10-char Key ID (from `.p8` filename) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | UUID from App Store Connect API page |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded `.p8` private key file |
| `IOS_BUNDLE_ID` | `org.gatherli.app` |

See `docs/epic-20/story-20.1/SECRETS_SETUP.md` for how to generate these.

---

## Build Command

Used in CI pipeline (Stories 20.5 and 20.6):

```bash
flutter build ipa --release --flavor prod \
  -t lib/main_prod.dart \
  --build-name=$VERSION_NAME \
  --build-number=$BUILD_NUMBER \
  --export-options-plist=ios/ExportOptions.plist
```

Output: `build/ios/ipa/Gatherli.ipa`

---

## CI API Key Install Step

The pipeline installs the `.p8` key before building:

```yaml
- name: Install App Store Connect API key
  run: |
    mkdir -p ~/.appstoreconnect/private_keys
    echo "${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}" | base64 --decode \
      > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}.p8
```

The `.p8` file is written to the standard location where `xcodebuild` and `xcrun altool`
expect to find it automatically.

---

## Upload Command

```bash
xcrun altool --upload-app \
  --type ios \
  --file "build/ios/ipa/Gatherli.ipa" \
  --apiKey ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }} \
  --apiIssuer ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
```

---

## Notes

- iOS builds require a **macOS runner** in GitHub Actions (`runs-on: macos-latest`)
- macOS runners are significantly more expensive than Linux — keep the job lean
- The `.p8` key file is in `.gitignore` and never committed
- `flutter build ipa` requires the `prod` flavor and `lib/main_prod.dart` entrypoint
