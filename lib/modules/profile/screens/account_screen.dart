import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/screens/update_password.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/screens/update_biker_data.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const double _photoSize = KSpace.xxxl * 2 + KSpace.xl;

  /// `(+20) 1012345678`: country code, then the rest. Isolated left to right,
  /// so the digits and brackets stay in order in Arabic.
  String _formattedPhone(String phoneNumber) {
    final String countryCode = phoneNumber.substring(0, 3);
    final String restOfNumber = phoneNumber.substring(3);
    return '\u2066($countryCode) $restOfNumber\u2069';
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        title: Text(
          tr(context, AppStrings.account),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: sl<ProfileBloc>(),
          buildWhen: (ProfileState previous, ProfileState current) =>
              current is BikerProfileSuccess ||
              current is BikerProfileEditSuccess,
          builder: (BuildContext context, ProfileState state) {
            final ProfileModel profile = sl<ProfileBloc>().profile;
            return ListView(
              padding: const EdgeInsets.all(KSpace.l),
              children: <Widget>[
                Center(
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => pushPage(context, const UpdateBikerData()),
                    child: SizedBox.square(
                      dimension: _photoSize,
                      child: Stack(
                        children: <Widget>[
                          HomeAvatar(
                            imageUrl: profile.imageLink,
                            name: profile.userName,
                            size: _photoSize,
                          ),
                          PositionedDirectional(
                            bottom: 0,
                            end: 0,
                            child: SvgPicture.asset(
                              ImageAssets.cameraLogo,
                              width: KSpace.xxl,
                              height: KSpace.xxl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: KSpace.xxl),
                KCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      KListRow(
                        title: tr(context, AppStrings.username),
                        subtitle: profile.userName!,
                        showChevron: true,
                        onTap: () => pushPage(context, const UpdateBikerData()),
                      ),
                      Divider(height: 1, color: c.separator),
                      KListRow(
                        title: tr(context, AppStrings.password),
                        subtitle: '********',
                        showChevron: true,
                        onTap: () => pushPage(
                          context,
                          UpdatePassword(profile: true),
                        ),
                      ),
                      Divider(height: 1, color: c.separator),
                      KListRow(
                        title: tr(context, AppStrings.phoneNumber),
                        subtitle: profile.phone == null
                            ? null
                            : _formattedPhone(profile.phone!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KSpace.xxl),
                Text(
                  tr(context, AppStrings.deleteAccount),
                  textAlign: TextAlign.center,
                  style: KType.body.copyWith(color: c.error),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
