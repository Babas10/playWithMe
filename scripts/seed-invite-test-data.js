// Seed script for Epic 17 invite flow testing with Firebase Emulators.
// Creates test users, a group, and invite tokens ready for deep link testing.
//
// Prerequisites:
//   firebase emulators:start --only auth,firestore,functions --project playwithme-dev
//
// Usage:
//   node scripts/seed-invite-test-data.js
//
// After running, use the printed deep link URLs with:
//   iOS Simulator:  xcrun simctl openurl booted "playwithme://invite/<token>"
//   Android Emulator: adb shell am start -a android.intent.action.VIEW -d "playwithme://invite/<token>" -c android.intent.category.BROWSABLE

const admin = require("firebase-admin");
const crypto = require("crypto");

// --- Configuration ---
const EMULATOR_HOST = "127.0.0.1";
const AUTH_PORT = 9099;
const FIRESTORE_PORT = 8080;
const PROJECT_ID = "playwithme-dev";

// Point Admin SDK at emulators
process.env.FIREBASE_AUTH_EMULATOR_HOST = `${EMULATOR_HOST}:${AUTH_PORT}`;
process.env.FIRESTORE_EMULATOR_HOST = `${EMULATOR_HOST}:${FIRESTORE_PORT}`;

admin.initializeApp({ projectId: PROJECT_ID });

const db = admin.firestore();
const auth = admin.auth();

// --- Test Data Definitions ---

const TEST_USERS = [
  {
    uid: "user-alice",
    email: "alice@test.com",
    password: "Test1234!",
    displayName: "Alice (Group Creator)",
  },
  {
    uid: "user-bob",
    email: "bob@test.com",
    password: "Test1234!",
    displayName: "Bob (Existing Member)",
  },
  // Charlie is intentionally NOT pre-created — use this for the
  // "unauthenticated user clicks invite link" flow (Story 17.7).
];

const GROUP_ID = "group-beach-test";
const GROUP_DATA = {
  name: "Beach Volleyball Crew",
  description: "Weekend beach volleyball sessions",
  photoUrl: null,
  createdBy: "user-alice",
  memberIds: ["user-alice", "user-bob"],
  adminIds: ["user-alice"],
  maxMembers: 20,
  allowMembersToInviteOthers: true,
  lastActivity: admin.firestore.FieldValue.serverTimestamp(),
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
};

// We create multiple invite scenarios
function buildInvites() {
  const now = Date.now();
  return [
    {
      id: "invite-valid",
      token: crypto.randomBytes(24).toString("base64url"),
      label: "Valid invite (no limits)",
      data: {
        createdBy: "user-alice",
        createdAt: admin.firestore.Timestamp.fromDate(new Date(now)),
        expiresAt: null,
        revoked: false,
        usageLimit: null,
        usageCount: 0,
        groupId: GROUP_ID,
        inviteType: "group_link",
      },
    },
    {
      id: "invite-limited",
      token: crypto.randomBytes(24).toString("base64url"),
      label: "Usage-limited invite (3 max, 2 used)",
      data: {
        createdBy: "user-alice",
        createdAt: admin.firestore.Timestamp.fromDate(new Date(now)),
        expiresAt: null,
        revoked: false,
        usageLimit: 3,
        usageCount: 2,
        groupId: GROUP_ID,
        inviteType: "group_link",
      },
    },
    {
      id: "invite-exhausted",
      token: crypto.randomBytes(24).toString("base64url"),
      label: "Exhausted invite (limit reached)",
      data: {
        createdBy: "user-alice",
        createdAt: admin.firestore.Timestamp.fromDate(new Date(now)),
        expiresAt: null,
        revoked: false,
        usageLimit: 1,
        usageCount: 1,
        groupId: GROUP_ID,
        inviteType: "group_link",
      },
    },
    {
      id: "invite-expired",
      token: crypto.randomBytes(24).toString("base64url"),
      label: "Expired invite",
      data: {
        createdBy: "user-alice",
        createdAt: admin.firestore.Timestamp.fromDate(
          new Date(now - 48 * 60 * 60 * 1000)
        ),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(now - 24 * 60 * 60 * 1000)
        ),
        revoked: false,
        usageLimit: null,
        usageCount: 0,
        groupId: GROUP_ID,
        inviteType: "group_link",
      },
    },
    {
      id: "invite-revoked",
      token: crypto.randomBytes(24).toString("base64url"),
      label: "Revoked invite",
      data: {
        createdBy: "user-alice",
        createdAt: admin.firestore.Timestamp.fromDate(new Date(now)),
        expiresAt: null,
        revoked: true,
        usageLimit: null,
        usageCount: 5,
        groupId: GROUP_ID,
        inviteType: "group_link",
      },
    },
  ];
}

// --- Seed Functions ---

async function createTestUsers() {
  console.log("\n--- Creating test users ---");
  for (const user of TEST_USERS) {
    try {
      await auth.createUser({
        uid: user.uid,
        email: user.email,
        password: user.password,
        displayName: user.displayName,
        emailVerified: true,
      });
      console.log(`  + Auth: ${user.displayName} (${user.email})`);
    } catch (e) {
      if (e.code === "auth/uid-already-exists") {
        console.log(`  ~ Auth: ${user.displayName} already exists, skipping`);
      } else {
        throw e;
      }
    }

    // Create matching Firestore user profile
    await db.collection("users").doc(user.uid).set({
      email: user.email,
      displayName: user.displayName,
      photoUrl: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`  + Firestore profile: /users/${user.uid}`);
  }
}

async function createTestGroup() {
  console.log("\n--- Creating test group ---");
  await db.collection("groups").doc(GROUP_ID).set(GROUP_DATA);
  console.log(`  + Group: /groups/${GROUP_ID} — "${GROUP_DATA.name}"`);
  console.log(`    Members: ${GROUP_DATA.memberIds.join(", ")}`);
}

async function createTestInvites(invites) {
  console.log("\n--- Creating test invites ---");
  const batch = db.batch();

  for (const invite of invites) {
    // Invite document under the group
    const inviteRef = db
      .collection("groups")
      .doc(GROUP_ID)
      .collection("invites")
      .doc(invite.id);

    batch.set(inviteRef, { ...invite.data, token: invite.token });

    // Token lookup document (top-level)
    const tokenRef = db.collection("invite_tokens").doc(invite.token);
    batch.set(tokenRef, {
      groupId: GROUP_ID,
      inviteId: invite.id,
      createdAt: invite.data.createdAt,
      active: !invite.data.revoked,
    });
  }

  await batch.commit();

  for (const invite of invites) {
    console.log(`  + ${invite.label}`);
    console.log(`    ID: ${invite.id}`);
    console.log(`    Token: ${invite.token}`);
  }
}

function printTestingGuide(invites) {
  const valid = invites.find((i) => i.id === "invite-valid");
  const limited = invites.find((i) => i.id === "invite-limited");
  const exhausted = invites.find((i) => i.id === "invite-exhausted");
  const expired = invites.find((i) => i.id === "invite-expired");
  const revoked = invites.find((i) => i.id === "invite-revoked");

  console.log("\n=============================================");
  console.log("  TESTING GUIDE");
  console.log("=============================================");

  console.log("\n-- Deep Link URLs (custom scheme) --\n");
  for (const invite of invites) {
    console.log(`${invite.label}:`);
    console.log(`  playwithme://invite/${invite.token}\n`);
  }

  console.log("-- Deep Link URLs (https) --\n");
  for (const invite of invites) {
    console.log(`${invite.label}:`);
    console.log(`  https://playwithme.app/invite/${invite.token}\n`);
  }

  console.log("=============================================");
  console.log("  PLATFORM COMMANDS");
  console.log("=============================================");

  console.log("\n-- iOS Simulator --\n");
  console.log(
    `  xcrun simctl openurl booted "playwithme://invite/${valid.token}"`
  );

  console.log("\n-- Android Emulator --\n");
  console.log(
    `  adb shell am start -a android.intent.action.VIEW \\`
  );
  console.log(
    `    -d "playwithme://invite/${valid.token}" \\`
  );
  console.log(`    -c android.intent.category.BROWSABLE`);

  console.log("\n-- Real iPhone --\n");
  console.log(
    `  Send yourself this link via iMessage/Notes and tap it:`
  );
  console.log(`  playwithme://invite/${valid.token}`);

  console.log("\n=============================================");
  console.log("  TEST SCENARIOS");
  console.log("=============================================");

  console.log(`
1. AUTHENTICATED USER — NEW MEMBER (Happy path)
   - Log in as Alice (alice@test.com / Test1234!)
   - Log out
   - Log in as Bob (bob@test.com / Test1234!)
   - Create a second group, generate an invite from that group
   - Log out, log in as Alice
   - Open the invite deep link
   - Expected: JoinGroupConfirmationPage -> tap Join -> success

2. AUTHENTICATED USER — ALREADY A MEMBER (Idempotent)
   - Log in as Bob (bob@test.com / Test1234!)
   - Open: playwithme://invite/${valid.token}
   - Expected: "You're already a member" message

3. UNAUTHENTICATED USER — NEW ACCOUNT (Story 17.7)
   - Make sure you are logged out
   - Open: playwithme://invite/${valid.token}
   - Expected: InviteOnboardingPage with group info
   - Tap "Create Account" -> fill form -> auto-join group

4. EXPIRED INVITE
   - Open: playwithme://invite/${expired.token}
   - Expected: Error — invite has expired

5. REVOKED INVITE
   - Open: playwithme://invite/${revoked.token}
   - Expected: Error — invite has been revoked

6. EXHAUSTED INVITE (usage limit reached)
   - Open: playwithme://invite/${exhausted.token}
   - Expected: Error — usage limit reached

7. USAGE-LIMITED INVITE (still has room)
   - Log out, open: playwithme://invite/${limited.token}
   - Expected: Normal join flow (2/3 uses consumed)

8. INVALID TOKEN
   - Open: playwithme://invite/this-token-does-not-exist
   - Expected: Error — invalid token

9. GENERATE INVITE FROM UI (Story 17.4)
   - Log in as Alice
   - Go to "Beach Volleyball Crew" group
   - Tap "Generate Invite Link"
   - Share/copy the generated link
   - Verify the link works for another user
`);

  console.log("=============================================");
  console.log("  TEST ACCOUNTS");
  console.log("=============================================");
  console.log(`
  Alice (group creator & admin):
    Email:    alice@test.com
    Password: Test1234!
    UID:      user-alice

  Bob (existing member):
    Email:    bob@test.com
    Password: Test1234!
    UID:      user-bob

  Charlie (not pre-created — for registration flow):
    Use any new email during the invite onboarding flow
`);

  console.log("=============================================");
  console.log("  EMULATOR UI");
  console.log("=============================================");
  console.log(`
  Dashboard:  http://${EMULATOR_HOST}:4000
  Auth:       http://${EMULATOR_HOST}:4000/auth
  Firestore:  http://${EMULATOR_HOST}:4000/firestore
`);
}

// --- Main ---

async function main() {
  console.log("====================================================");
  console.log("  Epic 17 — Invite Flow Test Data Seeder");
  console.log("  Target: Firebase Emulators (playwithme-dev)");
  console.log("====================================================");

  const invites = buildInvites();

  await createTestUsers();
  await createTestGroup();
  await createTestInvites(invites);

  printTestingGuide(invites);

  console.log("\nSeed complete.\n");
  process.exit(0);
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
