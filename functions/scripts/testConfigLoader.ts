/**
 * Test Configuration Loader
 *
 * Helper module to load test user IDs and configuration from testConfig.json
 * Use this in other scripts to access test user data instead of hardcoding UIDs.
 *
 * Usage:
 *   import { loadTestConfig, getTestUser, getAllTestUserIds } from './testConfigLoader';
 *
 *   const alice = getTestUser(0); // Get first user (Alice)
 *   const allUserIds = getAllTestUserIds();
 *   const groupId = getTestGroupId();
 */

import * as fs from "fs";
import * as path from "path";

export interface TestUser {
  index: number;
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
  password: string;
}

export interface TestConfig {
  timestamp: string;
  users: TestUser[];
  groupId: string;
  gameIds: string[];
  notes: {
    password: string;
    friendships: string;
    group: string;
    games: string;
  };
}

/**
 * Load test configuration from testConfig.json
 */
export function loadTestConfig(): TestConfig {
  const configPath = path.join(__dirname, "testConfig.json");

  if (!fs.existsSync(configPath)) {
    throw new Error(
      `❌ Test config not found at ${configPath}.\n\n` +
        `   Please run setupTestEnvironment.ts first:\n` +
        `   cd functions\n` +
        `   npx ts-node scripts/setupTestEnvironment.ts\n`
    );
  }

  const configContent = fs.readFileSync(configPath, "utf-8");
  const config = JSON.parse(configContent) as TestConfig;

  return config;
}

/**
 * Get a test user by index (0-9)
 *
 * @param index User index (0 = Alice, 1 = Bob, etc.)
 */
export function getTestUser(index: number): TestUser {
  const config = loadTestConfig();

  if (index < 0 || index >= config.users.length) {
    throw new Error(
      `Invalid user index ${index}. Must be between 0 and ${config.users.length - 1}`
    );
  }

  return config.users[index];
}

/**
 * Get a test user by email
 */
export function getTestUserByEmail(email: string): TestUser | undefined {
  const config = loadTestConfig();
  return config.users.find((u) => u.email === email);
}

/**
 * Get a test user by display name
 */
export function getTestUserByName(displayName: string): TestUser | undefined {
  const config = loadTestConfig();
  return config.users.find((u) => u.displayName === displayName);
}

/**
 * Get all test user IDs
 */
export function getAllTestUserIds(): string[] {
  const config = loadTestConfig();
  return config.users.map((u) => u.uid);
}

/**
 * Get test group ID
 */
export function getTestGroupId(): string {
  const config = loadTestConfig();
  return config.groupId;
}

/**
 * Get test game IDs
 */
export function getTestGameIds(): string[] {
  const config = loadTestConfig();
  return config.gameIds;
}

/**
 * Print test configuration summary to console
 */
export function printTestConfig(): void {
  const config = loadTestConfig();

  console.log("\n" + "=".repeat(70));
  console.log("📋 TEST CONFIGURATION");
  console.log("=".repeat(70));
  console.log(`\nGenerated: ${new Date(config.timestamp).toLocaleString()}`);
  console.log(`\n👤 Test Users (${config.users.length}):`);

  config.users.forEach((user) => {
    console.log(
      `  ${user.index + 1}. ${user.displayName.padEnd(20)} ${user.email.padEnd(25)} ${user.uid}`
    );
  });

  console.log(`\n🏐 Group ID: ${config.groupId}`);
  console.log(`\n🎮 Game IDs (${config.gameIds.length}):`);
  config.gameIds.forEach((gameId, i) => {
    console.log(`  ${i + 1}. ${gameId}`);
  });

  console.log(`\n📝 Notes:`);
  console.log(`  Password: ${config.notes.password}`);
  console.log(`  Friendships: ${config.notes.friendships}`);
  console.log(`  Group: ${config.notes.group}`);
  console.log(`  Games: ${config.notes.games}`);
  console.log("\n" + "=".repeat(70) + "\n");
}

/**
 * Generate a code snippet with the current user IDs
 * Useful for copying into other scripts
 */
export function printUserIdSnippet(): void {
  const config = loadTestConfig();

  console.log("\n// Copy these user IDs into your script:");
  console.log(`const groupId = "${config.groupId}";`);
  config.users.forEach((user, i) => {
    console.log(
      `const ${user.firstName.toLowerCase()}_uid = "${user.uid}"; // ${user.displayName}`
    );
  });
  console.log();
}
