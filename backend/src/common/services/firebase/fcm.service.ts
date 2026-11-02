import { Injectable } from '@nestjs/common';
import { FirebaseApp } from './firebase.config';
import { MulticastMessage } from 'firebase-admin/lib/messaging/messaging-api';

@Injectable()
export class FCMService {
  constructor() {
    /* TODO document why this constructor is empty */
  }

  async subscribeToTopic(registrationTokens: any, topic: any) {
    try {
      await FirebaseApp.messaging().subscribeToTopic(registrationTokens, topic);
    } catch (error) {
      console.log(error);
      console.log(error.errors[0].error);
    }
  }

  async unSubscribeToTopic(registrationTokens, topic) {
    try {
      await FirebaseApp.messaging().unsubscribeFromTopic(
        registrationTokens,
        topic,
      );
    } catch (error) {
      console.log(error);
    }
  }

  async pushNotificationToDeviceGroup(message: any) {
    console.log(message);

    if (message.tokens?.length) {
      try {
        // push message to user's tokens
        const response = await FirebaseApp.messaging().sendEachForMulticast(
          message,
        );
        // Check tokens

        return response;
      } catch (error) {
        console.log(error);
      }
    }
  }

  async pushNotificationToSpecificDevice(message: any) {
    try {
      // push message to user's tokens
      const response = await FirebaseApp.messaging().send(message);

      return response;
    } catch (error) {
      console.log(error);
    }
  }

  async pushNotificationToTopics(message: any) {
    try {
      const response = await FirebaseApp.messaging().send(message);
      return response;
    } catch (error) {
      console.log(error);
    }
  }

  async pushNotificationToMultiUser(message: MulticastMessage) {
    try {
      const response = await FirebaseApp.messaging().sendEachForMulticast(
        message,
      );
      return response;
    } catch (error) {
      console.log(error);
    }
  }
}
