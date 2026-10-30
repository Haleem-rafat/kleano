import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/booking/widgets/main_services.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/components/empty_state_widget.dart';
import 'package:thewasher/shared/components/shimmering/basic_container_shimmering.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

class ServicesList extends StatefulWidget {
  const ServicesList({super.key});

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  late final OffersBloc offersBloc;
  Map<int, bool> expandedStates = {};

  @override
  void initState() {
    super.initState();
    offersBloc = sl<OffersBloc>();
  }

  void _refreshServices() {
    final bool guestMode = AppShared.token.isEmpty || isGuestUser;

    if (guestMode) {
      final guestPosition = GeneralSingleton().currentPositionGuest;
      final guestCountry = GeneralSingleton().country ?? 'saudi arabia';

      if (guestPosition != null) {
        offersBloc.add(GetGuestServices(
          lat: guestPosition.latitude,
          lng: guestPosition.longitude,
          country: guestCountry,
        ));
        offersBloc.add(GetGuestAddOns(
          lat: guestPosition.latitude,
          lng: guestPosition.longitude,
          country: guestCountry,
        ));
      }
    } else {
      // Trigger refresh of services and add-ons for authenticated users
      offersBloc.add(GetServices(
        lat: blcoPosition.latitude,
        lng: blcoPosition.longitude,
        country: "saudi arabia",
      ));
      offersBloc.add(GetAddOns(
        lat: blcoPosition.latitude,
        lng: blcoPosition.longitude,
        country: "saudi arabia",
      ));
    }
  }

  bool _shouldShowLoading(OffersState state) {
    return state is OffersInitial ||
        state is GetServicesLoading ||
        state is GetGuestServicesLoading ||
        state is GetAddOnsLoading ||
        state is GetGuestAddOnsLoading;
  }

  Widget _buildDetailItem({
    required String icon,
    required String text,
    Color? color,
    Widget? suffix,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          height: 14.h,
          width: 14.w,
          color: color,
        ),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppStyles.caption12Medium.copyWith(
            color: ColorManager.black,
          ),
        ),
        if (suffix != null) ...[
          SizedBox(width: 2.w),
          suffix,
        ],
      ],
    );
  }

  Widget _buildDescriptionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h, right: 8.w),
            height: 4.h,
            width: 4.w,
            decoration: BoxDecoration(
              color: ColorManager.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppStyles.caption12Medium.copyWith(
                color: ColorManager.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            margin: EdgeInsets.symmetric(vertical: 18.h),
            padding: EdgeInsets.fromLTRB(12.5.w, 11.5.h, 12.5.w, 13.5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppPadding.p15.r),
              color: ColorManager.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: ColorManager.black.withOpacity(.05),
                  blurRadius: 3.r,
                  offset: const Offset(0, 3),
                )
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
                SizedBox(width: AppPadding.p8.w),
                // Icon shimmer
                BasicContainerShemmering(
                  height: 50.h,
                  width: 50.w,
                  radius: 10,
                ),
                SizedBox(width: AppPadding.p8.w),
                // Text content shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    int? selectedServiceIndex;

    void addOrRemoveMainServices() {
      final mainService = offersBloc.mainServices[selectedServiceIndex!];
      if (offersBloc.cartServicesList.contains(mainService)) {
        int deleteIndex = offersBloc.cartServicesList.indexOf(mainService);
        offersBloc.add(DeleteServiceCart(
          index: deleteIndex,
          service: mainService,
        ));
      } else {
        offersBloc.add(AddServiceCart(
          service: mainService,
          selectedMainServiceIndex: selectedServiceIndex,
        ));
      }
    }

    void addOrRemoveServices(ServiceModel extraService) {
      if (offersBloc.cartServicesList.contains(extraService)) {
        int deleteIndex = offersBloc.cartServicesList.indexOf(extraService);
        offersBloc.add(DeleteServiceCart(
          index: deleteIndex,
          service: extraService,
        ));
      } else {
        offersBloc.add(AddServiceCart(service: extraService));
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
      child: BlocBuilder<OffersBloc, OffersState>(
        bloc: offersBloc,
        builder: (context, state) {
          if (_shouldShowLoading(state)) {
            return _buildLoadingSlider();
          }

          // Handle empty services state
          if (state is EmptyServices || state is EmptyGuestServices) {
            return EmptyStateWidget(
              title: translate(AppStrings.ourServicesNotAvailable),
              subtitle: translate(AppStrings.noContent),
              lottieAsset: 'assets/empty.json',
            );
          }

          // Handle error state
          if (state is GetServicesFailed) {
            return EmptyStateWidget(
              title: translate(AppStrings.defaultError),
              subtitle: state.error,
              lottieAsset: 'assets/empty.json',
              showRetryButton: true,
              retryButtonText: translate(AppStrings.retryAgain),
              onRetry: _refreshServices,
            );
          }

          if (state is GetGuestServicesFailed) {
            return EmptyStateWidget(
              title: translate(AppStrings.defaultError),
              subtitle: state.error,
              lottieAsset: 'assets/empty.json',
              showRetryButton: true,
              retryButtonText: translate(AppStrings.retryAgain),
              onRetry: _refreshServices,
            );
          }

          // Handle success state
          List<ServiceModel> mainServicesData = offersBloc.mainServices;
          List<ServiceModel> extraServicesData = offersBloc.extraServices;

          if (state is GetServicesSuccess) {
            mainServicesData = state.mainServices;
            extraServicesData = state.extraServices;
          } else if (state is GetGuestServicesSuccess) {
            mainServicesData = state.mainServices;
            extraServicesData = state.extraServices;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              8.verticalSpace,
              Text(
                translate(AppStrings.chooseYourMainService),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.black,
                ),
              ),
              // 8.verticalSpace,
              MainServices(
                mainServices: mainServicesData,
                addOrRemoveMainServices: (index) {
                  selectedServiceIndex = index;
                  addOrRemoveMainServices();
                },
              ),
              16.verticalSpace,
              if (extraServicesData.isNotEmpty) ...[
                Text(
                  translate(AppStrings.chooseYourExtraServices),
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Column(
                  children: extraServicesData.asMap().keys.map((int index) {
                    final extraService = extraServicesData[index];
                    final extraDescription =
                        extraService.description as List<dynamic>?;
                    bool isSelected =
                        offersBloc.cartServicesList.contains(extraService);
                    return AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: GestureDetector(
                        onTapDown: (_) {
                          HapticFeedback.lightImpact();
                        },
                        onTap: () {
                          addOrRemoveServices(extraService);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin:
                              EdgeInsets.symmetric(vertical: AppMargin.m8.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? ColorManager.secondary
                                  : ColorManager.lightGray,
                              width: isSelected ? 2.w : 1.w,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            color: ColorManager.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: isSelected
                                    ? ColorManager.secondary.withOpacity(0.15)
                                    : ColorManager.black.withOpacity(0.08),
                                blurRadius: isSelected ? 8.r : 4.r,
                                offset: Offset(0, isSelected ? 4.h : 2.h),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Checkbox
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: SizedBox(
                                      height: AppSize.s20.h,
                                      width: AppSize.s20.w,
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (bool? selected) {
                                          addOrRemoveServices(extraService);
                                        },
                                        activeColor: ColorManager.primary,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                        ),
                                        side: BorderSide(
                                          color: ColorManager.medGray,
                                          width: 1.5.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),

                                  // Service Icon
                                  Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: ColorManager.gray,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: ColorManager.lightGray,
                                        width: 1.w,
                                      ),
                                    ),
                                    child: ImageShared(
                                      image: extraService.icon?.iconLink ?? '',
                                      height: 48.h,
                                      width: 48.w,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),

                                  // Service Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Service Name
                                        Text(
                                          extraService.name ?? '',
                                          style:
                                              AppStyles.body14Medium.copyWith(
                                            color: ColorManager.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8.h),

                                        // Service Details Grid
                                        Wrap(
                                          spacing: 16.w,
                                          runSpacing: 6.h,
                                          children: [
                                            // // Points
                                            // _buildDetailItem(
                                            //   icon: AssetsManager.walletCoin,
                                            //   text: services
                                            //       .extraServices[index]
                                            //       .pointsToPay
                                            //       .toString(),
                                            // ),

                                            // // Duration
                                            _buildDetailItem(
                                              color: ColorManager.black,
                                              icon: AssetsManager.timeIconLogo,
                                              text:
                                                  "${extraService.duration!} ${translate(extraService.durationUnit ?? '')} ${translate(AppStrings.toService)}",
                                            ),

                                            // Price
                                            _buildDetailItem(
                                              color: ColorManager.black,
                                              icon:
                                                  AssetsManager.serviceCoinSvg,
                                              text: "${extraService.price!} ",
                                              suffix: SvgPicture.asset(
                                                AssetsManager.saudiRiyalSymbol,
                                                height: 12.h,
                                                width: 12.w,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // Description Section with Enhanced Design
                              if (extraDescription?.isNotEmpty == true)
                                Container(
                                  margin: EdgeInsets.only(top: 12.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: ColorManager.gray.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: ColorManager.lightGray,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Description Title
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16.h,
                                            color: ColorManager.primary,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            translate(
                                                AppStrings.serviceDetails),
                                            style: AppStyles.caption12Medium
                                                .copyWith(
                                              color: ColorManager.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),

                                      // Description Items
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Show first item always
                                          _buildDescriptionItem(
                                            extraDescription?[0]?.toString() ??
                                                '',
                                          ),
                                          // Show additional items only when expanded
                                          if (expandedStates[index] == true)
                                            ...List.generate(
                                              (extraDescription?.length ?? 1) -
                                                  1,
                                              (i) => _buildDescriptionItem(
                                                extraDescription?[i + 1]
                                                        ?.toString() ??
                                                    '',
                                              ),
                                            ),
                                        ],
                                      ),

                                      // Show see more/hide button only if there are multiple items
                                      if ((extraDescription?.length ?? 0) >
                                          1) ...[
                                        SizedBox(height: 8.h),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              expandedStates[index] =
                                                  !(expandedStates[index] ??
                                                      false);
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.h, horizontal: 8.w),
                                            decoration: BoxDecoration(
                                              color: ColorManager.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  expandedStates[index] == true
                                                      ? translate('hide')
                                                      : translate('seeMore'),
                                                  style: AppStyles
                                                      .caption12Medium
                                                      .copyWith(
                                                    color: ColorManager.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  expandedStates[index] == true
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 16.h,
                                                  color: ColorManager.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                150.verticalSpace,
              ],
            ],
          );
        },
      ),
    );
  }
}
