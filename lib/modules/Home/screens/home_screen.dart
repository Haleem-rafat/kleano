import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_stats_card.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_status_card.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_top_bar.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/notification/screens/notification_screen.dart';
import 'package:thewhsherbiker/modules/notification/widget/firebase_notification.dart';
import 'package:thewhsherbiker/modules/notification/widget/local_notification.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:url_launcher/url_launcher.dart';

/// The Today tab: online switch first, then the order to deal with and stats.
/// One scroll view, and each section listens to its own bloc states, so a socket
/// event doesn't rebuild the whole screen. Stays mounted in [BikerShell], so what
/// it sends on open is sent once, whichever tab the shell opens on.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseCloudMessagingService firebaseCloudMessagingService;
  String whatsappNumber = "+966533720654";
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingService = FirebaseCloudMessagingService();
    // sl<NotificationBloc>().add(MakePushNotification());
    sl<NotificationBloc>().add(GetBikerNotification());
    sl<ProfileBloc>().add(BikerGetTotalWashes(status: "COMPLETED"));
    sl<ProfileBloc>().add(BikerGetTotalCommission());

    if (sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name) {
      sl<HomeBloc>().add(BikerGetNewOrders());
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    try {
      // Refresh user profile
      sl<ProfileBloc>().add(BikerProfile());

      // Refresh total washes
      sl<ProfileBloc>().add(BikerGetTotalWashes(status: "COMPLETED"));

      // Refresh total commission
      sl<ProfileBloc>().add(BikerGetTotalCommission());

      // Refresh active orders if biker is online
      if (sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name) {
        sl<HomeBloc>().add(BikerGetOrdersAccept());
      }

      // Wait for the requests to complete
      await Future.delayed(const Duration(milliseconds: 1000));

      // Complete the refresh
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      if (mounted) {
        _refreshController.refreshFailed();
      }
    }
  }

  Future<void> _openSupportWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$whatsappNumber");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      final Uri whatsappWebUri = Uri.parse(
        "https://web.whatsapp.com/send?phone=$whatsappNumber",
      );
      if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        showSnackBar(
          buildContext: context,
          message:
              'Unable to open WhatsApp. Please install WhatsApp or try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (BuildContext context, NotificationState state) {
        if (state is MakePushNotificationFailed) {
          showSnackBar(buildContext: context, message: state.error);
        } else if (state is MakePushNotificationSuccess) {
          firebaseCloudMessagingService.listenToForegroundNotifications((
            RemoteMessage message,
          ) async {
            sl<NotificationBloc>().totalUnRead++;
            LocalNotificationServices(context: context).notification(
              title: message.notification?.title ?? '',
              body: message.notification?.body ?? '',
            );
          });
          firebaseCloudMessagingService.listenToBackgroundNotifications((
            RemoteMessage message,
          ) async {
            pushPage(context, NotificationScreen());
          });
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: AdaptiveContent(
          child: BlocSelector<ProfileBloc, ProfileState, bool>(
            bloc: sl<ProfileBloc>(),
            selector: (ProfileState state) => bikerIsOnline(),
            builder: _buildScrollView,
          ),
        ),
        // The shell's floating tab bar is in padding, not viewPadding, and the
        // FAB location only reads viewPadding: lift it above the bar here.
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom:
                (MediaQuery.paddingOf(context).bottom -
                        MediaQuery.viewPaddingOf(context).bottom)
                    .clamp(0.0, double.infinity),
          ),
          child: GlassIconButton(
            icon: Icons.chat_rounded,
            onPressed: _openSupportWhatsApp,
            tooltip: 'WhatsApp',
            child: SvgPicture.asset(
              "assets/svg/whatsapp_icon.svg",
              width: KSpace.xxl,
              height: KSpace.xxl,
              colorFilter: ColorFilter.mode(c.success, BlendMode.srcIn),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, bool online) {
    const Widget gap = SliverToBoxAdapter(child: SizedBox(height: KSpace.l));
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      enablePullDown: true,
      header: const CustomHeader(
        builder: orderRefreshHeader,
        height: orderIndicatorHeight,
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          const HomeTopBar(),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KSpace.l,
              KSpace.s,
              KSpace.l,
              0,
            ),
            sliver: SliverMainAxisGroup(
              slivers: <Widget>[
                const SliverToBoxAdapter(child: HomeStatusCard()),
                gap,
                if (online) const ActiveOrderFocus(),
                const SliverToBoxAdapter(child: HomeStatsCard()),
                gap,
                if (!online)
                  const SliverToBoxAdapter(child: HomeOfflinePrompt()),
              ],
            ),
          ),
          // Keeps the last card clear of the floating WhatsApp button.
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom + KSpace.xxxl * 3,
            ),
          ),
        ],
      ),
    );
  }
}
