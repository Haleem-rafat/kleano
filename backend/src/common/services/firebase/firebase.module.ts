import { Module } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { FCMService } from './fcm.service';
@Module({
  imports: [],
  controllers: [],
  providers: [FirebaseService, FCMService],
  exports: [FirebaseService, FCMService],
})
export class FirebaseModule {}
