import 'dart:io';

import 'package:flutter/material.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:badges/badges.dart' as badge;
import 'package:thewasher/core/utilis/geocoding_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/widget/doted_widget.dart';
import 'package:thewasher/modules/Home/widget/offer_widget.dart';
import 'package:thewasher/modules/booking/screens/order_detalis_screen.dart';
import 'package:thewasher/modules/booking/widgets/functions/check_value_method_to_navigate_pages.dart';
import 'package:thewasher/modules/booking/widgets/total_pay_card.dart';
import 'package:thewasher/modules/notifications/screens/notifications_screen.dart';
import 'package:thewasher/modules/notifications/screens/guest_notification_screen.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/screens/add_services.dart';
import 'package:thewasher/modules/booking/screens/rest_unified_booking_screen.dart';
import 'package:thewasher/modules/booking/screens/set_booking_location_screen.dart';
import 'package:thewasher/modules/booking/widgets/functions/create_order_data_request.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/shimmering/basic_container_shimmering.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/order_utils.dart';

class BookingMainScreen extends StatefulWidget {
  const BookingMainScreen({super.key});

  @override
  State<BookingMainScreen> createState() => _BookingMainScreenState();
}

class _BookingMainScreenState extends State<BookingMainScreen> {
  int indexPage = 0;
  BookingOrderBloc createOrderBloc = CreateOrderFunction().orderBloc;
  GeneralSingleton generalSingleton = GeneralSingleton();
  final ValueNotifier<bool> _isNotesFocused = ValueNotifier<bool>(false);
  late final List<Widget> bookingScreen;
  bool isLoading = true;
  bool _isGuest = false;
  Position? _currentPosition;
  String _currentCountry = "";
  late final RefreshController refreshController;
  Key _offerWidgetKey = UniqueKey();

  String _guestAuthMessage(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'ar') {
      return 'فضلًا سجّل الدخول أو أنشئ حسابًا للمتابعة';
    }
    return 'Please log in or sign up to continue';
  }

  Future<void> _checkAuthenticationStatus() async {
    await AppShared.getToken();
    final bool guestStatus = AppShared.token.isEmpty || isGuestUser;
    debugPrint(
      "Checking authentication: Token empty=${AppShared.token.isEmpty}, isGuestUser=$isGuestUser, _isGuest=$guestStatus",
    );
    setState(() {
      _isGuest = guestStatus;
    });
  }

  Future<void> _getUserLocation() async {
    try {
      debugPrint("Guest user: Checking location services...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Guest user: Location services are disabled");
        await Geolocator.openLocationSettings();
        return;
      }

      debugPrint("Guest user: Checking location permissions...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Guest user: Requesting location permission...");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("Guest user: Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("Guest user: Location permission denied forever");
        return;
      }

      debugPrint("Guest user: Getting current position...");
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint(
        "Guest user: Position obtained - lat: ${position.latitude}, lng: ${position.longitude}",
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final country = placemarks.first.country ?? "saudi arabia";
      debugPrint("Guest user: Country detected - $country");

      setState(() {
        _currentPosition = position;
        _currentCountry = country;
        GeneralSingleton().currentPositionGuest = LatLng(
          position.latitude,
          position.longitude,
        );
        GeneralSingleton().country = placemarks.first.country;
      });

      debugPrint("Guest user: Location successfully stored");
    } catch (e) {
      debugPrint("Guest user: Error getting location - $e");
    }
  }

  Future<void> _handleRefresh() async {
    await _checkAuthenticationStatus();
    if (!mounted) return;

    if (_isGuest) {
      await _getUserLocation();
      if (_currentPosition == null) {
        if (refreshController.isRefresh) {
          refreshController.refreshFailed();
        }
        return;
      }

      sl<OffersBloc>().add(
        GetGuestServices(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          country: "saudi arabia",
        ),
      );

      sl<OffersBloc>().add(
        GetGuestAddOns(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          country: "saudi arabia",
        ),
      );
    } else {
      sl<LocationBloc>().add(GetSavedLocation());
      sl<GetUserProfileBloc>().add(GetUserProfileEvent());
      sl<PlansAndSubscriptionBloc>().add(
        GetSubscriptionUserByLocation(
          latitude: blcoPosition.latitude,
          longitude: blcoPosition.longitude,
          country: blcoCountry,
        ),
      );

      sl<OffersBloc>().add(
        GetServices(
          lat: blcoPosition.latitude,
          lng: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );

      sl<OffersBloc>().add(
        GetAddOns(
          lat: blcoPosition.latitude,
          lng: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );
    }

    if (mounted) {
      setState(() {
        _offerWidgetKey = UniqueKey();
      });
    }
  }

  void _backButtonSteps() {
    if (indexPage == 0) {
      popScreen(context, 2);
      createOrderBloc.add(ClearCartOrder());
    } else {
      setState(() {
        indexPage = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    clearAllOrderDetails();
    refreshController = RefreshController();
    bookingScreen = [
      const AddServices(),
      RestUnifiedBookingScreen(
        onNotesFocusChanged: (isFocused) => _isNotesFocused.value = isFocused,
      ),
    ];

    // Check if user is guest
    _checkAuthenticationStatus().then((_) {
      if (_isGuest) {
        // For guest users, get location and fetch guest services
        _getUserLocation().then((_) {
          if (_currentPosition != null) {
            // Fetch guest services with current location

            debugPrint(
              "Fetching guest services with location: lat=${_currentPosition!.latitude}, lng=${_currentPosition!.longitude}, country=$_currentCountry",
            );
            sl<OffersBloc>().add(
              GetGuestServices(
                lat: _currentPosition!.latitude,
                lng: _currentPosition!.longitude,
                country: "saudi arabia",
              ),
            );

            debugPrint(
              "Fetching guest add-ons with location: lat=${_currentPosition!.latitude}, lng=${_currentPosition!.longitude}, country=$_currentCountry",
            );
            sl<OffersBloc>().add(
              GetGuestAddOns(
                lat: _currentPosition!.latitude,
                lng: _currentPosition!.longitude,
                country: "saudi arabia",
              ),
            );
          } else {
            debugPrint("Guest user: Unable to fetch location");
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        });
      } else {
        // For authenticated users, use existing logic
        sl<LocationBloc>().add(GetSavedLocation());
        sl<GetUserProfileBloc>().add(GetUserProfileEvent());

        Future.delayed(const Duration(seconds: 2), () {
          sl<PlansAndSubscriptionBloc>().add(
            GetSubscriptionUserByLocation(
              latitude: blcoPosition.latitude,
              longitude: blcoPosition.longitude,
              country: "saudi arabia",
            ),
          );

          sl<OffersBloc>().add(
            GetServices(
              lat: blcoPosition.latitude,
              lng: blcoPosition.longitude,
              country: "saudi arabia",
            ),
          );

          sl<OffersBloc>().add(
            GetAddOns(
              lat: blcoPosition.latitude,
              lng: blcoPosition.longitude,
              country: "saudi arabia",
            ),
          );
        });
      }
    });

    sl<BookingOrderBloc>().add(ClearCartOrder());
  }

  @override
  void dispose() {
    refreshController.dispose();
    _isNotesFocused.dispose();
    super.dispose();
  }

  void _nextButtonSteps() {
    if (_isGuest) {
      showSnackBar(buildContext: context, message: _guestAuthMessage(context));
      return;
    }

    if (indexPage == 0) {
      // Validate services then move to the rest page
      final bool hasService = checkSetValue(0);
      if (!hasService) {
        showSnackBar(
          buildContext: context,
          message: translate(AppStrings.pleaseSelectOneMainService),
        );
        return;
      }
      setState(() {
        indexPage = 1;
      });
      return;
    }

    // On the rest page, validate vehicle and time then proceed
    final bool hasVehicle = checkSetValue(2);
    if (!hasVehicle) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.pleaseSelectCar),
      );
      return;
    }

    final bool hasTime = checkSetValue(4);
    if (!hasTime) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.pleaseSelectTime),
      );
      return;
    }

    if (sl.call<OffersBloc>().total.toDouble() != 0.0) {
      pushPage(context, const OrderDetalisScreen());
    } else {
      CreateOrderFunction().createOrderDataRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsWithTransparentColorStyle.copyWith(
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: PopScope(
          canPop: false,
          child: MultiBlocListener(
            listeners: [
              BlocListener<OffersBloc, OffersState>(
                bloc: sl<OffersBloc>(),
                listener: (context, state) {
                  if (state is GetServicesSuccess ||
                      state is GetGuestServicesSuccess ||
                      state is EmptyServices ||
                      state is EmptyGuestServices) {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                    if (refreshController.isRefresh) {
                      refreshController.refreshCompleted();
                    }
                  } else if (state is GetServicesFailed ||
                      state is GetGuestServicesFailed) {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                    if (refreshController.isRefresh) {
                      refreshController.refreshFailed();
                    }
                  }
                },
              ),
            ],
            child: Stack(
              children: [
                SmartRefresher(
                  controller: refreshController,
                  enablePullDown: indexPage == 0 ? true : false,
                  header: const ClassicHeader(),
                  onRefresh: _handleRefresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        // Safe-area aware: works with notches, the Dynamic
                        // Island and iPhone Duo's side camera island.
                        expandedHeight: indexPage == 0
                            ? MediaQuery.paddingOf(context).top +
                                  8 +
                                  (Platform.isAndroid ? 220.h : 200.h) +
                                  24
                            : 70.h,
                        floating: false,
                        pinned: true,
                        // iOS 26/27: no coloured bar; title on the content.
                        backgroundColor: ColorManager.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        leading: indexPage == 0
                            ? null
                            : GlassBackButton(
                                color: ColorManager.primary,
                                onPressed: _backButtonSteps,
                              ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.paddingOf(context).top + 8,
                                  left:
                                      16.w + MediaQuery.paddingOf(context).left,
                                  right:
                                      16.w +
                                      MediaQuery.paddingOf(context).right,
                                  bottom: 2.h,
                                ),
                                child: indexPage == 0
                                    ? Row(
                                        children: <Widget>[
                                          // Greeting section
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                Text(
                                                  translate(AppStrings.hello),
                                                  style: AppStyles
                                                      .titleWhite16Bold,
                                                ),
                                                AppSize.s1_5.pw,
                                                _isGuest
                                                    ? Text(
                                                        '...',
                                                        style: AppStyles
                                                            .titleWhite16Bold,
                                                      )
                                                    : (context
                                                                  .read<
                                                                    GetUserProfileBloc
                                                                  >()
                                                                  .profile
                                                                  .userName ==
                                                              ""
                                                          ? const DotedWidget()
                                                          : BlocBuilder<
                                                              GetUserProfileBloc,
                                                              GetUserProfileState
                                                            >(
                                                              builder: (context, state) {
                                                                if (state
                                                                    is GetUserProfileLoading) {
                                                                  return const DotedWidget();
                                                                } else if (state
                                                                    is GetUserProfileSuccess) {
                                                                  return Text(
                                                                    ' ${state.userProfile.data?.userName!.split(' ').first}',
                                                                    style: AppStyles
                                                                        .titleWhite16Bold,
                                                                  );
                                                                }
                                                                return const SizedBox();
                                                              },
                                                            )),
                                              ],
                                            ),
                                          ),
                                          // Coins section
                                          _isGuest
                                              ? GestureDetector(
                                                  onTap: () {
                                                    AlertHelper.pointAlert(
                                                      context,
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 24.h,
                                                    width: 24.w,
                                                    decoration: BoxDecoration(
                                                      color: ColorManager
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.10,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15.r,
                                                          ),
                                                    ),
                                                    child: SvgPicture.asset(
                                                      AssetsManager.walletCoin,
                                                      height: 12.h,
                                                      width: 12.w,
                                                      fit: BoxFit.none,
                                                    ),
                                                  ),
                                                )
                                              : BlocBuilder<
                                                  GetUserProfileBloc,
                                                  GetUserProfileState
                                                >(
                                                  builder: (context, state) {
                                                    if (state
                                                        is GetUserProfileLoading) {
                                                      return const DotedWidget();
                                                    } else if (state
                                                        is GetUserProfileSuccess) {
                                                      return InkWell(
                                                        onTap: () {
                                                          AlertHelper.pointAlert(
                                                            context,
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 23.h,
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 3.h,
                                                                horizontal: 8.w,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: ColorManager
                                                                .secondary,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  15.r,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SvgPicture.asset(
                                                                  AssetsManager
                                                                      .walletCoin,
                                                                  height: 10.h,
                                                                  width: 10.w,
                                                                ),
                                                                2.pw,
                                                                Text(
                                                                  "${state.userProfile.data?.points ?? 0.0}",
                                                                  style: AppStyles
                                                                      .subtext14Regular
                                                                      .copyWith(
                                                                        color: ColorManager
                                                                            .white,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox();
                                                  },
                                                ),
                                          // Notifications section
                                          SizedBox(width: 8.w),
                                          GestureDetector(
                                            onTap: () {
                                              if (_isGuest) {
                                                pushPage(
                                                  context,
                                                  const GuestNotificationScreen(),
                                                );
                                              } else {
                                                pushPage(
                                                  context,
                                                  const NotificationsScreen(),
                                                );
                                              }
                                              if (mounted) {
                                                setState(() {
                                                  generalSingleton
                                                          .hasUnreadNotification =
                                                      false;
                                                });
                                              }
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: SizedBox(
                                              height: AppSize.s20.h,
                                              width: AppSize.s20.w,
                                              child: Stack(
                                                alignment: Alignment.topLeft,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                    AssetsManager.notification,
                                                    fit: BoxFit.cover,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                          ColorManager.primary,
                                                          BlendMode.srcIn,
                                                        ),
                                                  ),
                                                  if (generalSingleton
                                                      .hasUnreadNotification)
                                                    SizedBox(
                                                      height: 6.h,
                                                      width: 6.w,
                                                      child:
                                                          const badge.Badge(),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Location chip section
                                          if (!_isGuest) ...[
                                            SizedBox(width: 8.w),
                                            BlocBuilder<
                                              LocationBloc,
                                              LocationState
                                            >(
                                              builder: (context, state) {
                                                if (state
                                                    is GetSavedLocationSuccess) {
                                                  // Find the default address
                                                  AddressModel? defaultAddress;
                                                  try {
                                                    defaultAddress = state
                                                        .savedLocation
                                                        .firstWhere(
                                                          (address) =>
                                                              address
                                                                  .isDefault ==
                                                              true,
                                                        );
                                                  } catch (e) {
                                                    if (state
                                                        .savedLocation
                                                        .isNotEmpty) {
                                                      defaultAddress = state
                                                          .savedLocation
                                                          .first;
                                                    }
                                                  }

                                                  if (defaultAddress != null) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        pushPage(
                                                          context,
                                                          SetBookingLocationScreen(),
                                                        );
                                                      },
                                                      child: Chip(
                                                        backgroundColor:
                                                            ColorManager
                                                                .primary,
                                                        label: Text(
                                                          defaultAddress
                                                                      .savedName
                                                                      ?.isNotEmpty ==
                                                                  true
                                                              ? defaultAddress
                                                                    .savedName!
                                                              : defaultAddress
                                                                        .streetName ??
                                                                    translate(
                                                                      AppStrings
                                                                          .defaultAddress,
                                                                    ),
                                                          style: AppStyles
                                                              .title16Bold
                                                              .copyWith(
                                                                color:
                                                                    ColorManager
                                                                        .white,
                                                                fontSize: 12.sp,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        avatar: const Icon(
                                                          Icons.location_on,
                                                          color: ColorManager
                                                              .white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }

                                                return SizedBox();
                                              },
                                            ),
                                          ],
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 10.h),
                                          Text(
                                            translate(AppStrings.bookingOrder),
                                            style: AppStyles.titleWhite16Bold
                                                .copyWith(
                                                  color: ColorManager.black,
                                                  fontSize: 22.sp,
                                                )
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                              // Offer widget section - only show on first screen
                              if (indexPage == 0) ...[
                                OfferWidget(key: _offerWidgetKey),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Main content as sliver
                      SliverToBoxAdapter(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height -
                                250.h, // Account for app bar height
                          ),
                          child: isLoading
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      16.verticalSpace,
                                      // Title shimmer
                                      BasicContainerShemmering(
                                        height: 20.h,
                                        width: 200.w,
                                        radius: 8,
                                      ),
                                      16.verticalSpace,
                                      // Main services shimmer
                                      BasicContainerShemmering(
                                        height: 80.h,
                                        width: double.infinity,
                                        radius: 15,
                                      ),
                                      16.verticalSpace,
                                      // Extra services title shimmer
                                      BasicContainerShemmering(
                                        height: 20.h,
                                        width: 180.w,
                                        radius: 8,
                                      ),
                                      2.verticalSpace,
                                      // Extra services list shimmer
                                      ...List.generate(3, (index) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 18.h,
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                            12.5.w,
                                            11.5.h,
                                            12.5.w,
                                            13.5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15.r,
                                            ),
                                            color: ColorManager.white,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: ColorManager.black
                                                    .withValues(alpha: .05),
                                                blurRadius: 3.r,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              // Checkbox shimmer
                                              BasicContainerShemmering(
                                                height: 24.h,
                                                width: 24.w,
                                                radius: 6,
                                              ),
                                              SizedBox(width: 8.w),
                                              // Icon shimmer
                                              BasicContainerShemmering(
                                                height: 50.h,
                                                width: 50.w,
                                                radius: 10,
                                              ),
                                              SizedBox(width: 8.w),
                                              // Text content shimmer
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    BasicContainerShemmering(
                                                      height: 16.h,
                                                      width: 120.w,
                                                      radius: 4,
                                                    ),
                                                    8.verticalSpace,
                                                    BasicContainerShemmering(
                                                      height: 12.h,
                                                      width: 80.w,
                                                      radius: 4,
                                                    ),
                                                    4.verticalSpace,
                                                    BasicContainerShemmering(
                                                      height: 12.h,
                                                      width: 100.w,
                                                      radius: 4,
                                                    ),
                                                    4.verticalSpace,
                                                    BasicContainerShemmering(
                                                      height: 12.h,
                                                      width: 60.w,
                                                      radius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 100.h,
                                  ), // Add bottom padding for FAB
                                  child: bookingScreen[indexPage],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Positioned button at bottom (hidden while notes field focused)
                ValueListenableBuilder<bool>(
                  valueListenable: _isNotesFocused,
                  builder: (context, isFocused, child) {
                    if (isFocused && indexPage == 1) {
                      return const SizedBox.shrink();
                    }
                    return isLoading
                        ? const SizedBox.shrink()
                        : Positioned(
                            bottom: 90.h,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isGuest)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: Text(
                                      _guestAuthMessage(context),
                                      style: AppStyles.subtext14Regular
                                          .copyWith(color: ColorManager.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                Opacity(
                                  opacity: _isGuest ? 0.6 : 1,
                                  child: GestureDetector(
                                    onTap: _nextButtonSteps,
                                    child: BlocConsumer<BookingOrderBloc, BookingOrderState>(
                                      listener:
                                          (
                                            BuildContext context,
                                            BookingOrderState state,
                                          ) {
                                            if (state is CreateOrderSuccess) {
                                              generalSingleton.orderId = state
                                                  .reviewOrderModel
                                                  .data!
                                                  .sId!;

                                              if (state
                                                          .reviewOrderModel
                                                          .data!
                                                          .totalPay ==
                                                      0.0 ||
                                                  state
                                                          .reviewOrderModel
                                                          .data!
                                                          .totalPay ==
                                                      0) {
                                                AlertHelper.createOrderSuccess(
                                                  context,
                                                );
                                              }
                                            } else if (state
                                                is CreateOrderFailed) {
                                              if (state.errorModel!.en ==
                                                      AppStrings
                                                          .yourWalletBalanceIsNotValid ||
                                                  state.errorModel!.ar ==
                                                      AppStrings
                                                          .yourWalletBalanceIsNotValid) {
                                                AlertHelper.payWithWalletNotEnoughAmount(
                                                  context,
                                                );
                                              } else {
                                                showSnackBar(
                                                  buildContext: context,
                                                  message:
                                                      Localizations.localeOf(
                                                            context,
                                                          ).languageCode ==
                                                          'en'
                                                      ? state.errorModel!.en!
                                                      : state.errorModel!.ar!,
                                                );
                                              }
                                            }
                                          },
                                      builder:
                                          (
                                            BuildContext context,
                                            BookingOrderState state,
                                          ) {
                                            if (state is CreateOrderLoading) {
                                              return const LoadingWidget();
                                            }

                                            // Hide button when services are loading
                                            return BlocBuilder<
                                              OffersBloc,
                                              OffersState
                                            >(
                                              builder: (context, offersState) {
                                                if (offersState
                                                        is OffersInitial ||
                                                    offersState
                                                        is GetServicesLoading ||
                                                    offersState
                                                        is GetAddOnsLoading ||
                                                    offersState
                                                        is AddServiceCartLoading ||
                                                    offersState
                                                        is DeleteServiceCartLoading ||
                                                    offersState
                                                        is AddExtraCartLoading ||
                                                    offersState
                                                        is DeleteExtraCartLoading ||
                                                    offersState
                                                        is ClearCartLoading ||
                                                    offersState
                                                        is ClearAllSelectedServicesLoading ||
                                                    offersState
                                                        is GetGuestServicesLoading ||
                                                    offersState
                                                        is GetGuestAddOnsLoading) {
                                                  return const SizedBox.shrink();
                                                }

                                                final offersBloc = context
                                                    .read<OffersBloc>();

                                                final int servicesCount =
                                                    offersBloc
                                                        .cartServicesList
                                                        .length;
                                                final int addOnsCount =
                                                    offersBloc
                                                        .cartAddOnsList
                                                        .length;
                                                final num servicesTotal =
                                                    offersBloc.cartServicesList
                                                        .fold<num>(
                                                          0,
                                                          (sum, service) =>
                                                              sum +
                                                              (service.price ??
                                                                  0),
                                                        );
                                                final num addOnsTotal =
                                                    offersBloc.cartAddOnsList
                                                        .fold<num>(
                                                          0,
                                                          (sum, addon) =>
                                                              sum +
                                                              (addon.price ??
                                                                  0),
                                                        );
                                                final num totalPrice =
                                                    servicesTotal + addOnsTotal;

                                                return TotalPayCard(
                                                  text: indexPage == 0
                                                      ? translate(
                                                          AppStrings.nextButton,
                                                        )
                                                      : translate(
                                                          AppStrings
                                                              .confirmButton,
                                                        ),
                                                  servicesCount: servicesCount,
                                                  addOnsCount: addOnsCount,
                                                  servicesTotal: servicesTotal,
                                                  addOnsTotal: addOnsTotal,
                                                  totalPrice: totalPrice,
                                                );
                                              },
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
