1. Check function is actually deployed:
  firebase functions:list --project playwithme-dev
  # Should show: searchUserByEmail | callable | us-central1
2. Check function logs for errors:
  firebase functions:log --project playwithme-dev