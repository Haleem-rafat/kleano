import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/layout/services/notification_manager_service.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  final NotificationManagerService _notificationManager =
      NotificationManagerService();

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _bookingNotifications = true;
  bool _reminderNotifications = true;
  bool _promotionNotifications = true;
  bool _orderNotifications = true;
  bool _systemNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _notificationManager.notificationsEnabled;
      _soundEnabled = _notificationManager.soundEnabled;
      _vibrationEnabled = _notificationManager.vibrationEnabled;
      _bookingNotifications = _notificationManager.bookingNotifications;
      _reminderNotifications = _notificationManager.reminderNotifications;
      _promotionNotifications = _notificationManager.promotionNotifications;
      _orderNotifications = _notificationManager.orderNotifications;
      _systemNotifications = _notificationManager.systemNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main notifications toggle
        _buildSectionHeader(translate(AppStrings.notifications)),
        _buildToggleTile(
          title: translate(AppStrings.enableNotifications),
          subtitle: translate(AppStrings.enableNotificationsDescription),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _notificationManager.setNotificationsEnabled(value);
          },
          icon: Icons.notifications,
        ),

        if (_notificationsEnabled) ...[
          SizedBox(height: AppSize.s16.h),

          // Sound and vibration settings
          _buildSectionHeader(translate(AppStrings.soundAndVibration)),
          _buildToggleTile(
            title: translate(AppStrings.sound),
            subtitle: translate(AppStrings.soundDescription),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              _notificationManager.setSoundEnabled(value);
            },
            icon: Icons.volume_up,
          ),
          _buildToggleTile(
            title: translate(AppStrings.vibration),
            subtitle: translate(AppStrings.vibrationDescription),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              _notificationManager.setVibrationEnabled(value);
            },
            icon: Icons.vibration,
          ),

          SizedBox(height: AppSize.s16.h),

          // Notification types
          _buildSectionHeader(translate(AppStrings.notificationTypes)),
          _buildToggleTile(
            title: translate(AppStrings.bookingNotifications),
            subtitle: translate(AppStrings.bookingNotificationsDescription),
            value: _bookingNotifications,
            onChanged: (value) {
              setState(() {
                _bookingNotifications = value;
              });
              _notificationManager.setBookingNotifications(value);
            },
            icon: Icons.calendar_today,
          ),
          _buildToggleTile(
            title: translate(AppStrings.reminderNotifications),
            subtitle: translate(AppStrings.reminderNotificationsDescription),
            value: _reminderNotifications,
            onChanged: (value) {
              setState(() {
                _reminderNotifications = value;
              });
              _notificationManager.setReminderNotifications(value);
            },
            icon: Icons.schedule,
          ),
          _buildToggleTile(
            title: translate(AppStrings.promotionNotifications),
            subtitle: translate(AppStrings.promotionNotificationsDescription),
            value: _promotionNotifications,
            onChanged: (value) {
              setState(() {
                _promotionNotifications = value;
              });
              _notificationManager.setPromotionNotifications(value);
            },
            icon: Icons.local_offer,
          ),
          _buildToggleTile(
            title: translate(AppStrings.orderNotifications),
            subtitle: translate(AppStrings.orderNotificationsDescription),
            value: _orderNotifications,
            onChanged: (value) {
              setState(() {
                _orderNotifications = value;
              });
              _notificationManager.setOrderNotifications(value);
            },
            icon: Icons.shopping_bag,
          ),
          _buildToggleTile(
            title: translate(AppStrings.systemNotifications),
            subtitle: translate(AppStrings.systemNotificationsDescription),
            value: _systemNotifications,
            onChanged: (value) {
              setState(() {
                _systemNotifications = value;
              });
              _notificationManager.setSystemNotifications(value);
            },
            icon: Icons.settings,
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
      child: Text(
        title,
        style: AppStyles.title16Bold.copyWith(
          color: ColorManager.primary,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppPadding.p16.w,
        vertical: AppPadding.p4.h,
      ),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s12.r),
        border: Border.all(
          color: ColorManager.lightGray,
          width: 1.w,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: ColorManager.primary,
          size: AppSize.s24.r,
        ),
        title: Text(
          title,
          style: AppStyles.title16Regular.copyWith(
            color: ColorManager.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyles.titleGray16Regular.copyWith(
            color: ColorManager.darkGrey,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ColorManager.primary,
          inactiveThumbColor: ColorManager.lightGray,
          inactiveTrackColor: ColorManager.lightGray.withOpacity(0.3),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppPadding.p16.w,
          vertical: AppPadding.p8.h,
        ),
      ),
    );
  }
}

class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationManager = NotificationManagerService();

    return Container(
      margin: EdgeInsets.all(AppPadding.p16.w),
      padding: EdgeInsets.all(AppPadding.p16.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s12.r),
        border: Border.all(
          color: ColorManager.lightGray,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(AppStrings.testNotifications),
            style: AppStyles.title16Bold.copyWith(
              color: ColorManager.primary,
            ),
          ),
          SizedBox(height: AppSize.s12.h),
          Wrap(
            spacing: AppPadding.p8.w,
            runSpacing: AppPadding.p8.h,
            children: [
              _buildTestButton(
                context,
                translate(AppStrings.testBooking),
                () => notificationManager.showBookingNotification(
                  translate(AppStrings.testBookingTitle),
                  translate(AppStrings.testBookingBody),
                ),
                ColorManager.primary,
              ),
              _buildTestButton(
                context,
                translate(AppStrings.testReminder),
                () => notificationManager.showReminderNotification(
                  translate(AppStrings.testReminderTitle),
                  translate(AppStrings.testReminderBody),
                ),
                ColorManager.orange,
              ),
              _buildTestButton(
                context,
                translate(AppStrings.testPromotion),
                () => notificationManager.showPromotionNotification(
                  translate(AppStrings.testPromotionTitle),
                  translate(AppStrings.testPromotionBody),
                ),
                ColorManager.green,
              ),
              _buildTestButton(
                context,
                translate(AppStrings.testOrder),
                () => notificationManager.showOrderNotification(
                  translate(AppStrings.testOrderTitle),
                  translate(AppStrings.testOrderBody),
                ),
                ColorManager.blue,
              ),
              _buildTestButton(
                context,
                translate(AppStrings.testSystem),
                () => notificationManager.showSystemNotification(
                  translate(AppStrings.testSystemTitle),
                  translate(AppStrings.testSystemBody),
                ),
                ColorManager.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: ColorManager.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8.r),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p12.w,
          vertical: AppPadding.p8.h,
        ),
      ),
      child: Text(
        text,
        style: AppStyles.title16Regular.copyWith(
          color: ColorManager.white,
        ),
      ),
    );
  }
}
