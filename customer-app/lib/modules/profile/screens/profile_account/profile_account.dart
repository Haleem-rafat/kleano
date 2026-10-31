import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/screens/profile_account/change_personal_information/change_personal_info.dart';
import 'package:thewasher/modules/profile/widgets/edit_profile/info_user_profile.dart';
import 'package:thewasher/modules/profile/widgets/upload_user_photo.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/utilties/navigator.dart';

class ProfileAccountScreen extends StatefulWidget {
  const ProfileAccountScreen({super.key});

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
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.account)),
      ),
      body: BlocConsumer<GetUserProfileBloc, GetUserProfileState>(
        listener: (BuildContext context, GetUserProfileState state) async {
          if (state is GetUserProfileSuccess) {
            user = state.userProfile.data!;
            if ((user.phone ?? '').isNotEmpty) {
              // A number saved without a dial code cannot be parsed.
              try {
                final PhoneNumber phoneNumber = PhoneNumber.parse(user.phone!);
                setState(() {
                  countryCode = '+${phoneNumber.countryCode}';
                  phoneNumberText = phoneNumber.international;
                });
              } on Exception catch (_) {
                setState(() {
                  countryCode = AppConstants.defaultDialCode;
                  phoneNumberText = user.phone!;
                });
              }
            } else {
              setState(() {
                countryCode = '+20';
              });
            }
          }
        },
        builder: (BuildContext context, GetUserProfileState state) {
          if (state is GetUserProfileConnectionError) {
            return KErrorState(
              message: translate('somethingWentWrong'),
              onRetry: () => getUserProfileBloc.add(GetUserProfileEvent()),
            );
          } else if (state is GetUserProfileSuccess) {
            return ListView(
              padding: const EdgeInsets.all(KSpace.xl),
              children: <Widget>[
                UserPhoto(
                  isEdit: false,
                  userPhoto: user.imageLink != null ? user.imageLink! : 'null',
                  name: user.userName,
                ),
                const SizedBox(height: KSpace.xxl),
                SectionCard(
                  title: translate(AppStrings.personalInformation),
                  onEdit: () {
                    pushPage(context, ChangePersonalInformation(user: user));
                  },
                  child: PersonalInformation(user: user),
                ),
                const SizedBox(height: KSpace.l),
                SectionCard(
                  title: translate(AppStrings.phoneNumberUser),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KSpace.l,
                      0,
                      KSpace.l,
                      KSpace.l,
                    ),
                    child: phoneNumberText != ''
                        ? buildFormattedPhoneNumber(c, phoneNumberText)
                        : Text(
                            translate(AppStrings.phoneNumber),
                            style: KType.body.copyWith(color: c.textSecondary),
                          ),
                  ),
                ),
                const SizedBox(height: KSpace.xl),
                KButton(
                  label: translate(AppStrings.deleteAccount),
                  variant: KButtonVariant.text,
                  color: c.error,
                  onPressed: () => AlertHelper.deleteUserAccount(context),
                ),
              ],
            );
          }
          return const KSkeleton.details();
        },
      ),
    );
  }

  Widget buildFormattedPhoneNumber(KColors c, String phoneNumber) {
    final String code = countryCode ?? '';
    final String restOfNumber = phoneNumber.startsWith(code)
        ? phoneNumber.substring(code.length)
        : phoneNumber;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text.rich(
        textDirection: TextDirection.ltr,
        TextSpan(
          style: KType.body.copyWith(color: c.text),
          children: <InlineSpan>[
            TextSpan(text: '($code) '),
            TextSpan(text: restOfNumber),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return KCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: KSpace.l,
              end: KSpace.xs,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: KType.headline.copyWith(color: c.text),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    tooltip: translate(AppStrings.editProfile),
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined, size: 20, color: c.brand),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
