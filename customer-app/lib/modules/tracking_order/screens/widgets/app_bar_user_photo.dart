import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/screens/user_profile_screen.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

/// The controls floating over the tracking map: glass back button and the
/// user's photo.
class AppBarUserPhoto extends StatelessWidget {
  const AppBarUserPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Profile profile = sl<GetUserProfileBloc>().profile;
    final String name = profile.userName!;
    final String image = profile.imageLink ?? '';
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: GlassBackButton(onPressed: () => pop(context)),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: KSpace.l),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              pushPage(context, const UserProfileScreen(openAnother: true));
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: c.brandTint,
              foregroundImage: image.isEmpty
                  ? null
                  : ResizeImage(
                      NetworkImage(image),
                      width:
                          (KSpace.xxxl * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                    ),
              child: Text(
                name.isEmpty ? '' : name.characters.first.toUpperCase(),
                style: KType.headline.copyWith(color: c.onBrandTint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
