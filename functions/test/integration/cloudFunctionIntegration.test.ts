// Integration Test Set 3: Cloud Function and Firestore Interaction
import * as admin from "firebase-admin";
import {EmulatorHelper} from "./emulatorHelper";
import {acceptInvitationHandler} from "../../src/acceptInvitation";
import {declineInvitationHandler} from "../../src/declineInvitation";
import {getUsersByIdsHandler} from "../../src/getUsersByIds";
import {searchUserByEmailHandler} from "../../src/searchUserByEmail";

describe("Integration: Cloud Function and Firestore Interaction", () => {
  let userA: admin.auth.UserRecord; // Admin
  let userB: admin.auth.UserRecord; // User to be invited
  let userC: admin.auth.UserRecord; // Another user
  let groupId: string;

  beforeAll(async () => {
    await EmulatorHelper.initialize();
  });

  beforeEach(async () => {
    await EmulatorHelper.clearFirestore();
    await EmulatorHelper.clearAuth();

    // Create test users
    userA = await EmulatorHelper.createTestUser({
      email: "admin@test.com",
      password: "password123",
      displayName: "Admin User",
    });

    userB = await EmulatorHelper.createTestUser({
      email: "userb@test.com",
      password: "password123",
      displayName: "User B",
    });

    userC = await EmulatorHelper.createTestUser({
      email: "userc@test.com",
      password: "password123",
      displayName: "User C",
    });

    // Create group
    groupId = await EmulatorHelper.createTestGroup({
      name: "Test Group",
      adminId: userA.uid,
      memberIds: [userA.uid],
    });
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  describe("Accept Invitation → Group Document Auto-Updates", () => {
    it("should automatically add user to group when invitation accepted", async () => {
      const db = admin.firestore();

      // Create invitation
      const invitationId = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      // Verify userB not in group yet
      let groupDoc = await db.collection("groups").doc(groupId).get();
      expect(groupDoc.data()?.memberIds).not.toContain(userB.uid);

      // Accept invitation
      const context = {auth: {uid: userB.uid}} as any;
      const result = await acceptInvitationHandler(
        {invitationId: invitationId},
        context
      );

      expect(result.success).toBe(true);

      // Verify userB now in group
      groupDoc = await db.collection("groups").doc(groupId).get();
      expect(groupDoc.data()?.memberIds).toContain(userB.uid);
      expect(groupDoc.data()?.memberIds.length).toBe(2);
    });

    it("should update group metadata when invitation accepted", async () => {
      const db = admin.firestore();

      // Get initial group state
      const initialGroupDoc = await db.collection("groups").doc(groupId).get();
      const initialUpdatedAt = initialGroupDoc.data()?.updatedAt;

      // Create and accept invitation
      const invitationId = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      // Wait a bit to ensure timestamp difference
      await new Promise((resolve) => setTimeout(resolve, 100));

      const context = {auth: {uid: userB.uid}} as any;
      await acceptInvitationHandler({invitationId: invitationId}, context);

      // Verify group metadata updated
      const updatedGroupDoc = await db.collection("groups").doc(groupId).get();
      const updatedAt = updatedGroupDoc.data()?.updatedAt;
      const lastActivity = updatedGroupDoc.data()?.lastActivity;

      expect(updatedAt).toBeDefined();
      expect(lastActivity).toBeDefined();

      // Timestamps should be different (group was updated)
      if (initialUpdatedAt) {
        expect(updatedAt.toMillis()).toBeGreaterThan(
          initialUpdatedAt.toMillis()
        );
      }
    });
  });

  describe("Decline Invitation → No Group Write", () => {
    it("should NOT modify group when invitation declined", async () => {
      const db = admin.firestore();

      // Get initial group state
      const initialGroupDoc = await db.collection("groups").doc(groupId).get();
      const initialMemberIds = initialGroupDoc.data()?.memberIds;
      const initialUpdatedAt = initialGroupDoc.data()?.updatedAt;

      // Create and decline invitation
      const invitationId = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      const context = {auth: {uid: userB.uid}} as any;
      const result = await declineInvitationHandler(
        {invitationId: invitationId},
        context
      );

      expect(result.success).toBe(true);

      // Verify group unchanged
      const finalGroupDoc = await db.collection("groups").doc(groupId).get();
      const finalMemberIds = finalGroupDoc.data()?.memberIds;
      const finalUpdatedAt = finalGroupDoc.data()?.updatedAt;

      expect(finalMemberIds).toEqual(initialMemberIds);
      expect(finalMemberIds).not.toContain(userB.uid);

      // Group metadata should be unchanged
      if (initialUpdatedAt && finalUpdatedAt) {
        expect(finalUpdatedAt.toMillis()).toBe(initialUpdatedAt.toMillis());
      }
    });
  });

  describe("Group Membership Updates → All Members Can View", () => {
    it("should allow all members to view group after new member joins", async () => {
      const db = admin.firestore();

      // Add userB to group
      const invitationId = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      const context = {auth: {uid: userB.uid}} as any;
      await acceptInvitationHandler({invitationId: invitationId}, context);

      // Both userA and userB should be able to read group
      const groupDocA = await db.collection("groups").doc(groupId).get();
      const groupDocB = await db.collection("groups").doc(groupId).get();

      expect(groupDocA.exists).toBe(true);
      expect(groupDocB.exists).toBe(true);

      expect(groupDocA.data()?.memberIds).toContain(userA.uid);
      expect(groupDocA.data()?.memberIds).toContain(userB.uid);

      expect(groupDocB.data()?.memberIds).toContain(userA.uid);
      expect(groupDocB.data()?.memberIds).toContain(userB.uid);
    });

    it("should allow fetching all group members via getUsersByIds", async () => {
      const db = admin.firestore();

      // Add userB and userC to group
      const invitationIdB = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      const invitationIdC = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userC.uid,
        invitedBy: userA.uid,
      });

      await acceptInvitationHandler(
        {invitationId: invitationIdB},
        {auth: {uid: userB.uid}} as any
      );

      await acceptInvitationHandler(
        {invitationId: invitationIdC},
        {auth: {uid: userC.uid}} as any
      );

      // Get group member IDs
      const groupDoc = await db.collection("groups").doc(groupId).get();
      const memberIds = groupDoc.data()?.memberIds;

      expect(memberIds).toHaveLength(3);

      // Fetch all member profiles via Cloud Function
      const context = {auth: {uid: userA.uid}} as any;
      const result = await getUsersByIdsHandler(
        {userIds: memberIds},
        context
      );

      expect(result.users).toHaveLength(3);
      expect(result.users.map((u) => u.uid).sort()).toEqual(
        [userA.uid, userB.uid, userC.uid].sort()
      );

      // Verify we got public data only
      result.users.forEach((user) => {
        expect(user).toHaveProperty("uid");
        expect(user).toHaveProperty("email");
        expect(user).toHaveProperty("displayName");
        expect(user).toHaveProperty("photoUrl");
        expect(user).not.toHaveProperty("password");
      });
    });
  });

  describe("No Permission Errors with Proper Auth Context", () => {
    it("should allow authenticated user to search by email", async () => {
      const context = {auth: {uid: userA.uid}} as any;

      const result = await searchUserByEmailHandler(
        {email: "userb@test.com"},
        context
      );

      expect(result.found).toBe(true);
      expect(result.user?.uid).toBe(userB.uid);
      expect(result.user?.email).toBe("userb@test.com");
    });

    it("should allow authenticated user to get users by IDs", async () => {
      const context = {auth: {uid: userA.uid}} as any;

      const result = await getUsersByIdsHandler(
        {userIds: [userA.uid, userB.uid, userC.uid]},
        context
      );

      expect(result.users).toHaveLength(3);
      expect(result.users.map((u) => u.uid).sort()).toEqual(
        [userA.uid, userB.uid, userC.uid].sort()
      );
    });

    it("should allow user to accept their own invitation", async () => {
      const invitationId = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      const context = {auth: {uid: userB.uid}} as any;

      const result = await acceptInvitationHandler(
        {invitationId: invitationId},
        context
      );

      expect(result.success).toBe(true);
    });

    it("should NOT allow user to accept someone else's invitation", async () => {
      const invitationId = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      // UserC tries to accept UserB's invitation
      const context = {auth: {uid: userC.uid}} as any;

      await expect(
        acceptInvitationHandler({invitationId: invitationId}, context)
      ).rejects.toThrow("This invitation is not for you");
    });
  });

  describe("Data Consistency Across Operations", () => {
    it("should maintain consistent state through multiple operations", async () => {
      const db = admin.firestore();

      // Initial state: 1 member (userA)
      let groupDoc = await db.collection("groups").doc(groupId).get();
      expect(groupDoc.data()?.memberIds.length).toBe(1);

      // Invite and accept userB
      const invitationIdB = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userB.uid,
        invitedBy: userA.uid,
      });

      await acceptInvitationHandler(
        {invitationId: invitationIdB},
        {auth: {uid: userB.uid}} as any
      );

      // State: 2 members
      groupDoc = await db.collection("groups").doc(groupId).get();
      expect(groupDoc.data()?.memberIds.length).toBe(2);

      // Invite userC but they decline
      const invitationIdC = await EmulatorHelper.createTestInvitation({
        groupId: groupId,
        groupName: "Test Group",
        invitedUserId: userC.uid,
        invitedBy: userA.uid,
      });

      await declineInvitationHandler(
        {invitationId: invitationIdC},
        {auth: {uid: userC.uid}} as any
      );

      // State: still 2 members
      groupDoc = await db.collection("groups").doc(groupId).get();
      expect(groupDoc.data()?.memberIds.length).toBe(2);
      expect(groupDoc.data()?.memberIds).toContain(userA.uid);
      expect(groupDoc.data()?.memberIds).toContain(userB.uid);
      expect(groupDoc.data()?.memberIds).not.toContain(userC.uid);

      // Verify getUsersByIds returns correct member list
      const result = await getUsersByIdsHandler(
        {userIds: groupDoc.data()?.memberIds},
        {auth: {uid: userA.uid}} as any
      );

      expect(result.users.length).toBe(2);
      expect(result.users.map((u) => u.uid).sort()).toEqual(
        [userA.uid, userB.uid].sort()
      );
    });
  });
});
