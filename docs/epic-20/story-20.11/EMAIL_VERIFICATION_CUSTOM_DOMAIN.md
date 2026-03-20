# Email Verification — Custom Domain Setup

**Epic:** 20 — Production Release
**Story:** 20.11 — Custom Domain Email Verification
**Status:** Complete

---

## Overview

This document covers the full configuration required to send Firebase Auth emails
(email verification, password reset) from `noreply@gatherli.org` with a branded
verification page, good deliverability, and correct app name display.

---

## 1. DNS Records (GoDaddy)

The following DNS records must be present on `gatherli.org`:

### MX — Receive email via ImprovMX (email forwarding)

| Type | Name | Value | Priority |
|------|------|-------|----------|
| MX | @ | mx1.improvmx.com. | 10 |
| MX | @ | mx2.improvmx.com. | 20 |

ImprovMX forwards emails received at `@gatherli.org` to a personal inbox.
Configure forwarding rules at [improvmx.com](https://improvmx.com).

### SPF — Authorise Firebase and ImprovMX to send on behalf of the domain

> **Critical:** only ONE SPF TXT record is allowed at `@`. Having two separate
> SPF records breaks SPF validation. Merge both senders into a single record.

| Type | Name | Value |
|------|------|-------|
| TXT | @ | `v=spf1 include:spf.improvmx.com include:_spf.firebasemail.com ~all` |

### DMARC — Policy for handling unauthenticated mail

| Type | Name | Value |
|------|------|-------|
| TXT | _dmarc | `v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;` |

`p=quarantine` sends suspicious emails to spam rather than rejecting them outright,
which is a safe starting policy.

### Firebase ownership verification

| Type | Name | Value |
|------|------|-------|
| TXT | @ | `firebase=gatherli-prod` |
| TXT | @ | `hosting-site=gatherli-prod` |

---

## 2. Firebase Auth — Custom Email Sender

**Path:** Firebase Console → Authentication → Templates → Edit any template → Sender

| Field | Value |
|-------|-------|
| Sender name | Gatherli |
| Sender email | noreply@gatherli.org |

This configures all Firebase Auth emails (verification, password reset, email change)
to appear as coming from `noreply@gatherli.org` rather than Firebase's default domain.

---

## 3. Firebase Auth — Custom Action URL

**Path:** Firebase Console → Authentication → Templates → Email address verification
→ Customize action URL

| Field | Value |
|-------|-------|
| Custom action URL | `https://gatherli.org/auth/action` |

This points the link inside every verification email to Gatherli's branded
verification page (see Section 5) instead of Firebase's default unstyled handler.

Apply the same custom action URL to the Password Reset and Email Address Change
templates.

---

## 4. Firebase Auth — Authorised Domains

**Path:** Firebase Console → Authentication → Settings → Authorised domains

Ensure `gatherli.org` is listed. If missing, add it. This allows Firebase to
issue action links and tokens for the custom domain.

---

## 5. Custom Email Action Handler Page

A branded HTML page is served at `https://gatherli.org/auth/action`.

**File:** `public/auth/action.html`

The page uses the Firebase JS SDK (loaded from CDN) and the Firebase Hosting
auto-config endpoint (`/__/firebase/init.json`) to avoid hardcoding API keys.

**Flow:**
1. User clicks the verification link in the email
2. Browser opens `https://gatherli.org/auth/action?mode=verifyEmail&oobCode=XXX`
3. The page reads `mode` and `oobCode` from the URL
4. Calls `applyActionCode(auth, oobCode)` to verify the email server-side
5. Shows a branded success screen with App Store / Google Play download links
6. On error (expired or already-used code) shows a friendly error message

**Supported modes:**
- `verifyEmail` — email address verification (primary use case)
- Others — shows a graceful fallback message

**Firebase Hosting rewrite** (`firebase.json`):
```json
{
  "source": "/auth/action",
  "destination": "/auth/action.html"
}
```

The `cleanUrls: true` setting in `firebase.json` means `auth/action.html` is
also accessible as `/auth/action` without the `.html` extension.

---

## 6. App Name in Email Templates (`%APP_NAME%`)

Firebase Auth email templates use `%APP_NAME%` which is populated from the
**OAuth consent screen app name**, not the Firebase project name.

### Steps to configure

1. Go to [Google Cloud Console](https://console.cloud.google.com) →
   select project `gatherli-prod`
2. Navigate to **APIs & Services → OAuth consent screen**
3. Set **Audience** to **External** (required for public apps)
4. Set **App name** to `Gatherli`
5. Set a support email (can use a Google account created with `admin@gatherli.org`)
6. Save

`%APP_NAME%` in all Firebase Auth email templates will now display `Gatherli`.

> **Note:** The Firebase project name (Project Settings → General) does NOT
> control `%APP_NAME%`. The OAuth consent screen app name is the authoritative
> source.

---

## 7. ImprovMX — Email Forwarding

ImprovMX is used to receive emails at `@gatherli.org` and forward them to a
personal inbox. This is separate from Firebase Auth email sending.

Configure forwarding aliases at [improvmx.com](https://improvmx.com):

| Alias | Forwards to |
|-------|------------|
| admin@gatherli.org | personal inbox |
| noreply@gatherli.org | personal inbox (optional, for bounce monitoring) |

---

## 8. Verification Checklist

Before considering this setup complete, verify:

- [ ] Verification email arrives in inbox (not spam)
- [ ] Sender shows `noreply@gatherli.org`
- [ ] Sign-off shows `The Gatherli team` (not `gatherli-prod`)
- [ ] Link points to `https://gatherli.org/auth/action`
- [ ] Clicking the link shows the branded verification page
- [ ] Verified successfully message appears after clicking
- [ ] SPF record is a single merged TXT record at `@`
- [ ] DMARC record exists at `_dmarc.gatherli.org`
- [ ] `gatherli.org` is in Firebase Auth authorised domains

---

## 9. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Email lands in spam | SPF misconfigured (two records) | Merge into one SPF TXT record |
| `%APP_NAME%` shows `gatherli-prod` | OAuth consent screen not configured | Set app name in Google Cloud Console → APIs & Services → OAuth consent screen |
| Link shows 404 basketball page | Action URL set to `/__/auth/action` (Firebase default, not custom page) | Set custom action URL to `https://gatherli.org/auth/action` |
| Verification page shows "already used" | Link clicked twice or expired | Expected behaviour — user must request a new email |
| Sender shows `noreply@gatherli-prod.firebaseapp.com` | Custom sender not configured in Auth templates | Set sender email in Authentication → Templates → Edit |
