import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:thewhsherbiker/core/resources/app_bar.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/car_details_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/user_details_widget.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/modules/order/widgets/tabs_service_and_addons.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/rating_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel data;
  final bool complete;
  final int? index;
  const OrderDetailsScreen(
      {Key? key, required this.data, required this.complete, this.index})
      : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375.w, AppSize.s60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.washDetails),
          isTextOnly: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p24.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              24.verticalSpace,
              UserDetailsWidget(
                userData: widget.data,
                textStyle: AppStyles.title16Bold,
              ),
              // if (widget.complete) 20.verticalSpace,
              // if (widget.complete) _rating(),
              20.verticalSpace,
              if (widget.data.vehicle != null)
                CarDetailsWidget(carData: widget.data.vehicle),

              if (widget.data.startTime != null)
                RowInfoWidget(
                  title: translate(AppStrings.washingDate),
                  infoText:
                      '${AppDateFormatter.allDate(widget.data.startTime!)} ${AppDateFormatter.dateToStringHHMMA(widget.data.startTime!.toLocal())}',
                ),
              if (widget.data.description != null)
                RowInfoWidget(
                  title: translate(AppStrings.notes),
                  infoText: '${widget.data.description!} ',
                ),
              3.verticalSpace,
              // Car Freshened Status
              if (widget.data.isCarFreshened == true)
                Container(
                  margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorManager.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.air,
                        color: ColorManager.green,
                        size: 20.sp,
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Text(
                          translate('Car Freshener'),
                          style: AppStyles.body14Medium.copyWith(
                            color: ColorManager.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.data.isCarFreshened != true) 16.verticalSpace,
              // Before and After Images
              // if (widget.data.beforeWashImage != null ||
              //     widget.data.afterWashImage != null)
              //   _buildBeforeAfterImages(),
              // 16.verticalSpace,
              if (widget.data.addOns != null &&
                  widget.data.washingServices != null)
                TabsServicesAndAddOns(
                  addOnsModel: widget.data.addOns!,
                  services: widget.data.washingServices!,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          !widget.complete ? _bottomSheetActionOrder(context) : null,
    );
  }

  Container _bottomSheetActionOrder(BuildContext context) {
    return Container(
      height: 79.h,
      width: 375.w,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
      decoration:
          BoxDecoration(color: ColorManager.white, boxShadow: <BoxShadow>[
        BoxShadow(
            color: ColorManager.black.withOpacity(.16),
            blurRadius: 6.r,
            offset: const Offset(0, 3))
      ]),
      child: Row(
        children: <Widget>[
          BlocConsumer<HomeBloc, HomeState>(
            listener: (BuildContext context, HomeState state) {
              if (state is BikerAcceptOrderSuccess) {
                if (state.details) {
                  _navigateToOrderDetails();
                }
              }
            },
            builder: (BuildContext context, HomeState state) {
              if (state is BikerAcceptOrderLoading) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
                  child: SizedBox(
                    height: 50.h,
                    child: const LoadingWidget(),
                  ),
                );
              } else {
                return ButtonsShared(
                  height: 50.h,
                  width: 164.w,
                  onPressed: _handleButtonPress,
                  text: translate(AppStrings.accept),
                  borderRadius: 25,
                  textStyle: AppStyles.body14Medium,
                );
              }
            },
          ),
          SizedBox(
            width: 90.w,
          ),
          InkWell(
            onTap: () {
              pop(context);
            },
            child: Text(
              translate(AppStrings.back),
              style: AppStyles.subtext14Regular.copyWith(
                color: ColorManager.medGray,
                decorationColor: ColorManager.medGray,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              translate(AppStrings.clientRatingForYou),
              style: AppStyles.body14Medium.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
            SizedBox(
              width: 73.5.w,
              child: Divider(
                color: ColorManager.divider,
                thickness: 1,
                height: 10.h,
              ),
            ),
            19.verticalSpace,
            IgnorePointer(
              child: RatingBarShared(
                ratingCount: widget.data.ratingOfBiker!.toDouble(),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              translate(AppStrings.yourRatingToClient),
              style: AppStyles.body14Medium.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
            SizedBox(
              width: 73.5.w,
              child: Divider(
                color: ColorManager.divider,
                thickness: 1,
                height: 10.h,
              ),
            ),
            19.verticalSpace,
            IgnorePointer(
              child: RatingBarShared(
                ratingCount: widget.data.ratingOfUser!.toDouble(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToOrderDetails() {
    Navigator.of(context).pushReplacement(createRoute(OrderChangeStatus(
      order: sl<HomeBloc>().orderDetails,
      notification: false,
    )));
  }

  Widget _buildBeforeAfterImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate(AppStrings.carImages),
          style: AppStyles.title16Bold.copyWith(
            color: ColorManager.primary,
          ),
        ),
        12.verticalSpace,
        Row(
          children: [
            // Before Image
            if (widget.data.beforeWashImage != null)
              Expanded(
                child: _buildImageCard(
                  imageUrl: widget.data.beforeWashImage!,
                  title: translate(AppStrings.beforeWash),
                  isBefore: true,
                ),
              ),
            if (widget.data.beforeWashImage != null &&
                widget.data.afterWashImage != null)
              12.horizontalSpace,
            // After Image
            if (widget.data.afterWashImage != null)
              Expanded(
                child: _buildImageCard(
                  imageUrl: widget.data.afterWashImage!,
                  title: translate(AppStrings.afterWash),
                  isBefore: false,
                ),
              ),
          ],
        ),
      ],
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
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isBefore ? ColorManager.red : ColorManager.green,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 120.h,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                ),
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
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.primary,
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
                    // Zoom icon overlay
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: ColorManager.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.zoom_in,
                          color: ColorManager.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isBefore
                    ? ColorManager.red.withOpacity(0.1)
                    : ColorManager.green.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: AppStyles.caption12Medium.copyWith(
                    color: isBefore ? ColorManager.red : ColorManager.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  void _handleButtonPress() {
    final HomeBloc homeBloc = sl<HomeBloc>();
    final AuthBloc authBloc = sl<AuthBloc>();

    final int? orderIndex = widget.index;
    final String? orderId = widget.data.sId;
    final String? latitude = authBloc.currentPosition.latitude.toString();
    final String? longitude = authBloc.currentPosition.longitude.toString();
    final String streetName = authBloc.currentAddress;
    final String subAdministrativeArea = authBloc.administrativeArea;

    if (orderIndex != null &&
        orderId != null &&
        latitude != null &&
        longitude != null) {
      homeBloc.add(BikerAcceptOrder(
        context: context,
        orderIndex: orderIndex,
        orderId: orderId,
        lat: latitude,
        lng: longitude,
        streetName: streetName,
        subAdministrativeArea: subAdministrativeArea,
        details: true,
      ));
    }
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

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
                translate(AppStrings.errorLoadingImage),
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

class RowInfoWidget extends StatelessWidget {
  const RowInfoWidget({
    super.key,
    required this.title,
    required this.infoText,
  });

  final String title;
  final String infoText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '$title :',
          style: AppStyles.subtext14Regular.copyWith(fontSize: 13.sp),
        ),
        6.horizontalSpace,
        Flexible(
          child: Text(
            infoText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.subtext14Regular.copyWith(
              // color: ColorManager.medGray,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}
