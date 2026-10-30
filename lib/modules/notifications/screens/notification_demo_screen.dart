// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:thewasher/core/resources/app_styles.dart';
// import 'package:thewasher/core/resources/color_manager.dart';
// import 'package:thewasher/core/resources/strings_manager.dart';
// import 'package:thewasher/core/resources/values_manager.dart';
// import 'package:thewasher/layout/services/notification_helper_service.dart';
// import 'package:thewasher/shared/widgets/notification_settings_widget.dart';
// import 'package:thewasher/utilties/navigator.dart';
// import 'package:flutter_translate/flutter_translate.dart';

// class NotificationDemoScreen extends StatelessWidget {
//   const NotificationDemoScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           translate(AppStrings.notifications),
//           style: AppStyles.title18Regular.copyWith(
//             color: ColorManager.white,
//           ),
//         ),
//         backgroundColor: ColorManager.primary,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: ColorManager.white),
//           onPressed: () => pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Demo notifications section
//             Container(
//               margin: EdgeInsets.all(AppPadding.p16.w),
//               padding: EdgeInsets.all(AppPadding.p16.w),
//               decoration: BoxDecoration(
//                 color: ColorManager.white,
//                 borderRadius: BorderRadius.circular(AppSize.s12.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: ColorManager.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Demo Notifications',
//                     style: AppStyles.title18Regular.copyWith(
//                       color: ColorManager.primary,
//                     ),
//                   ),
//                   SizedBox(height: AppSize.s12.h),
//                   Text(
//                     'Test different types of notifications to see how they work in your app.',
//                     style: AppStyles.titleGray16Regular.copyWith(
//                       color: ColorManager.darkGrey,
//                     ),
//                   ),
//                   SizedBox(height: AppSize.s16.h),
//                   const NotificationTestWidget(),
//                 ],
//               ),
//             ),

//             // Notification settings
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
//               padding: EdgeInsets.all(AppPadding.p16.w),
//               decoration: BoxDecoration(
//                 color: ColorManager.white,
//                 borderRadius: BorderRadius.circular(AppSize.s12.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: ColorManager.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: const NotificationSettingsWidget(),
//             ),

//             SizedBox(height: AppSize.s24.h),

//             // Quick demo buttons
//             Container(
//               margin: EdgeInsets.all(AppPadding.p16.w),
//               padding: EdgeInsets.all(AppPadding.p16.w),
//               decoration: BoxDecoration(
//                 color: ColorManager.white,
//                 borderRadius: BorderRadius.circular(AppSize.s12.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: ColorManager.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Quick Demo',
//                     style: AppStyles.title18Regular.copyWith(
//                       color: ColorManager.primary,
//                     ),
//                   ),
//                   SizedBox(height: AppSize.s12.h),
//                   Text(
//                     'Try common notification scenarios:',
//                     style: AppStyles.titleGray16Regular.copyWith(
//                       color: ColorManager.darkGrey,
//                     ),
//                   ),
//                   SizedBox(height: AppSize.s16.h),
//                   _buildQuickDemoButtons(),
//                 ],
//               ),
//             ),

//             SizedBox(height: AppSize.s24.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickDemoButtons() {
//     final notificationHelper = NotificationHelperService();

//     return Column(
//       children: [
//         _buildQuickDemoButton(
//           'Booking Confirmation',
//           'Test booking confirmation notification',
//           () => notificationHelper.notifyBookingConfirmed(
//             'demo123',
//             'House Cleaning',
//             DateTime.now().add(const Duration(hours: 2)),
//           ),
//           ColorManager.primary,
//         ),
//         SizedBox(height: AppSize.s8.h),
//         _buildQuickDemoButton(
//           'Service Reminder',
//           'Test service reminder notification',
//           () => notificationHelper.notifyBookingReminder(
//             'demo123',
//             'Car Wash',
//             DateTime.now().add(const Duration(hours: 1)),
//           ),
//           ColorManager.orange,
//         ),
//         SizedBox(height: AppSize.s8.h),
//         _buildQuickDemoButton(
//           'Special Offer',
//           'Test promotion notification',
//           () => notificationHelper.notifySpecialOffer(
//             'Summer Sale!',
//             'Get 20% off on all cleaning services this weekend',
//             'SUMMER20',
//           ),
//           ColorManager.green,
//         ),
//         SizedBox(height: AppSize.s8.h),
//         _buildQuickDemoButton(
//           'Order Update',
//           'Test order status notification',
//           () => notificationHelper.notifyOrderStatusUpdate(
//             'order123',
//             'Processing',
//           ),
//           ColorManager.blue,
//         ),
//         SizedBox(height: AppSize.s8.h),
//         _buildQuickDemoButton(
//           'Schedule Reminder',
//           'Schedule a reminder for 10 seconds from now',
//           () => notificationHelper.scheduleReminder(
//             'Scheduled Reminder',
//             'This is a scheduled notification that will appear in 10 seconds',
//             DateTime.now().add(const Duration(seconds: 10)),
//           ),
//           ColorManager.secondary,
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickDemoButton(
//     String title,
//     String subtitle,
//     VoidCallback onPressed,
//     Color color,
//   ) {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(vertical: AppPadding.p4.h),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: ColorManager.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppSize.s8.r),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppPadding.p16.w,
//             vertical: AppPadding.p12.h,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: AppStyles.title16Bold.copyWith(
//                 color: ColorManager.white,
//               ),
//             ),
//             SizedBox(height: AppSize.s4.h),
//             Text(
//               subtitle,
//               style: AppStyles.titleGray16Regular.copyWith(
//                 color: ColorManager.white.withOpacity(0.9),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
