/**
 * Show Test Configuration
 *
 * Display the current test configuration loaded from testConfig.json
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/showTestConfig.ts
 */

import { printTestConfig, printUserIdSnippet } from "./testConfigLoader";

try {
  printTestConfig();
  printUserIdSnippet();
} catch (error: any) {
  console.error("\n❌ Error loading test configuration:", error.message);
  console.log(
    "\n💡 Tip: Run setupTestEnvironment.ts first to generate test data:\n"
  );
  console.log("   cd functions");
  console.log("   npx ts-node scripts/setupTestEnvironment.ts\n");
  process.exit(1);
}
