#!/usr/bin/env python3
"""
Submit an existing App Store Connect build for App Store review.

The build is assumed to already be in App Store Connect (uploaded during the
beta TestFlight pipeline). This script finds it by iOS version string and
submits it for review — no re-upload required.

Required environment variables:
  ASC_KEY_ID       — App Store Connect API key ID
  ASC_ISSUER_ID    — App Store Connect API issuer ID
  ASC_KEY_PATH     — Path to the .p8 private key file
  ASC_APP_ID       — Numeric Apple app ID (from App Store Connect)
  ASC_IOS_VERSION  — iOS version string, e.g. "0.7.1" (no beta suffix)
"""

import sys
import os
import time
import json
import urllib.request
import urllib.error
import jwt  # PyJWT


def main():
    key_id = os.environ["ASC_KEY_ID"]
    issuer_id = os.environ["ASC_ISSUER_ID"]
    app_id = os.environ["ASC_APP_ID"]
    key_path = os.path.expanduser(os.environ["ASC_KEY_PATH"])
    ios_version = os.environ["ASC_IOS_VERSION"]

    with open(key_path) as f:
        private_key = f.read()

    token = jwt.encode(
        {"iss": issuer_id, "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": key_id},
    )

    def api(method, path, data=None):
        url = f"https://api.appstoreconnect.apple.com{path}"
        body = json.dumps(data).encode() if data else None
        req = urllib.request.Request(
            url,
            data=body,
            method=method,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req) as r:
                content = r.read()
                return json.loads(content) if content else {}
        except urllib.error.HTTPError as e:
            content = e.read().decode()
            print(f"HTTP {e.code}: {content}", file=sys.stderr)
            raise

    # 1. Find the most recently uploaded valid build for this iOS version
    print(f"Looking for valid build with iOS version {ios_version}...")
    builds = api(
        "GET",
        f"/v1/builds"
        f"?filter[app]={app_id}"
        f"&filter[preReleaseVersion.version]={ios_version}"
        f"&filter[processingState]=VALID"
        f"&sort=-uploadedDate"
        f"&limit=1"
        f"&fields[builds]=id,version,processingState,uploadedDate",
    )
    if not builds.get("data"):
        print(
            f"ERROR: No valid build found in ASC for iOS version {ios_version}",
            file=sys.stderr,
        )
        print(
            "Make sure the beta TestFlight upload completed and build processing finished.",
            file=sys.stderr,
        )
        sys.exit(1)
    build_id = builds["data"][0]["id"]
    print(f"Found build: {build_id}")

    # 2. Find or create the App Store version entry
    versions = api(
        "GET",
        f"/v1/apps/{app_id}/appStoreVersions"
        f"?filter[versionString]={ios_version}"
        f"&filter[platform]=IOS",
    )
    if versions.get("data"):
        version_id = versions["data"][0]["id"]
        print(f"Using existing App Store version: {version_id}")
    else:
        print("Creating App Store version entry...")
        new_ver = api(
            "POST",
            "/v1/appStoreVersions",
            {
                "data": {
                    "type": "appStoreVersions",
                    "attributes": {
                        "versionString": ios_version,
                        "releaseType": "MANUAL",
                        "platform": "IOS",
                    },
                    "relationships": {
                        "app": {"data": {"type": "apps", "id": app_id}}
                    },
                }
            },
        )
        version_id = new_ver["data"]["id"]
        print(f"Created App Store version: {version_id}")

    # 3. Attach the build to the App Store version
    print("Attaching build to App Store version...")
    api(
        "PATCH",
        f"/v1/appStoreVersions/{version_id}",
        {
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "relationships": {
                    "build": {"data": {"type": "builds", "id": build_id}}
                },
            }
        },
    )

    # 4. Submit for App Store review
    print("Submitting for App Store review...")
    api(
        "POST",
        "/v1/appStoreVersionSubmissions",
        {
            "data": {
                "type": "appStoreVersionSubmissions",
                "relationships": {
                    "appStoreVersion": {
                        "data": {"type": "appStoreVersions", "id": version_id}
                    }
                },
            }
        },
    )

    print(f"✅ iOS v{ios_version} (build {build_id}) submitted for App Store review!")


if __name__ == "__main__":
    main()
