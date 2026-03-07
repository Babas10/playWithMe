1. Check function is actually deployed:
  firebase functions:list --project gatherli-dev
  # Should show: searchUserByEmail | callable | us-central1
2. Check function logs for errors:
  firebase functions:log --project gatherli-dev