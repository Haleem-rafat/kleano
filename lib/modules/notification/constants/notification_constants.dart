/// Notification Constants
/// Contains all constants related to notifications

class NotificationConstants {
  // Notification Channel IDs
  static const String defaultChannelId = 'default_channel';
  static const String orderChannelId = 'order_notifications';
  static const String highImportanceChannelId = 'high_importance_channel';

  // Notification Channel Names
  static const String defaultChannelName = 'Default Notifications';
  static const String orderChannelName = 'Order Notifications';
  static const String highImportanceChannelName =
      'High Importance Notifications';

  // Notification Channel Descriptions
  static const String defaultChannelDescription = 'General app notifications';
  static const String orderChannelDescription =
      'New order and order update notifications';
  static const String highImportanceChannelDescription =
      'High priority notifications';

  // Notification Types (for data payload)
  static const String typeOrder = 'order';
  static const String typeMessage = 'message';
  static const String typeUpdate = 'update';
  static const String typePromotion = 'promotion';
  static const String typeSystem = 'system';

  // Notification Sound Files
  static const String orderSoundAndroid = 'neworder';
  static const String orderSoundIOS = 'newOrder.wav';

  // Topic Names
  static const String topicAllBikers = 'all-bikers';
  static const String topicPremiumBikers = 'premium-bikers';
  static const String topicNewOrders = 'new-orders';
  static const String topicUrgentAlerts = 'urgent-alerts';

  // Notification Icons
  static const String defaultIconAndroid = '@mipmap/ic_launcher';

  // Notification Colors
  static const int notificationColorPrimary = 0xFF4CAF50;
  static const int notificationColorAccent = 0xFF2196F3;
  static const int notificationColorWarning = 0xFFFFC107;
  static const int notificationColorError = 0xFFF44336;

  // Notification Actions
  static const String actionAccept = 'ACCEPT';
  static const String actionReject = 'REJECT';
  static const String actionView = 'VIEW';
  static const String actionReply = 'REPLY';

  // Notification Payload Keys
  static const String payloadKeyType = 'type';
  static const String payloadKeyOrderId = 'orderId';
  static const String payloadKeyUserId = 'userId';
  static const String payloadKeyTitle = 'title';
  static const String payloadKeyBody = 'body';
  static const String payloadKeyAction = 'action';
  static const String payloadKeyData = 'data';

  // Notification Settings
  static const bool defaultEnableSound = true;
  static const bool defaultEnableVibration = true;
  static const bool defaultEnableLights = true;
  static const int defaultNotificationTimeout = 5000; // milliseconds

  // Private constructor to prevent instantiation
  NotificationConstants._();
}
