import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(GetSavedLocation());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(AppSize.s375, 60.h),
            child: AppBarShared(
              titleAppBar: translate(AppStrings.savedPlaces),
              isTextOnly: false,
            ),
          ),
          body: BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is DeleteLocationByIdSuccess) {
                // Refresh the saved locations after successful deletion
                context.read<LocationBloc>().add(GetSavedLocation());
                showSnackBar(
                  buildContext: context,
                  message: translate('locationDeletedSuccessfully'),
                  icon: Icons.check_circle_outline,
                  backgroundColor: ColorManager.green,
                );
              } else if (state is DeleteLocationByIdFailed) {
                showSnackBar(
                  buildContext: context,
                  message:
                      '${translate('failedToDeleteLocation')}: ${state.error}',
                  icon: Icons.error_outline,
                  backgroundColor: ColorManager.red,
                );
              }
            },
            child: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                if (state is GetSavedLocationLoading ||
                    state is SetDefaultLocationLoading) {
                  return const LoadingWidget();
                } else if (state is GetSavedLocationSuccess) {
                  return ListView.builder(
                    padding: EdgeInsets.all(AppPadding.p16.w),
                    itemCount: state.savedLocation.length,
                    itemBuilder: (context, index) {
                      final location = state.savedLocation[index];
                      return _buildLocationCard(location);
                    },
                  );
                } else if (state is SetDefaultLocationSuccess) {
                  // Handle the updated state after setting default location
                  if (state.updatedSavedLocations != null) {
                    return ListView.builder(
                      padding: EdgeInsets.all(AppPadding.p16.w),
                      itemCount: state.updatedSavedLocations!.length,
                      itemBuilder: (context, index) {
                        final location = state.updatedSavedLocations![index];
                        return _buildLocationCard(location);
                      },
                    );
                  } else {
                    // If no updated locations, refresh the saved locations
                    context.read<LocationBloc>().add(GetSavedLocation());
                    return const LoadingWidget();
                  }
                } else if (state is GetSavedLocationFailed ||
                    state is SetDefaultLocationFailed) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.r,
                          color: ColorManager.red,
                        ),
                        AppPadding.p16.ph,
                        Text(
                          state is GetSavedLocationFailed
                              ? translate(AppStrings.failedToGetSavedLocations)
                              : translate(
                                  AppStrings.failedToSetDefaultLocation),
                          style: AppStyles.title16Regular.copyWith(
                            color: ColorManager.black,
                          ),
                        ),
                        AppPadding.p16.ph,
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<LocationBloc>()
                                .add(GetSavedLocation());
                          },
                          child: Text(translate(AppStrings.retry)),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ));
  }

  Widget _buildLocationCard(AddressModel location) {
    return Container(
      margin: EdgeInsets.only(bottom: AppMargin.m12.h),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          ),
        ],
        border: location.isDefault == true
            ? Border.all(
                color: ColorManager.primary.withValues(alpha: 0.3),
                width: 2.w,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.r),
          onTap: () {
            context.read<LocationBloc>().add(SetDefaultLocation(
                  locationId: location.sId!,
                ));
          },
          child: Padding(
            padding: EdgeInsets.all(AppPadding.p16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and default badge
                Row(
                  children: [
                    // Location Icon
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: ColorManager.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: ColorManager.primary,
                        size: 20.r,
                      ),
                    ),
                    AppPadding.p12.pw,
                    // Location Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.savedName ??
                                translate(AppStrings.savedLocation),
                            style: AppStyles.title16Bold.copyWith(
                              color: ColorManager.black,
                            ),
                          ),
                          if (location.isDefault == true) ...[
                            AppPadding.p4.ph,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                translate(AppStrings.defaultLabel),
                                style: AppStyles.caption12Medium.copyWith(
                                  color: ColorManager.primary,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Delete icon
                    GestureDetector(
                      onTap: () {
                        if (location.isDefault == true) {
                          showSnackBar(
                            buildContext: context,
                            message: translate('cannotDeleteDefaultLocation'),
                          );
                        } else {
                          _showDeleteLocationDialog(location);
                        }
                      },
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: location.isDefault == true
                              ? ColorManager.medGray.withValues(alpha: 0.1)
                              : ColorManager.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: location.isDefault == true
                              ? ColorManager.medGray
                              : ColorManager.red,
                          size: 18.r,
                        ),
                      ),
                    ),
                  ],
                ),
                AppPadding.p12.ph,
                // Location Details
                if (location.streetName != null &&
                    location.streetName!.isNotEmpty)
                  _buildLocationDetail(
                    icon: Icons.place,
                    text: location.streetName!,
                  ),
                if (location.subAdministrativeArea != null &&
                    location.subAdministrativeArea!.isNotEmpty)
                  _buildLocationDetail(
                    icon: Icons.location_city,
                    text: location.subAdministrativeArea!,
                  ),
                if (location.country != null && location.country!.isNotEmpty)
                  _buildLocationDetail(
                    icon: Icons.public,
                    text: location.country!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDetail({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppPadding.p8.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: ColorManager.black,
            size: 16.r,
          ),
          AppPadding.p8.pw,
          Expanded(
            child: Text(
              text,
              style: AppStyles.subtextGray14Regular
                  .copyWith(color: ColorManager.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteLocationDialog(AddressModel location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            translate('deleteLocation'),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          content: Text(
            translate('areYouSureDeleteLocation',
                args: {'locationName': location.savedName ?? 'this location'}),
            style: AppStyles.subtext14Regular
                .copyWith(color: ColorManager.darkGrey),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                translate('cancel'),
                style: AppStyles.body14Medium
                    .copyWith(color: ColorManager.darkGrey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Delete the location
                context.read<LocationBloc>().add(DeleteLocationById(
                      locationId: location.sId!,
                    ));
              },
              child: Text(
                translate('delete'),
                style: AppStyles.body14Medium.copyWith(color: ColorManager.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
