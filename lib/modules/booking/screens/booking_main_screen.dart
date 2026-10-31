import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/design/components/k_chip_button.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/core/utilis/enums.dart';
import 'package:thewasher/modules/tracking_order/services/wash_live_status.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/booking/widgets/home/active_order_card.dart';
import 'package:thewasher/modules/booking/widgets/home/home_sections.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/utilis/geocoding_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
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

const double _statusStripAfter = KSpace.xxxl * 2;

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
  final MyBookingBloc _activeOrders = MyBookingBloc();
  StreamSubscription<MyBookingState>? _liveStatusSub;
  final MyBookingBloc _pastOrders = MyBookingBloc();
  final ValueNotifier<bool> _scrolledPastHero = ValueNotifier<bool>(false);

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
      _loadOrders();
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

  void _loadOrders() {
    _activeOrders.add(FetchMyBookingActive());
    _pastOrders.add(FetchMyBookingHistory());
    sl<VehiclesBloc>().add(GetVehicles());
  }

  /// Continue in the Choose a wash sheet. Guests log in at this moment.
  void _continueFromSheet() {
    if (_isGuest) {
      AlertHelper.guestAlert(context);
      return;
    }
    _nextButtonSteps();
  }

  /// Book again: the last wash and car in the cart, straight to choosing a time.
  void _bookAgain(OrderModel order) {
    final OffersBloc offers = sl<OffersBloc>();
    final String? serviceId = order.washingServices?.firstOrNull?.sId;
    final int index = offers.mainServices.indexWhere(
      (ServiceModel s) => s.sId == serviceId,
    );
    if (index < 0) return;
    offers.add(
      AddServiceCart(
        service: offers.mainServices[index],
        selectedMainServiceIndex: index,
      ),
    );
    final VehiclesBloc vehicles = sl<VehiclesBloc>();
    for (final vehicle in vehicles.vehiclesList) {
      if (vehicle.sId == order.vehicle?.sId) {
        vehicles.add(SelectCar(vehicle: vehicle));
      }
    }
    setState(() => indexPage = 1);
  }

  void _loadOffersForAddress() {
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
    _liveStatusSub = _activeOrders.stream.listen((MyBookingState state) {
      if (!mounted || state.myBookingStatus != RequestStatus.success) return;
      WashLiveStatus.instance.showOrder(
        state.activeList.isEmpty ? null : state.activeList.first,
        arabic: Localizations.localeOf(context).languageCode == 'ar',
      );
    });
    refreshController = RefreshController();
    bookingScreen = [
      AddServices(onContinue: _continueFromSheet),
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
        _loadOrders();
        sl<LocationBloc>().add(GetSavedLocation());
        sl<GetUserProfileBloc>().add(GetUserProfileEvent());

        // The address check already set the position: load straight away. Only
        // wait for the saved address when arriving here without one.
        if (blcoPosition.latitude != 0 || blcoPosition.longitude != 0) {
          _loadOffersForAddress();
        } else {
          sl<LocationBloc>().stream
              .firstWhere(
                (LocationState s) =>
                    s is GetSavedLocationSuccess || s is GetSavedLocationFailed,
              )
              .then((_) {
                if (mounted) _loadOffersForAddress();
              });
        }
      }
    });

    sl<BookingOrderBloc>().add(ClearCartOrder());
  }

  @override
  void dispose() {
    refreshController.dispose();
    _isNotesFocused.dispose();
    _liveStatusSub?.cancel();
    _activeOrders.close();
    _scrolledPastHero.dispose();
    _pastOrders.close();
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
    final KColors c = KColors.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: c.background,
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
                NotificationListener<ScrollUpdateNotification>(
                  onNotification: (ScrollUpdateNotification update) {
                    _scrolledPastHero.value =
                        update.metrics.axis == Axis.vertical &&
                        update.metrics.pixels > _statusStripAfter;
                    return false;
                  },
                  child: SmartRefresher(
                    controller: refreshController,
                    enablePullDown: indexPage == 0 ? true : false,
                    header: const ClassicHeader(),
                    onRefresh: _handleRefresh,
                    child: CustomScrollView(
                      slivers: indexPage == 0
                          ? _homeSlivers(c)
                          : _reviewSlivers(c),
                    ),
                  ),
                ),
                // The photo Homes have no top bar: keeps scrolled content
                // from running under the clock.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.paddingOf(context).top,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _scrolledPastHero,
                    builder: (BuildContext _, bool scrolled, Widget? _) =>
                        scrolled
                        ? ColoredBox(color: c.background)
                        : const SizedBox.shrink(),
                  ),
                ),
                _buildBookingAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Home: the photo melting into the page with the wash card, the services,
  /// plans and offers, then the three promises.
  List<Widget> _homeSlivers(KColors c) {
    Widget box(Widget child) => SliverToBoxAdapter(child: child);
    return <Widget>[
      box(_buildPhotoHero(c)),
      box(
        isLoading
            ? const KSkeleton.grid(
                padding: EdgeInsets.symmetric(horizontal: KSpace.l),
              )
            : bookingScreen[0],
      ),
      box(const HomePlansCard()),
      box(
        Padding(
          padding: const EdgeInsets.only(top: KSpace.xl),
          child: OfferWidget(key: _offerWidgetKey),
        ),
      ),
      box(const HomeReassurance()),
      _buildHomeClearance(),
    ];
  }

  List<Widget> _reviewSlivers(KColors c) {
    return <Widget>[
      SliverAppBar(
        pinned: true,
        automaticallyImplyLeading: false,
        backgroundColor: c.background,
        leading: GlassBackButton(onPressed: _backButtonSteps),
        title: Text(translate(AppStrings.bookingOrder)),
      ),
      SliverToBoxAdapter(
        child: isLoading ? const KSkeleton.details() : bookingScreen[indexPage],
      ),
      _buildActionClearance(),
    ];
  }

  /// Keeps Home's end just above the tab bar, or above the booking action for
  /// subscribers, who get one without choosing a service.
  Widget _buildHomeClearance() {
    final bool subscribed =
        sl<GetUserProfileBloc>().profile.isSubscribed == true;
    return subscribed
        ? _buildActionClearance()
        : SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom + KSpace.l,
            ),
          );
  }

  /// Keeps the last content clear of the floating booking action and tab bar.
  Widget _buildActionClearance() {
    return SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 96),
    );
  }

  /// Photo header holding the address, greeting and the wash card (Photo hero).
  Widget _buildPhotoHero(KColors c) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                // Melts the photo into the page behind the card.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const <double>[0, 0.55, 1],
                  colors: <Color>[
                    KColors.light.brand.withValues(alpha: 0.72),
                    KColors.light.brand.withValues(alpha: 0.55),
                    c.background,
                  ],
                ),
              ),
              child: Image.asset(
                'assets/images/on_boarding_3.png',
                fit: BoxFit.cover,
                cacheWidth:
                    (MediaQuery.sizeOf(context).width *
                            MediaQuery.devicePixelRatioOf(context))
                        .round(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.paddingOf(context).top),
              Row(
                children: <Widget>[
                  const SizedBox(width: KSpace.s),
                  Expanded(child: _buildAddress(c)),
                  _buildPoints(),
                  const SizedBox(width: KSpace.s),
                  _buildNotifications(c),
                  const SizedBox(width: KSpace.s),
                ],
              ),
              BlocBuilder<GetUserProfileBloc, GetUserProfileState>(
                builder: (BuildContext context, GetUserProfileState state) {
                  final String name = state is GetUserProfileSuccess
                      ? (state.userProfile.data?.userName ?? '')
                            .split(' ')
                            .first
                      : '';
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KSpace.l,
                      KSpace.s,
                      KSpace.l,
                      KSpace.l,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${translate(AppStrings.hello)} $name'.trim(),
                          style: KType.largeTitle.copyWith(color: Colors.white),
                        ),
                        Text(
                          translate('homeTagline'),
                          style: KType.subhead.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (_isGuest)
                const SizedBox(height: KSpace.xxl)
              else
                _buildActiveOrder(showStages: true, light: true),
            ],
          ),
        ],
      ),
    );
  }

  /// The saved address the booking goes to, always one tap from changing.
  Widget _buildAddress(KColors c) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (BuildContext context, LocationState state) {
        final List<AddressModel> saved = context
            .read<LocationBloc>()
            .savedLocation;
        if (saved.isEmpty) return const SizedBox.shrink();
        final AddressModel address = saved.firstWhere(
          (AddressModel a) => a.isDefault == true,
          orElse: () => saved.first,
        );
        final String label = address.savedName?.isNotEmpty == true
            ? address.savedName!
            : address.streetName ?? translate(AppStrings.defaultAddress);
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: KChipButton(
            leading: const Icon(Icons.location_on_rounded),
            trailing: const Icon(Icons.keyboard_arrow_down_rounded),
            label: label,
            onPhoto: true,
            onTap: () => pushPage(context, SetBookingLocationScreen()),
          ),
        );
      },
    );
  }

  Widget _buildPoints() {
    final Widget coin = SvgPicture.asset(
      AssetsManager.walletCoin,
      height: 16,
      width: 16,
    );
    if (_isGuest) {
      return KChipButton(
        leading: coin,
        label: '0',
        onPhoto: true,
        semanticLabel: translate(AppStrings.points),
        onTap: () => AlertHelper.pointAlert(context),
      );
    }
    return BlocBuilder<GetUserProfileBloc, GetUserProfileState>(
      builder: (BuildContext context, GetUserProfileState state) {
        return KChipButton(
          leading: coin,
          label: '${points ?? 0}',
          onPhoto: true,
          semanticLabel: translate(AppStrings.points),
          onTap: () => AlertHelper.pointAlert(context),
        );
      },
    );
  }

  Widget _buildNotifications(KColors c) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        GlassBarButton(
          icon: Icons.notifications_none_rounded,
          sfSymbol: 'bell',
          color: Colors.white,
          style: GlassButtonStyle.clear,
          tooltip: translate(AppStrings.notifications),
          onPressed: () {
            pushPage(
              context,
              _isGuest
                  ? const GuestNotificationScreen()
                  : const NotificationsScreen(),
            );
            if (mounted) {
              setState(() {
                generalSingleton.hasUnreadNotification = false;
              });
            }
          },
        ),
        if (generalSingleton.hasUnreadNotification)
          PositionedDirectional(
            top: KSpace.s,
            end: KSpace.s,
            child: IgnorePointer(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: c.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// One card at most: the wash in progress, else the last wash to book again.
  /// New customers see neither. Own blocs, so the Bookings tab is not disturbed.
  Widget _buildActiveOrder({bool showStages = false, bool light = false}) {
    return BlocBuilder<MyBookingBloc, MyBookingState>(
      bloc: _activeOrders,
      builder: (BuildContext context, MyBookingState active) {
        if (active.activeList.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(KSpace.l, 0, KSpace.l, KSpace.l),
            child: ActiveOrderCard(
              order: active.activeList.first,
              showStages: showStages,
            ),
          );
        }
        return BlocBuilder<MyBookingBloc, MyBookingState>(
          bloc: _pastOrders,
          builder: (BuildContext context, MyBookingState past) {
            final Iterable<OrderModel> done = past.historyList.where(
              (OrderModel o) =>
                  o.status == AppConstants.completed &&
                  (o.washingServices?.isNotEmpty ?? false),
            );
            if (done.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpace.l,
                0,
                KSpace.l,
                KSpace.l,
              ),
              child: BookAgainCard(
                order: done.first,
                light: light,
                onTap: () => _bookAgain(done.first),
              ),
            );
          },
        );
      },
    );
  }

  /// One action, shown once there is something to book.
  Widget _buildBookingAction() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isNotesFocused,
      builder: (BuildContext context, bool isFocused, Widget? child) {
        if ((isFocused && indexPage == 1) || isLoading) {
          return const SizedBox.shrink();
        }
        return Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.paddingOf(context).bottom + KSpace.m,
          child: BlocConsumer<BookingOrderBloc, BookingOrderState>(
            listener: (BuildContext context, BookingOrderState state) {
              if (state is CreateOrderSuccess) {
                generalSingleton.orderId = state.reviewOrderModel.data!.sId!;

                if (state.reviewOrderModel.data!.totalPay == 0.0 ||
                    state.reviewOrderModel.data!.totalPay == 0) {
                  AlertHelper.createOrderSuccess(context);
                }
              } else if (state is CreateOrderFailed) {
                if (state.errorModel!.en ==
                        AppStrings.yourWalletBalanceIsNotValid ||
                    state.errorModel!.ar ==
                        AppStrings.yourWalletBalanceIsNotValid) {
                  AlertHelper.payWithWalletNotEnoughAmount(context);
                } else {
                  showSnackBar(
                    buildContext: context,
                    message:
                        Localizations.localeOf(context).languageCode == 'en'
                        ? state.errorModel!.en!
                        : state.errorModel!.ar!,
                  );
                }
              }
            },
            builder: (BuildContext context, BookingOrderState state) {
              if (state is CreateOrderLoading) {
                return const KLoadingState();
              }

              // Hide button when services are loading
              return BlocBuilder<OffersBloc, OffersState>(
                builder: (context, offersState) {
                  if (offersState is OffersInitial ||
                      offersState is GetServicesLoading ||
                      offersState is GetAddOnsLoading ||
                      offersState is AddServiceCartLoading ||
                      offersState is DeleteServiceCartLoading ||
                      offersState is AddExtraCartLoading ||
                      offersState is DeleteExtraCartLoading ||
                      offersState is ClearCartLoading ||
                      offersState is ClearAllSelectedServicesLoading ||
                      offersState is GetGuestServicesLoading ||
                      offersState is GetGuestAddOnsLoading) {
                    return const SizedBox.shrink();
                  }

                  final offersBloc = context.read<OffersBloc>();
                  // Subscribers can book on their plan without choosing a
                  // paid service.
                  final bool subscribed =
                      sl<GetUserProfileBloc>().profile.isSubscribed == true;
                  if (indexPage == 0 && !subscribed) {
                    return const SizedBox.shrink();
                  }

                  final int servicesCount = offersBloc.cartServicesList.length;
                  final int addOnsCount = offersBloc.cartAddOnsList.length;
                  final num servicesTotal = offersBloc.cartServicesList
                      .fold<num>(
                        0,
                        (sum, service) => sum + (service.price ?? 0),
                      );
                  final num addOnsTotal = offersBloc.cartAddOnsList.fold<num>(
                    0,
                    (sum, addon) => sum + (addon.price ?? 0),
                  );
                  final num totalPrice = servicesTotal + addOnsTotal;

                  return TotalPayCard(
                    onTap: _nextButtonSteps,
                    text: indexPage == 0
                        ? translate(AppStrings.nextButton)
                        : translate(AppStrings.confirmButton),
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
        );
      },
    );
  }
}
