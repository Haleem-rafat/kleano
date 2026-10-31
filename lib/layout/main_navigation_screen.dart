import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:animations/animations.dart';
import 'package:thewasher/layout/assets_nav_bar.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/modules/booking/screens/booking_main_screen.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_tabs.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
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

  const MainNavigationScreen({
    super.key,
    required this.selectedIndex,
    this.isBooking = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int screenIndex;
  late List<Widget> screens;
  DateTime preBackPress = DateTime.now();
  LocationMap locationMap = LocationMap();

  GeneralSingleton generalSingleton = GeneralSingleton();
  StreamSubscription<NotificationsState>? _notificationsSub;

  @override
  void dispose() {
    _notificationsSub?.cancel();
    super.dispose();
  }

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
    _notificationsSub = sl<NotificationsBloc>().stream.listen((
      NotificationsState notificationsState,
    ) {
      if (notificationsState is PushNotificationsSuccess) {
        sl<NotificationsBloc>().add(FetchAllNotifications());
      } else if (notificationsState is PushNotificationsFailed) {
        if (!mounted) return;
        showSnackBar(buildContext: context, message: notificationsState.error!);
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

  bool _useSidebar(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return isRegularWidth(context) && size.width > size.height;
  }

  Widget _pages() {
    return PageTransitionSwitcher(
      transitionBuilder:
          (
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
    );
  }

  List<GlassTabItem> _tabItems() => <GlassTabItem>[
    for (int index = 0; index < screens.length; index++)
      GlassTabItem(
        label: translate(getNavBarTitle(index)),
        svgAsset: getNavBarIconAsset(index),
        iconBuilder: (bool selected, Color color) => SvgPicture.asset(
          getNavBarIconAsset(index),
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
  ];

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final Duration timeGap = DateTime.now().difference(preBackPress);
        final bool cantExit = timeGap >= const Duration(seconds: 2);
        preBackPress = DateTime.now();
        if (cantExit) {
          final SnackBar snack = SnackBar(
            content: Text(translate(AppStrings.backButton)),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        floatingActionButton: BlocBuilder<AboutUsBloc, AboutUsState>(
          builder: (context, aboutUsState) {
            final String whatsappNumber =
                aboutUsState.contactInfo?.whatsAppNumber ?? '';

            // Hidden until the real support number has loaded.
            return screenIndex == 0 || whatsappNumber.isEmpty
                ? const SizedBox()
                : FloatingActionButton(
                    onPressed: () async {
                      final Uri whatsappUri = Uri.parse(
                        "https://wa.me/$whatsappNumber",
                      );

                      if (await urlLauncher.canLaunchUrl(whatsappUri)) {
                        await urlLauncher.launchUrl(whatsappUri);
                      } else {
                        // Fallback to WhatsApp web if app is not installed
                        final Uri whatsappWebUri = Uri.parse(
                          "https://web.whatsapp.com/send?phone=$whatsappNumber",
                        );
                        await urlLauncher.launchUrl(whatsappWebUri);
                      }
                    },
                    backgroundColor: const Color(0xFF25D366),
                    child: SvgPicture.asset(
                      'assets/svg/whatsapp_icon.svg',
                      height: 24,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
          },
        ),
        extendBody: true,
        // Regular width and wider than tall (iPhone Duo unfolded, iPad,
        // landscape): Apple's "tab bar as a sidebar". Otherwise the floating
        // tab bar at the bottom.
        body: _useSidebar(context)
            ? Row(
                children: <Widget>[
                  GlassSidebar(
                    title: const Text('KleanO'),
                    items: _tabItems(),
                    currentIndex: screenIndex,
                    onTap: _onTabSelected,
                    activeColor: KColors.of(context).brand,
                    labelStyle: AppStyles.body14Medium,
                  ),
                  Expanded(
                    child: SafeArea(
                      left: false,
                      top: false,
                      bottom: false,
                      child: _pages(),
                    ),
                  ),
                ],
              )
            : _pages(),
        bottomNavigationBar: _useSidebar(context)
            ? null
            : GlassTabBar(
                currentIndex: screenIndex,
                activeColor: KColors.of(context).brand,
                inactiveColor: KColors.of(context).textSecondary,
                labelStyle: AppStyles.body14Medium,
                items: _tabItems(),
                onTap: _onTabSelected,
              ),
      ),
    );
  }
}
