import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/design/components/k_stage_bar.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_chip_button.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/biker_details.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_card.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/tabs_service_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/vechilce_details.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_photos.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_section.dart';
import 'package:thewasher/modules/my_booking/widgets/your_rating.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';
import 'package:thewasher/utilties/navigator.dart';

class WashDetailsScreen extends StatefulWidget {
  final String orderId;
  const WashDetailsScreen({super.key, required this.orderId});

  @override
  State<WashDetailsScreen> createState() => _WashDetailsScreenState();
}

class _WashDetailsScreenState extends State<WashDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      sl<BookingOrderBloc>().add(GetOrderById(orderId: widget.orderId));

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 60,
        leading: GlassBackButton(color: c.brand, onPressed: () => pop(context)),
        title: Text(
          translate(AppStrings.washDetails),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: BlocConsumer<BookingOrderBloc, BookingOrderState>(
        listener: (BuildContext context, BookingOrderState state) {
          if (state is OrderByIdFailed) {
            showSnackBar(
              buildContext: context,
              message: state.error != null
                  ? state.error!
                  : Localizations.localeOf(context).languageCode == 'en'
                  ? state.errorModel!.en!
                  : state.errorModel!.ar!,
            );
          }
        },
        builder: (BuildContext context, BookingOrderState state) {
          if (state is OrderByIdLoading) {
            return const KLoadingState();
          }
          if (state is OrderByIdFailed) {
            return KErrorState(
              message: translate('somethingWentWrong'),
              onRetry: _load,
            );
          }
          if (state is OrderByIdSuccess) {
            return _details(context, state.orderModel);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _details(BuildContext context, OrderModel order) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.s,
        KSpace.xl,
        MediaQuery.paddingOf(context).bottom + KSpace.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: KSpace.xl,
        children: <Widget>[
          _OrderHeader(order: order, onCancelled: _load),
          WashPhotos(
            before: order.beforeWashImage,
            after: order.afterWashImage,
          ),
          if (order.biker != null)
            BikerDetails(biker: order.biker!, location: order.location!),
          if (order.location != null) _ServiceLocationCard(order: order),
          if (order.status == AppConstants.completed)
            YourRating(orderId: order.sId!, orderRating: order.ratingOfBiker!),
          if (order.vehicle != null) VechilceDetails(vehicle: order.vehicle!),
          if (order.description != null && order.description!.isNotEmpty)
            WashSection(
              title: translate(AppStrings.description),
              child: Text(
                order.description!,
                style: KType.subhead.copyWith(color: KColors.of(context).text),
              ),
            ),
          if (order.isCarFreshened == true) const _CarFreshenedCard(),
          _DatesCard(order: order),
          _PaymentSummary(order: order),
          TabsServicesAndAddOns(
            addOnsModel: order.addOns!,
            services: order.washingServices!,
          ),
        ],
      ),
    );
  }
}

/// The statuses that sit on the wash's stage bar.
const Set<String> _liveStatuses = <String>{
  AppConstants.acceptedByBiker,
  AppConstants.bikerOnTheWay,
  AppConstants.bikerArrived,
  AppConstants.onWashing,
  AppConstants.completed,
};

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order, required this.onCancelled});

  final OrderModel order;
  final VoidCallback onCancelled;

  bool get _canCancel =>
      order.status == AppConstants.active ||
      order.status == AppConstants.waitingForBikerByAdmin ||
      order.status == AppConstants.orderWaitingForAdmin;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String? id = order.sId;
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      translate(AppStrings.requestID),
                      style: KType.footnote.copyWith(color: c.textSecondary),
                    ),
                    Text(
                      "# ${(id != null && id.length > 6) ? id.substring(id.length - 6) : id ?? "N/A"}",
                      style: KType.title.copyWith(color: c.text),
                    ),
                  ],
                ),
              ),
              if (_canCancel)
                IconButton(
                  tooltip: translate(AppStrings.cancelOrder),
                  icon: Icon(Icons.delete_outline, color: c.error),
                  onPressed: () {
                    AlertHelper.cancelBooking(context, order.sId!, true).then((
                      _,
                    ) {
                      onCancelled();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: KSpace.m),
          Wrap(
            spacing: KSpace.s,
            runSpacing: KSpace.xs,
            children: <Widget>[
              KStatusChip(
                label: MyBookingCard.statusText(order.status ?? ''),
                status: MyBookingCard.statusKind(order.status ?? ''),
              ),
              if ((order.paymentType ?? '').isNotEmpty)
                KStatusChip(
                  label: MyBookingCard.paymentTypeText(order.paymentType!),
                  status: KStatus.neutral,
                ),
            ],
          ),
          if (_liveStatuses.contains(order.status)) ...<Widget>[
            const SizedBox(height: KSpace.l),
            KStageBar(
              step: getStepData(order.status!).step,
              stages: <String>[
                translate(AppStrings.onTheWay),
                translate(AppStrings.arrived),
                translate(AppStrings.washing),
                translate(AppStrings.completed),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceLocationCard extends StatelessWidget {
  const _ServiceLocationCard({required this.order});

  static const double _mapHeight = 180;

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    double latitude = order.location?.latitude ?? 0.0;
    double longitude = order.location?.longitude ?? 0.0;
    final String locationName =
        order.location?.streetName ??
        order.location?.subAdministrativeArea ??
        order.location?.savedName ??
        translate(AppStrings.serviceLocation);

    // Default to Riyadh if no coordinates
    if (latitude == 0.0 || longitude == 0.0) {
      latitude = 24.7136;
      longitude = 46.6753;
    }
    final LatLng serviceLocation = LatLng(latitude, longitude);

    void openFullMap() {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => _FullScreenMapView(
            latLng: serviceLocation,
            locationName: locationName,
          ),
        ),
      );
    }

    return WashSection(
      title: translate(AppStrings.serviceLocation),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: _mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: serviceLocation,
                    zoom: 15,
                  ),
                  markers: <Marker>{
                    Marker(
                      markerId: const MarkerId('service_location'),
                      position: serviceLocation,
                      infoWindow: InfoWindow(
                        title: translate(AppStrings.serviceLocation),
                        snippet: locationName,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                  circles: <Circle>{
                    Circle(
                      circleId: const CircleId('service_area'),
                      center: serviceLocation,
                      radius: 100,
                      fillColor: c.error.withValues(alpha: 0.2),
                      strokeWidth: 2,
                      strokeColor: c.error,
                    ),
                  },
                  scrollGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  mapToolbarEnabled: false,
                ),
                // Covers the map so a tap anywhere opens the full map.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: openFullMap,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(KSpace.m),
                      child: KChipButton(
                        label: translate(AppStrings.tapToViewFullMap),
                        leading: const Icon(Icons.fullscreen),
                        maxWidth: double.infinity,
                        onTap: openFullMap,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          KListRow(
            leading: SizedBox.square(
              dimension: KSpace.xxl,
              child: Icon(Icons.place, color: c.brand),
            ),
            title: translate(AppStrings.serviceAddress),
            subtitle: locationName,
          ),
        ],
      ),
    );
  }
}

class _CarFreshenedCard extends StatelessWidget {
  const _CarFreshenedCard();

  @override
  Widget build(BuildContext context) {
    return KCard(
      padding: EdgeInsets.zero,
      child: KListRow(
        leading: SizedBox.square(
          dimension: KSpace.xxl,
          child: Icon(Icons.air, color: KColors.of(context).success),
        ),
        title: translate(AppStrings.carFreshened),
        trailing: KStatusChip(
          label: translate(AppStrings.applied),
          status: KStatus.success,
        ),
      ),
    );
  }
}

class _DatesCard extends StatelessWidget {
  const _DatesCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final DateTime bookingDate = order.createdAt != null
        ? DateTime.parse(order.createdAt!)
        : DateTime.now();
    final DateTime? washingDate = order.startTime != null
        ? DateTime.parse(order.startTime!)
        : null;

    Widget icon(IconData data, Color color) => SizedBox.square(
      dimension: KSpace.xxl,
      child: Icon(data, color: color),
    );

    return KCard(
      padding: EdgeInsets.zero,
      child: WashRows(
        rows: <Widget>[
          KListRow(
            leading: icon(Icons.calendar_today, c.brand),
            title: translate(AppStrings.bookingDate),
            subtitle:
                '${AppDateFormatter.allDate(bookingDate)} ${AppDateFormatter.dateToStringHHMMA(bookingDate.toLocal())}',
          ),
          if (washingDate != null)
            KListRow(
              leading: icon(Icons.wash, c.success),
              title: translate(AppStrings.washingDate),
              subtitle:
                  '${AppDateFormatter.allDate(washingDate)} ${AppDateFormatter.dateToStringHHMMA(washingDate.toLocal())}',
            ),
          if ((order.ratingOfBiker ?? 0) > 0)
            KListRow(
              leading: icon(Icons.star, c.warning),
              title: translate(AppStrings.yourRating),
              subtitle: "${order.ratingOfBiker!.toStringAsFixed(1)}/5.0",
              trailing: _RatingStars(rating: order.ratingOfBiker!.toInt()),
            ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: <Widget>[
        for (int i = 0; i < 5; i++)
          SvgPicture.asset(
            i < rating
                ? AssetsManager.starSelected
                : AssetsManager.starUnselected,
            height: KSpace.l,
            width: KSpace.l,
          ),
      ],
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final double total = order.totalPrice ?? 0;
    final double pay = order.totalPay ?? 0;
    return WashSection(
      title: translate(AppStrings.paymentSummary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PriceRow(label: translate(AppStrings.total), amount: total),
          if (total > pay) ...<Widget>[
            const SizedBox(height: KSpace.s),
            _PriceRow(
              label: translate(AppStrings.discount),
              amount: total - pay,
              isDiscount: true,
            ),
          ],
          Divider(height: KSpace.xxl, color: KColors.of(context).separator),
          _PriceRow(
            label: translate(AppStrings.totalPay),
            amount: pay,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isDiscount = false,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Color color = isTotal
        ? c.brand
        : isDiscount
        ? c.success
        : c.text;
    final TextStyle style = (isTotal ? KType.headline : KType.subhead).copyWith(
      color: color,
    );
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: style)),
        Text(
          '${isDiscount ? '-' : ''}${amount.toStringAsFixed(0)} ',
          style: style,
        ),
        SvgPicture.asset(
          AssetsManager.saudiRiyalSymbol,
          height: isTotal ? KSpace.l : KSpace.m,
          width: isTotal ? KSpace.l : KSpace.m,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ],
    );
  }
}

class _FullScreenMapView extends StatefulWidget {
  final LatLng latLng;
  final String locationName;

  const _FullScreenMapView({required this.latLng, required this.locationName});

  @override
  State<_FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<_FullScreenMapView> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _markers = <Marker>{
      Marker(
        markerId: const MarkerId('service_location'),
        position: widget.latLng,
        infoWindow: InfoWindow(
          title: translate(AppStrings.serviceLocation),
          snippet: widget.locationName,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 60,
        leading: GlassBackButton(
          color: c.brand,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          translate(AppStrings.serviceLocation),
          style: KType.headline.copyWith(color: c.text),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: KSpace.s),
            child: GlassBarButton(
              icon: Icons.my_location,
              sfSymbol: 'location',
              color: c.brand,
              tooltip: translate(AppStrings.serviceLocation),
              onPressed: () {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.latLng, 16),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: 16,
            ),
            markers: _markers,
            circles: <Circle>{
              Circle(
                circleId: const CircleId('service_area'),
                center: widget.latLng,
                radius: 100,
                fillColor: c.error.withValues(alpha: 0.2),
                strokeWidth: 2,
                strokeColor: c.error,
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
          PositionedDirectional(
            start: KSpace.l,
            end: KSpace.l,
            bottom: MediaQuery.paddingOf(context).bottom + KSpace.l,
            child: KCard(
              padding: EdgeInsets.zero,
              child: KListRow(
                leading: SizedBox.square(
                  dimension: KSpace.xxl,
                  child: Icon(Icons.place, color: c.brand),
                ),
                title: translate(AppStrings.serviceAddress),
                subtitle:
                    "${widget.locationName}\nLat: ${widget.latLng.latitude.toStringAsFixed(6)}, Lng: ${widget.latLng.longitude.toStringAsFixed(6)}",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
