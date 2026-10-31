import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/notification/screens/notification_screen.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// Pinned top bar (a sliver): the biker's photo and name, which open the
/// profile, and the notification bell.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: KColors.of(context).background,
      centerTitle: false,
      titleSpacing: KSpace.l,
      title: const _BikerIdentity(),
      actions: const <Widget>[
        _NotificationBell(),
        SizedBox(width: KSpace.l),
      ],
    );
  }
}

class _BikerIdentity extends StatelessWidget {
  const _BikerIdentity();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, (String?, String?)>(
      bloc: sl<ProfileBloc>(),
      selector: (ProfileState state) => (
        sl<ProfileBloc>().profile.imageLink,
        sl<ProfileBloc>().profile.userName,
      ),
      builder: (BuildContext context, (String?, String?) biker) {
        final (String? image, String? name) = biker;
        return InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => pushPage(context, ProfileScreen()),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KSpace.tapTarget),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HomeAvatar(
                  imageUrl: image,
                  name: name,
                  size: KSpace.xxxl + KSpace.s,
                ),
                const SizedBox(width: KSpace.m),
                Flexible(
                  child: Text(
                    name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KType.headline.copyWith(
                      color: KColors.of(context).text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        GlassBarButton(
          icon: Icons.notifications_none_rounded,
          sfSymbol: 'bell',
          color: c.brand,
          tooltip: tr(context, AppStrings.notifications),
          onPressed: () => pushPage(context, NotificationScreen()),
        ),
        BlocSelector<NotificationBloc, NotificationState, bool>(
          selector: (NotificationState state) =>
              sl<NotificationBloc>().totalUnRead > 0,
          builder: (BuildContext context, bool unread) {
            if (!unread) return const SizedBox.shrink();
            return PositionedDirectional(
              top: KSpace.s,
              end: KSpace.s,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.error,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: KSpace.s),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
