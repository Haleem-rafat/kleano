import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { UserRepository } from '../user/user.repository';

/**
 * Migration script to assign serial numbers to existing users
 *
 * This script should be run once to assign serial numbers to all existing users
 * who don't have one. It will:
 * 1. Find all users without serial numbers
 * 2. Assign them sequential serial numbers starting from 1
 * 3. Maintain chronological order based on user creation date
 *
 * Usage:
 * npm run migration:assign-serial-numbers
 * or
 * npx ts-node src/migrations/assign-user-serial-numbers.migration.ts
 */

async function assignSerialNumbersToExistingUsers() {
  console.log(
    '🚀 Starting migration: Assign serial numbers to existing users...',
  );

  try {
    // Create NestJS application context
    const app = await NestFactory.createApplicationContext(AppModule);
    const userRepository = app.get(UserRepository);

    // Get current user count
    const totalUsers = await userRepository.getUserCount();
    console.log(`📊 Total users in database: ${totalUsers}`);

    // Check how many users already have serial numbers
    const usersWithSerialNumbers = await userRepository[
      'userModel'
    ].countDocuments({
      serialNumber: { $exists: true },
      isDeleted: false,
    });
    console.log(`✅ Users with serial numbers: ${usersWithSerialNumbers}`);

    const usersWithoutSerialNumbers = totalUsers - usersWithSerialNumbers;
    console.log(
      `🔄 Users needing serial numbers: ${usersWithoutSerialNumbers}`,
    );

    if (usersWithoutSerialNumbers === 0) {
      console.log(
        '✨ All users already have serial numbers. Migration not needed.',
      );
      await app.close();
      return;
    }

    // Assign serial numbers to existing users
    console.log('🔄 Assigning serial numbers to existing users...');
    await userRepository.assignSerialNumbersToExistingUsers();

    // Verify the migration
    const finalCount = await userRepository['userModel'].countDocuments({
      serialNumber: { $exists: true },
      isDeleted: false,
    });

    console.log(`✅ Migration completed successfully!`);
    console.log(`📊 Users with serial numbers after migration: ${finalCount}`);
    console.log(
      `🎯 Serial numbers assigned: ${finalCount - usersWithSerialNumbers}`,
    );

    await app.close();
    console.log('🏁 Migration script finished.');
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run the migration if this file is executed directly
if (require.main === module) {
  assignSerialNumbersToExistingUsers();
}

export { assignSerialNumbersToExistingUsers };
