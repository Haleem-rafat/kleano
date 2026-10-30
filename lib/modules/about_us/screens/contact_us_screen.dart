import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/modules/about_us/widgets/social_widget.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, AppSize.s60.h),
          child: AppBarWhiteShared(
            titleText: translate(AppStrings.contactUs),
          ),
        ),
        body: BlocProvider<AboutUsBloc>(
          create: (context) => AboutUsBloc()..add(GetContactInfo()),
          child: BlocConsumer<AboutUsBloc, AboutUsState>(
              listener: (context, state) {
            if (state.status == AboutUsStateStatus.error) {
              showSnackBar(buildContext: context, message: state.errorMessage!);
            }
          }, builder: (context, state) {
            if (state.status == AboutUsStateStatus.loading) {
              return const Center(
                child: LoadingWidget(),
              );
            }

            if (state.status == AboutUsStateStatus.success) {
              return _buildContactInfo(state);
            }
            return const SizedBox.shrink();
          }),
        ));
  }

  Widget _buildContactInfo(AboutUsState state) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _emails(state),
            24.verticalSpace,
            _phones(state),
            24.verticalSpace,
            _social(state),
            24.verticalSpace,
          ],
        ),
      ));

  Widget _emails(AboutUsState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: ColorManager.divider2,
          borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translate(AppStrings.emails),
                style:
                    AppStyles.title16Bold.copyWith(color: ColorManager.black),
              ),
              16.verticalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.contactInfo!.emails
                    .map((email) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              const Icon(Icons.email,
                                  color: ColorManager.black),
                              8.horizontalSpace,
                              Text(email,
                                  style: AppStyles.subtextGray14Regular
                                      .copyWith(color: ColorManager.black)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          )),
    );
  }

  Widget _phones(AboutUsState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: ColorManager.divider2,
          borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translate(AppStrings.phoneNumbers),
                style:
                    AppStyles.title16Bold.copyWith(color: ColorManager.black),
              ),
              16.verticalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.contactInfo!.phoneNumbers
                    .map((phone) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: ColorManager.black),
                              8.horizontalSpace,
                              Text(phone,
                                  style: AppStyles.subtextGray14Regular
                                      .copyWith(color: ColorManager.black)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          )),
    );
  }

  Widget _social(AboutUsState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: ColorManager.divider2,
          borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translate(AppStrings.socialMedia),
                style:
                    AppStyles.title16Bold.copyWith(color: ColorManager.black),
              ),
              16.verticalSpace,
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SocialWidget(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.green),
                      titleSocial: "WhatsApp",
                      isPhone: true,
                      url: state.contactInfo!.whatsAppNumber,
                    ),
                    if (state.contactInfo!.facebookLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.facebook,
                            color: Colors.blue),
                        titleSocial: "Facebook",
                        url: state.contactInfo!.facebookLink,
                      ),
                    if (state.contactInfo!.instagramLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.instagram,
                            color: Colors.pinkAccent),
                        titleSocial: "Instagram",
                        url: state.contactInfo!.instagramLink,
                      ),
                    if (state.contactInfo!.twitterLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.x),
                        titleSocial: "X",
                        url: state.contactInfo!.twitterLink,
                      ),
                    if (state.contactInfo!.linkedinLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.snapchat,
                            color: Colors.blue),
                        titleSocial: "Snapchat",
                        url: state.contactInfo!.linkedinLink,
                      ),
                    if (state.contactInfo!.youtubeLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.youtube,
                            color: Colors.red),
                        titleSocial: "Youtube",
                        url: state.contactInfo!.youtubeLink,
                      ),
                    if (state.contactInfo!.tiktokLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.tiktok),
                        titleSocial: "TikTok",
                        url: state.contactInfo!.tiktokLink,
                      ),
                    if (state.contactInfo!.webSiteLink.isNotEmpty)
                      SocialWidget(
                        icon: const FaIcon(FontAwesomeIcons.globe),
                        titleSocial: "Website",
                        url: state.contactInfo!.webSiteLink,
                      ),
                  ]),
            ],
          )),
    );
  }
}
