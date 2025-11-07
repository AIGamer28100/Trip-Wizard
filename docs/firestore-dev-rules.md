## Dev Firestore rules and how to use them

This project contains Firestore rules at `firestore.rules` that are scoped
to user ownership and trip membership. These rules are stricter than a
completely permissive dev file: they prevent users from reading or writing
another user's private data (credits, badges, billing) and ensure trip-
scoped collections (trips, itinerary_items, bookings) are only accessible
to trip members.

What the file does

- Allows read and write to all documents only when the user is authenticated.

Two ways to use these rules:

1. Run the Firebase Emulator (recommended for local dev)

Prereqs: install the Firebase CLI and initialize emulators for your project.

```bash
# install (if needed)
npm install -g firebase-tools

# from the repo root (optional) initialize firebase if not done already:
# firebase init firestore

# Start the emulator (it will pick up firestore.rules by default if you
# configured firebase.json during init)
firebase emulators:start --only firestore
```

While the emulator runs, your app can be pointed at the emulator and will
enforce `firestore.rules` locally. The rules in the repo restrict access
based on `request.auth.uid` and trip `memberIds`.

1. Deploy these rules to a development Firebase project

WARNING: Only deploy to a non-production project. Make sure you understand
the security implications.

```bash
# login and select project
firebase login
firebase use --add

# If you don't have a firebase.json configured, create one and point to the rules file:
cat > firebase.json <<'JSON'
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
JSON

# Deploy the rules to the selected project
firebase deploy --only firestore
```

### Recommended follow-ups

- Review `firestore.rules` and adapt for your production security model.
- Consider adding additional server-side validation or Cloud Functions for
  sensitive operations (awarding badges, moderation, billing webhooks) so
  these actions are performed under Admin privileges rather than the client.
- Consider configuring the Firebase Emulator UI for easier inspection.
