import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/biker_details.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/tabs_service_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/vechilce_details.dart';
import 'package:thewasher/modules/my_booking/widgets/your_rating.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class WashDetailsScreen extends StatefulWidget {
  final String orderId;
  const WashDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<WashDetailsScreen> createState() => _WashDetailsScreenState();
}

class _WashDetailsScreenState extends State<WashDetailsScreen> {
  @override
  void initState() {
    super.initState();
    sl<BookingOrderBloc>().add(GetOrderById(orderId: widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(1.sw, AppSize.s60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.washDetails),
          isTextOnly: false,
        ),
      ),
      body: BlocConsumer<BookingOrderBloc, BookingOrderState>(
        listener: (context, state) {
          if (state is OrderByIdFailed) {
            showSnackBar(
                buildContext: context,
                message: state.error != null
                    ? state.error!
                    : Localizations.localeOf(context).languageCode == 'en'
                        ? state.errorModel!.en!
                        : state.errorModel!.ar!);
          }
        },
        builder: (context, state) {
          if (state is OrderByIdLoading) {
            return const LoadingWidget();
          } else if (state is OrderByIdSuccess) {
            final bookingDate = state.orderModel.createdAt != null
                ? DateTime.parse(state.orderModel.createdAt!)
                : DateTime.now();
            final washingDate = state.orderModel.startTime != null
                ? DateTime.parse(state.orderModel.startTime!)
                : null;
            return Padding(
              padding: EdgeInsets.all(
                AppPadding.p24.r,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Modern Order Header Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorManager.primary,
                            ColorManager.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate(AppStrings.requestID),
                                      style: AppStyles.caption12Medium.copyWith(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "# ${(state.orderModel.sId != null && state.orderModel.sId!.length > 6) ? state.orderModel.sId!.substring(state.orderModel.sId!.length - 6) : state.orderModel.sId ?? "N/A"}",
                                      style: AppStyles.title16Bold.copyWith(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (state.orderModel.status ==
                                  "CANCELLED_BY_USER")
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "Cancelled",
                                    style: AppStyles.caption12Medium.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else if (state.orderModel.status ==
                                      AppConstants.active ||
                                  state.orderModel.status ==
                                      AppConstants.waitingForBikerByAdmin ||
                                  state.orderModel.status ==
                                      AppConstants.orderWaitingForAdmin)
                                GestureDetector(
                                  onTap: () {
                                    AlertHelper.cancelBooking(
                                      context,
                                      state.orderModel.sId!,
                                      true,
                                    ).then((value) {
                                      sl<BookingOrderBloc>().add(GetOrderById(
                                          orderId: widget.orderId));
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 20.w,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          // Status and Payment Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          _getStatusText(
                                              state.orderModel.status ?? ''),
                                          style: AppStyles.caption12Medium
                                              .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getPaymentTypeText(
                                        state.orderModel.paymentType ?? ''),
                                    style: AppStyles.caption12Medium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppPadding.p20.ph,
                    if (state.orderModel.biker != null)
                      BikerDetails(
                        biker: state.orderModel.biker!,
                        location: state.orderModel.location!,
                      ),
                    AppPadding.p16.ph,
                    // Service Location Map
                    if (state.orderModel.location != null)
                      _buildServiceLocationCard(state.orderModel),
                    AppPadding.p16.ph,
                    if (state.orderModel.status == AppConstants.completed)
                      YourRating(
                        orderId: state.orderModel.sId!,
                        orderRating: state.orderModel.ratingOfBiker!,
                      ),
                    if (state.orderModel.status == AppConstants.completed)
                      AppPadding.p18.ph,
                    AppPadding.p18.ph,
                    if (state.orderModel.vehicle != null)
                      VechilceDetails(
                        vehicle: state.orderModel.vehicle!,
                      ),
                    AppPadding.p18.ph,
                    // Description Section
                    if (state.orderModel.description != null &&
                        state.orderModel.description!.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color:
                                        ColorManager.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.description,
                                    color: ColorManager.primary,
                                    size: 20.w,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  translate(AppStrings.description),
                                  style: AppStyles.title16Bold.copyWith(
                                    color: ColorManager.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              state.orderModel.description!,
                              style: AppStyles.subtext14Regular.copyWith(
                                color: ColorManager.black,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 10.verticalSpace,
                    ],
                    // Car Freshened Status
                    if (state.orderModel.isCarFreshened == true) ...[
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorManager.green.withValues(alpha: 0.1),
                              ColorManager.green.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: ColorManager.green.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: ColorManager.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.air,
                                color: ColorManager.green,
                                size: 24.w,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translate(AppStrings.carFreshened),
                                    style: AppStyles.title16Bold.copyWith(
                                      color: ColorManager.black,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.green,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    translate(AppStrings.applied),
                                    style: AppStyles.caption12Medium.copyWith(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppPadding.p18.ph,
                    ],
                    AppPadding.p20.ph,
                    // Modern Date and Rating Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Booking Date
                          _buildModernInfoRow(
                            icon: Icons.calendar_today,
                            title: translate(AppStrings.bookingDate),
                            subtitle:
                                '${AppDateFormatter.allDate(bookingDate)} ${AppDateFormatter.dateToStringHHMMA(bookingDate.toLocal())}',
                            iconColor: ColorManager.primary,
                          ),
                          if (washingDate != null) ...[
                            SizedBox(height: 16.h),
                            _buildModernInfoRow(
                              icon: Icons.wash,
                              title: translate(AppStrings.washingDate),
                              subtitle:
                                  '${AppDateFormatter.allDate(washingDate)} ${AppDateFormatter.dateToStringHHMMA(washingDate.toLocal())}',
                              iconColor: ColorManager.green,
                            ),
                          ],
                          if (state.orderModel.ratingOfBiker != null) ...[
                            SizedBox(height: 16.h),
                            _buildModernInfoRow(
                              icon: Icons.star,
                              title: "Rating",
                              subtitle:
                                  "${state.orderModel.ratingOfBiker?.toStringAsFixed(1) ?? '0.0'}/5.0",
                              iconColor: Colors.amber,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...List.generate(
                                    state.orderModel.ratingOfBiker?.toInt() ??
                                        0,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(right: 2.w),
                                      child: SvgPicture.asset(
                                        AssetsManager.starSelected,
                                        height: 16.h,
                                        width: 16.w,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(
                                    5 -
                                        (state.orderModel.ratingOfBiker
                                                ?.toInt() ??
                                            0),
                                    (index) => Padding(
                                      padding: EdgeInsets.only(right: 2.w),
                                      child: SvgPicture.asset(
                                        AssetsManager.starUnselected,
                                        height: 16.h,
                                        width: 16.w,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppPadding.p20.ph,
                    // Modern Pricing Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorManager.primary.withValues(alpha: 0.05),
                            ColorManager.primary.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: ColorManager.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: ColorManager.primary,
                                  size: 20.w,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                translate(AppStrings.paymentSummary),
                                style: AppStyles.title16Bold.copyWith(
                                  color: ColorManager.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // Total Price Row
                          _buildPriceRow(
                            label: translate(AppStrings.total),
                            amount: state.orderModel.totalPrice ?? 0,
                            isTotal: false,
                          ),
                          // Discount Row (if applicable)
                          if ((state.orderModel.totalPrice ?? 0) >
                              (state.orderModel.totalPay ?? 0)) ...[
                            SizedBox(height: 12.h),
                            _buildPriceRow(
                              label: translate(AppStrings.discount),
                              amount: (state.orderModel.totalPrice ?? 0) -
                                  (state.orderModel.totalPay ?? 0),
                              isDiscount: true,
                            ),
                          ],
                          SizedBox(height: 16.h),
                          // Divider
                          Container(
                            height: 1,
                            color: ColorManager.divider.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 16.h),
                          // Total Pay Row
                          _buildPriceRow(
                            label: translate(AppStrings.totalPay),
                            amount: state.orderModel.totalPay ?? 0,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    // AppPadding.p20.ph,
                    // // Before/After Images Section
                    // if (state.orderModel.beforeWashImage != null ||
                    //     state.orderModel.afterWashImage != null)
                    //   _buildBeforeAfterImages(state.orderModel.beforeWashImage!,
                    //       state.orderModel.afterWashImage!),
                    // AppPadding.p20.ph,
                    TabsServicesAndAddOns(
                      addOnsModel: state.orderModel.addOns!,
                      services: state.orderModel.washingServices!,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildServiceLocationCard(OrderModel location) {
    // Extract coordinates from location object
    double? latitude;
    double? longitude;
    String locationName = "Service Location";

    // Try to get coordinates from different possible field names
    latitude = location.location?.latitude ?? 0.0;
    longitude = location.location?.longitude ?? 0.0;
    locationName = location.location?.streetName ??
        location.location?.subAdministrativeArea ??
        location.location?.savedName ??
        "Service Location";

    // Default to Riyadh if no coordinates
    if (latitude == 0.0 || longitude == 0.0) {
      latitude = 24.7136;
      longitude = 46.6753;
    }

    final LatLng serviceLocation = LatLng(latitude, longitude);

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.location_on,
                  color: ColorManager.primary,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                translate(AppStrings.serviceLocation),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Interactive Map
          GestureDetector(
            onTap: () => _openFullScreenMap(serviceLocation, locationName),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 180.h,
                      width: double.infinity,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: serviceLocation,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('service_location'),
                            position: serviceLocation,
                            infoWindow: InfoWindow(
                              title: translate(AppStrings.serviceLocation),
                              snippet: locationName,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          ),
                        },
                        circles: {
                          Circle(
                            circleId: const CircleId('service_area'),
                            center: serviceLocation,
                            radius: 100,
                            fillColor: ColorManager.red.withValues(alpha: 0.2),
                            strokeWidth: 2,
                            strokeColor: ColorManager.red,
                          ),
                        },
                        scrollGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                    // Map overlay with tap indicator
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 16.w,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  translate(AppStrings.tapToViewFullMap),
                                  style: AppStyles.caption12Medium.copyWith(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Location Details
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: ColorManager.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: ColorManager.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.place,
                        color: ColorManager.primary,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate(AppStrings.serviceAddress),
                            style: AppStyles.caption12Medium.copyWith(
                              color: ColorManager.medGray,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            locationName,
                            style: AppStyles.subtext14Regular.copyWith(
                              color: ColorManager.black,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterImages(
      String beforeWashImage, String afterWashImage) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.photo_camera,
                  color: ColorManager.primary,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Car Images",
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildImageCard(
                  imageUrl: beforeWashImage,
                  title: "Before Wash",
                  isBefore: true,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildImageCard(
                  imageUrl: afterWashImage,
                  title: "After Wash",
                  isBefore: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required String imageUrl,
    required String title,
    required bool isBefore,
  }) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl, title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: (isBefore ? ColorManager.red : ColorManager.green)
                  .withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isBefore ? ColorManager.red : ColorManager.green,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 200,
                      maxWidthDiskCache: 600,
                      maxHeightDiskCache: 400,
                      placeholder: (context, url) => Container(
                        color: ColorManager.lightGray,
                        child: Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isBefore
                                    ? ColorManager.red
                                    : ColorManager.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: ColorManager.lightGray,
                        child: Icon(
                          Icons.image_not_supported,
                          color: ColorManager.medGray,
                          size: 40.sp,
                        ),
                      ),
                    ),
                    // Status badge
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isBefore ? ColorManager.red : ColorManager.green)
                                  .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isBefore ? "BEFORE" : "AFTER",
                          style: AppStyles.caption12Medium.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Zoom icon overlay
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: AppStyles.subtext14Regular.copyWith(
                color: isBefore ? ColorManager.red : ColorManager.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrl: imageUrl,
          title: title,
        ),
      ),
    );
  }

  void _openFullScreenMap(LatLng latLng, String locationName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenMapView(
          latLng: latLng,
          locationName: locationName,
        ),
      ),
    );
  }

  Widget _buildModernInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.caption12Medium.copyWith(
                  color: ColorManager.medGray,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppStyles.subtext14Regular.copyWith(
                  color: ColorManager.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double amount,
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    Color textColor = isTotal
        ? ColorManager.primary
        : isDiscount
            ? ColorManager.green
            : ColorManager.black;

    double fontSize = isTotal ? 16.sp : 14.sp;
    FontWeight fontWeight = isTotal ? FontWeight.bold : FontWeight.w500;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.subtext14Regular.copyWith(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        Row(
          children: [
            Text(
              '${isDiscount ? '-' : ''}${amount.toStringAsFixed(0)} ',
              style: AppStyles.subtext14Regular.copyWith(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
            SvgPicture.asset(
              AssetsManager.saudiRiyalSymbol,
              height: isTotal ? 16.h : 14.h,
              width: isTotal ? 16.w : 14.w,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for status display
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING_USER_PAYMENT':
        return const Color.fromRGBO(255, 193, 7, 0.1);
      case 'PENDING_USER_REVIEW':
        return const Color.fromRGBO(255, 193, 7, 0.1);
      case 'ACTIVE':
        return const Color.fromRGBO(76, 175, 80, 0.1);
      case 'CANCELLED_BY_USER':
        return Colors.red.withValues(alpha: 0.1);
      case 'CANCELLED_BY_ADMIN':
        return Colors.red.withValues(alpha: 0.1);
      case 'ACCEPTED_BY_BIKER':
        return const Color.fromRGBO(111, 251, 76, 0.1);
      case 'WAITING_FOR_BIKER_BY_ADMIN':
        return const Color.fromRGBO(33, 150, 243, 0.1);
      case 'BIKER_ON_THE_WAY':
        return const Color.fromRGBO(103, 135, 198, 0.1);
      case 'CANCELLED_BY_BIKER':
        return Colors.red.withValues(alpha: 0.1);
      case 'BIKER_ARRIVED':
        return const Color.fromRGBO(251, 174, 76, 0.1);
      case 'ON_WASHING':
        return const Color.fromRGBO(255, 228, 54, 0.1);
      case 'COMPLETED':
        return const Color.fromRGBO(245, 240, 250, 1);
      case 'SCHEDULED':
        return const Color.fromRGBO(156, 39, 176, 0.1);
      default:
        return ColorManager.divider;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING_USER_PAYMENT':
        return translate(AppStrings.pendingPayment);
      case 'PENDING_USER_REVIEW':
        return translate(AppStrings.pendingReview);
      case 'ACTIVE':
        return translate(AppStrings.active);
      case 'CANCELLED_BY_USER':
        return translate(AppStrings.cancelledByUser);
      case 'CANCELLED_BY_ADMIN':
        return translate(AppStrings.cancelledByAdmin);
      case 'ACCEPTED_BY_BIKER':
        return translate(AppStrings.accepted);
      case 'WAITING_FOR_BIKER_BY_ADMIN':
        return translate(AppStrings.waitingForBiker);
      case 'BIKER_ON_THE_WAY':
        return translate(AppStrings.onTheWay);
      case 'CANCELLED_BY_BIKER':
        return translate(AppStrings.cancelledByBiker);
      case 'BIKER_ARRIVED':
        return translate(AppStrings.arrived);
      case 'ON_WASHING':
        return translate(AppStrings.inProgress);
      case 'COMPLETED':
        return translate(AppStrings.ended);
      case 'SCHEDULED':
        return translate(AppStrings.schedule);
      default:
        return status;
    }
  }

  // Helper method for payment type display
  String _getPaymentTypeText(String paymentType) {
    switch (paymentType) {
      case 'WALLET':
        return translate(AppStrings.wallet);
      case 'CREDIT':
        return translate(AppStrings.creditCards);
      case 'SUBSCRIBED':
        return translate(AppStrings.subscribed);
      case 'APPLE_PAY':
        return translate(AppStrings.applePay);
      case 'FREE':
        return translate(AppStrings.free);
      default:
        return paymentType;
    }
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        backgroundColor: ColorManager.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorManager.white,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: AppStyles.title16Bold.copyWith(
            color: ColorManager.white,
          ),
        ),
        centerTitle: true,
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: BoxDecoration(
          color: ColorManager.black,
        ),
        enableRotation: true,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 40.w,
            height: 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorManager.primary,
              ),
            ),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: ColorManager.white,
                size: 60.sp,
              ),
              16.verticalSpace,
              Text(
                "Error Loading Image",
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenMapView extends StatefulWidget {
  final LatLng latLng;
  final String locationName;

  const _FullScreenMapView({
    required this.latLng,
    required this.locationName,
  });

  @override
  State<_FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<_FullScreenMapView> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers = {
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
    return Scaffold(
      backgroundColor: ColorManager.gray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        title: Text(
          translate(AppStrings.serviceLocation),
          style: AppStyles.title16Bold.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.w, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.white, size: 20.w),
            onPressed: () {
              _mapController.animateCamera(
                CameraUpdate.newLatLngZoom(widget.latLng, 16),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: 16,
            ),
            markers: _markers,
            circles: {
              Circle(
                circleId: const CircleId('service_area'),
                center: widget.latLng,
                radius: 100,
                fillColor: ColorManager.red.withValues(alpha: 0.2),
                strokeWidth: 2,
                strokeColor: ColorManager.red,
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
          // Location info card
          Positioned(
            bottom: 20.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.place,
                          color: ColorManager.primary,
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate(AppStrings.serviceAddress),
                              style: AppStyles.caption12Medium.copyWith(
                                color: ColorManager.medGray,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              widget.locationName,
                              style: AppStyles.subtext14Regular.copyWith(
                                color: ColorManager.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: ColorManager.medGray,
                        size: 16.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "Lat: ${widget.latLng.latitude.toStringAsFixed(6)}, Lng: ${widget.latLng.longitude.toStringAsFixed(6)}",
                          style: AppStyles.caption12Medium.copyWith(
                            color: ColorManager.medGray,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
