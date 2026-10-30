import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:animations/animations.dart';
import 'package:thewasher/layout/assets_nav_bar.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/modules/booking/screens/booking_main_screen.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_tabs.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/screens/user_profile_screen.dart';
import 'package:thewasher/layout/guest_flow.dart';
import 'package:thewasher/modules/my_vehicles/screens/my_vehicles_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/location_single_tone.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/order_utils.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class MainNavigationScreen extends StatefulWidget {
  final int selectedIndex;
  final bool isBooking;

  const MainNavigationScreen(
      {super.key, required this.selectedIndex, this.isBooking = false});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int screenIndex;
  late List<Widget> screens;
  DateTime preBackPress = DateTime.now();
  LocationMap locationMap = LocationMap();

  GeneralSingleton generalSingleton = GeneralSingleton();

  @override
  void initState() {
    screenIndex = widget.selectedIndex;
    screens = <Widget>[
      const BookingMainScreen(),
      const MyVehiclesScreen(),
      const MyBookingMainTabsScreen(),
      const PlansAndSubscriptionScreen(),
      const UserProfileScreen(),
    ];
    super.initState();
    sl<NotificationsBloc>().add(PushNotificationsEvent());
    sl<AboutUsBloc>().add(GetContactInfo());

    // Listen to notifications bloc state changes only
    // FCM listeners are already set up in NotificationManagerService
    sl<NotificationsBloc>()
        .stream
        .listen((NotificationsState notificationsState) {
      if (notificationsState is PushNotificationsSuccess) {
        sl<NotificationsBloc>().add(FetchAllNotifications());
      } else if (notificationsState is PushNotificationsFailed) {
        showSnackBar(
          buildContext: context,
          message: notificationsState.error!,
        );
      } else if (notificationsState is NotificationsSuccess) {
        setState(() {
          generalSingleton.hasUnreadNotification = notificationsState
              .notifications
              .where((Notifications element) => !element.isRead!)
              .isNotEmpty;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final Duration timeGap = DateTime.now().difference(preBackPress);
        final bool cantExit = timeGap >= const Duration(seconds: 2);
        preBackPress = DateTime.now();
        if (cantExit) {
          final SnackBar snack = SnackBar(
            content: Text(translate(AppStrings.backButton)),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false;
        } else {
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: BlocBuilder<AboutUsBloc, AboutUsState>(
          builder: (context, aboutUsState) {
            String whatsappNumber = "+1234567890";
            if (aboutUsState.contactInfo?.whatsAppNumber.isNotEmpty == true) {
              whatsappNumber = aboutUsState.contactInfo!.whatsAppNumber;
            }

            return screenIndex == 0
                ? const SizedBox()
                : FloatingActionButton(
                    onPressed: () async {
                      final Uri whatsappUri =
                          Uri.parse("https://wa.me/$whatsappNumber");

                      if (await urlLauncher.canLaunchUrl(whatsappUri)) {
                        await urlLauncher.launchUrl(whatsappUri);
                      } else {
                        // Fallback to WhatsApp web if app is not installed
                        final Uri whatsappWebUri = Uri.parse(
                            "https://web.whatsapp.com/send?phone=$whatsappNumber");
                        await urlLauncher.launchUrl(whatsappWebUri);
                      }
                    },
                    backgroundColor: const Color(0xFF25D366),
                    child: SvgPicture.asset(
                      'assets/svg/whatsapp_icon.svg',
                      height: 24,
                      width: 24,
                      color: Colors.white,
                    ),
                  );
          },
        ),
        extendBody: true,
        body: PageTransitionSwitcher(
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: screens[screenIndex],
        ),
        bottomNavigationBar: Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(screens.length, (index) {
                  final isSelected = index == screenIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          HapticFeedback.lightImpact();
                          if (screenIndex == 0) {
                            sl<LocationBloc>().add(GetSavedLocation());
                            sl<GetUserProfileBloc>().add(GetUserProfileEvent());
                          }
                          // Clear selected services when navigating away from booking screen
                          if (screenIndex == 0 && index != 0) {
                            sl<OffersBloc>().add(ClearAllSelectedServices());
                          }
                          // Clear all order details when navigating to main nav bar index 0
                          if (index == 0) {
                            clearAllOrderDetails();
                          }
                          screenIndex = index;
                        });
                        LoginFlow.selectedGuestIndex = index;
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                              horizontal: 6.w,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                getNavBarIconAsset(index),
                                height: isSelected ? 24.h : 20.h,
                                width: isSelected ? 24.w : 20.w,
                                color: isSelected
                                    ? ColorManager.primary
                                    : ColorManager.medGray,
                              ),
                            ),
                          ),
                          1.verticalSpace,
                          Text(
                            translate(getNavBarTitle(index)),
                            style: AppStyles.body14Medium.copyWith(
                              fontSize: isSelected ? 12.sp : 11.sp,
                              color: isSelected
                                  ? ColorManager.primary
                                  : ColorManager.medGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
