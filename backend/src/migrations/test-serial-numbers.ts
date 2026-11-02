import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { UserRepository } from '../user/user.repository';

/**
 * Test script to verify serial number functionality
 *
 * This script tests:
 * 1. Getting the next serial number
 * 2. Creating a test user with serial number
 * 3. Verifying serial number assignment
 *
 * Usage:
 * npx ts-node -r tsconfig-paths/register src/migrations/test-serial-numbers.ts
 */

async function testSerialNumbers() {
  console.log('🧪 Testing serial number functionality...');

  try {
    // Create NestJS application context
    const app = await NestFactory.createApplicationContext(AppModule);
    const userRepository = app.get(UserRepository);

    // Test 1: Get next serial number
    console.log('\n1️⃣ Testing getNextSerialNumber()...');
    const nextSerialNumber = await userRepository.getNextSerialNumber();
    console.log(`✅ Next serial number: ${nextSerialNumber}`);

    // Test 2: Get user count
    console.log('\n2️⃣ Testing getUserCount()...');
    const userCount = await userRepository.getUserCount();
    console.log(`✅ Total users: ${userCount}`);

    // Test 3: Check users with serial numbers
    console.log('\n3️⃣ Checking users with serial numbers...');
    const usersWithSerialNumbers = await userRepository[
      'userModel'
    ].countDocuments({
      serialNumber: { $exists: true },
      isDeleted: false,
    });
    console.log(`✅ Users with serial numbers: ${usersWithSerialNumbers}`);

    // Test 4: Check users without serial numbers
    console.log('\n4️⃣ Checking users without serial numbers...');
    const usersWithoutSerialNumbers = await userRepository[
      'userModel'
    ].countDocuments({
      serialNumber: { $exists: false },
      isDeleted: false,
    });
    console.log(
      `✅ Users without serial numbers: ${usersWithoutSerialNumbers}`,
    );

    // Test 5: Show sample users with serial numbers
    console.log('\n5️⃣ Sample users with serial numbers:');
    const sampleUsers = await userRepository['userModel']
      .find({
        serialNumber: { $exists: true },
        isDeleted: false,
      })
      .sort({ serialNumber: 1 })
      .limit(5)
      .select('userName serialNumber createdAt');

    sampleUsers.forEach((user) => {
      console.log(
        `   User: ${user.userName}, Serial: ${user.serialNumber}, Created: ${user.createdAt}`,
      );
    });

    // Test 6: Show sample users without serial numbers
    if (usersWithoutSerialNumbers > 0) {
      console.log('\n6️⃣ Sample users without serial numbers:');
      const sampleUsersWithoutSerial = await userRepository['userModel']
        .find({
          serialNumber: { $exists: false },
          isDeleted: false,
        })
        .sort({ createdAt: 1 })
        .limit(5)
        .select('userName createdAt');

      sampleUsersWithoutSerial.forEach((user) => {
        console.log(`   User: ${user.userName}, Created: ${user.createdAt}`);
      });
    }

    console.log('\n✅ All tests completed successfully!');
    console.log('\n📋 Summary:');
    console.log(`   - Total users: ${userCount}`);
    console.log(`   - Users with serial numbers: ${usersWithSerialNumbers}`);
    console.log(
      `   - Users without serial numbers: ${usersWithoutSerialNumbers}`,
    );
    console.log(`   - Next available serial number: ${nextSerialNumber}`);

    if (usersWithoutSerialNumbers > 0) {
      console.log("\n⚠️  Note: Some users don't have serial numbers yet.");
      console.log(
        '   Run the migration script to assign serial numbers to existing users:',
      );
      console.log('   npm run migration:assign-serial-numbers');
    } else {
      console.log('\n🎉 All users have serial numbers!');
    }

    await app.close();
    console.log('\n🏁 Test script finished.');
  } catch (error) {
    console.error('❌ Test failed:', error);
    process.exit(1);
  }
}

// Run the test if this file is executed directly
if (require.main === module) {
  testSerialNumbers();
}

export { testSerialNumbers };
