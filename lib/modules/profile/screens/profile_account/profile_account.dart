import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/screens/profile_account/change_personal_information/change_personal_info.dart';
import 'package:thewasher/modules/profile/screens/profile_account/edit_phone_number/edit_phone_screen.dart';
import 'package:thewasher/modules/profile/widgets/edit_profile/info_user_profile.dart';
import 'package:thewasher/modules/profile/widgets/phone_number.dart';
import 'package:thewasher/modules/profile/widgets/shared_widget/container_edit.dart';
import 'package:thewasher/modules/profile/widgets/upload_user_photo.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/shared/components/connection_error/connection_error_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class ProfileAccountScreen extends StatefulWidget {
  const ProfileAccountScreen({
    super.key,
  });

  @override
  State<ProfileAccountScreen> createState() => _ProfileAccountScreenState();
}

class _ProfileAccountScreenState extends State<ProfileAccountScreen> {
  late GetUserProfileBloc getUserProfileBloc;
  String? countryCode;
  String phoneNumberText = '';
  Profile user = Profile();

  @override
  void initState() {
    super.initState();
    getUserProfileBloc = BlocProvider.of<GetUserProfileBloc>(context)
      ..add(GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, AppSize.s60.h),
          child: AppBarWhiteShared(
            titleText: translate(AppStrings.account),
          ),
        ),
        body: BlocConsumer<GetUserProfileBloc, GetUserProfileState>(
          listener: (context, state) async {
            if (state is GetUserProfileSuccess) {
              user = state.userProfile.data!;
              if ((user.phone ?? '').isNotEmpty) {
                final PhoneNumber phoneNumber =
                    await PhoneNumber.parse(user.phone!);
                setState(() {
                  countryCode = '+${phoneNumber.countryCode}';
                  phoneNumberText = phoneNumber.international;
                });
              } else {
                setState(() {
                  countryCode = '+20';
                });
              }
            }
          },
          builder: (context, state) {
            if (state is GetUserProfileConnectionError) {
              return Center(
                child: ConnectionErrorSharedScreen(
                  onPressed: () {
                    getUserProfileBloc.add(GetUserProfileEvent());
                  },
                ),
              );
            } else if (state is GetUserProfileSuccess) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppPadding.p20.ph,

                      /// User photo
                      Center(
                        child: UserPhoto(
                          isEdit: false,
                          userPhoto:
                              user.imageLink != null ? user.imageLink! : "null",
                        ),
                      ),

                      AppPadding.p20.ph,

                      /// Personal Info Section
                      SectionCard(
                        title: translate(AppStrings.personalInformation),
                        onEdit: () {
                          pushPage(
                              context, ChangePersonalInformation(user: user));
                        },
                        child: PersonalInformation(user: user),
                      ),

                      AppPadding.p16.ph,

                      /// Phone Section
                      SectionCard(
                        title: translate(AppStrings.phoneNumberUser),
                        onEdit: () {
                          pushPage(
                            context,
                            EditPhoneScreen(
                              phoneNumber: phoneNumberText,
                              countryCodeSelected: countryCode!,
                            ),
                          );
                        },
                        child: phoneNumberText != ''
                            ? buildFormattedPhoneNumber(phoneNumberText)
                            : Text(
                                translate(AppStrings.phoneNumber),
                                style: AppStyles.titleGray16Regular.copyWith(
                                  color: ColorManager.gray,
                                ),
                              ),
                      ),

                      AppPadding.p20.ph,

                      /// Delete Account
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            AlertHelper.deleteUserAccount(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.h, horizontal: 24.w),
                            decoration: BoxDecoration(
                              color: ColorManager.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              translate(AppStrings.deleteAccount),
                              style: AppStyles.titleGray16Regular.copyWith(
                                color: ColorManager.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      AppPadding.p30.ph,
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget buildFormattedPhoneNumber(String phoneNumber) {
    String countryCode = phoneNumber.substring(0, 4);
    String restOfNumber = phoneNumber.substring(4);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: '($countryCode) ',
                style: AppStyles.titleGray16Regular
                    .copyWith(color: ColorManager.darkGrey),
              ),
              TextSpan(
                text: restOfNumber,
                style: AppStyles.titleGray16Regular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.titleGray16Regular.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.edit_outlined,
                  size: 20.sp,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
          AppPadding.p12.ph,
          child,
        ],
      ),
    );
  }
}
