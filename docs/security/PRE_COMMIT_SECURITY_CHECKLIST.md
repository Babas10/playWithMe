# Pre-Commit Security Checklist

## 🚨 CRITICAL: Always Check Before Committing

This checklist MUST be verified before EVERY commit. NO EXCEPTIONS.

### 1. Environment Files Check
```bash
# Check for .env files
git status | grep -E "\.env"

# If ANY .env files appear, STOP and verify .gitignore
```

**Action if .env files detected:**
- ❌ DO NOT COMMIT
- Verify `.gitignore` includes `.env` patterns
- Remove files from staging: `git reset .env*`

### 2. API Keys and Secrets Check
```bash
# Scan staged files for potential secrets
git diff --cached | grep -iE "(api[_-]?key|secret|password|token|credential)"
```

**Action if secrets detected:**
- ❌ DO NOT COMMIT
- Move secrets to environment variables
- Use GitHub Secrets for CI/CD
- Update `.gitignore` if needed

### 3. Firebase Configuration Check
```bash
# Verify Firebase configs are NOT staged
git status | grep -E "(google-services\.json|GoogleService-Info\.plist|firebase_config_.*\.dart)"
```

**Action if Firebase configs detected:**
- ❌ DO NOT COMMIT
- Run: `git reset android/app/src/*/google-services.json ios/Runner/Firebase/*/GoogleService-Info.plist`
- Verify `.gitignore` rules are correct

### 4. Credentials Files Check
```bash
# Check for credential files
git status | grep -iE "(credentials|service-account|.*-key\.json)"
```

**Action if credentials detected:**
- ❌ DO NOT COMMIT
- Remove from staging
- Add to `.gitignore`

## 🛡️ Prevention Strategy

### Always Use This Pre-Commit Command:
```bash
# Run BEFORE every commit
git diff --cached --name-only | grep -iE "(\.env|credentials|secret|key\.json|google-services)"
```

If this returns ANY results, STOP and investigate.

### Automated Protection (Recommended)
Install a pre-commit hook:

```bash
# Create .git/hooks/pre-commit
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Check for sensitive files
SENSITIVE_PATTERNS="\.env|credentials|secret|key\.json|google-services|GoogleService-Info"

STAGED_FILES=$(git diff --cached --name-only)

if echo "$STAGED_FILES" | grep -qiE "$SENSITIVE_PATTERNS"; then
    echo "🚨 ERROR: Sensitive files detected in commit!"
    echo "$STAGED_FILES" | grep -iE "$SENSITIVE_PATTERNS"
    echo ""
    echo "Please remove these files from staging and update .gitignore"
    exit 1
fi

exit 0
EOF

chmod +x .git/hooks/pre-commit
```

## 📋 What Should Be in .gitignore

### Environment Variables:
```
.env
.env.*
*.env
**/.env
**/.env.*
```

### Credentials:
```
**/credentials.json
**/service-account*.json
**/*-key.json
**/*_key.json
**/secrets.json
```

### Firebase:
```
.firebase_projects.json
android/app/src/*/google-services.json
ios/Runner/Firebase/*/GoogleService-Info.plist
lib/core/config/firebase_config_*.dart
```

## 🚨 If Secrets Are Already Committed

1. **STOP immediately** - Don't make more commits
2. **Rotate ALL leaked credentials** immediately
3. **Remove from Git history:**
   ```bash
   # Use git-filter-repo (preferred) or BFG Repo-Cleaner
   git filter-repo --path .env --invert-paths
   ```
4. **Force push** (ONLY after team coordination):
   ```bash
   git push --force-with-lease
   ```
5. **Verify** secrets are removed from all branches

## 📚 Reference
See [FIREBASE_CONFIG_SECURITY.md](./FIREBASE_CONFIG_SECURITY.md) for Firebase-specific security guidelines.
