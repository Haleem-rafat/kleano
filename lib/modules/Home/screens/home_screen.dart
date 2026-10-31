import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_segmented.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/complet_widget.dart';
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

enum _OrdersTab { active, completed }

const double _indicatorHeight = KSpace.xxxl * 2;

Widget _refreshHeader(BuildContext context, RefreshStatus? mode) => SizedBox(
  height: _indicatorHeight,
  child: mode == RefreshStatus.refreshing
      ? const Center(child: CircularProgressIndicator.adaptive())
      : null,
);

Widget _loadMoreFooter(BuildContext context, LoadStatus? mode) => SizedBox(
  height: _indicatorHeight,
  child: switch (mode) {
    LoadStatus.loading => const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    LoadStatus.failed => Center(
      child: Text(
        MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
        style: KType.footnote.copyWith(
          color: KColors.of(context).textSecondary,
        ),
      ),
    ),
    _ => null,
  },
);

/// The biker's home: online switch first, then the order to deal with, stats,
/// and the Active / Completed lists. One scroll view, and each section listens
/// to its own bloc states, so a socket event doesn't rebuild the whole screen.
class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, required this.initialIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime preBackPress = DateTime.now();
  late final FirebaseCloudMessagingService firebaseCloudMessagingService;
  late final ValueNotifier<_OrdersTab> _tab;
  String whatsappNumber = "+966533720654";
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    // Callers pass 2 for "completed", from when there was a third tab.
    _tab = ValueNotifier<_OrdersTab>(
      widget.initialIndex == 0 ? _OrdersTab.active : _OrdersTab.completed,
    );

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
    _tab.dispose();
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

  /// Next page of the list on screen. An empty list has no next page: the page
  /// ends right after its empty state, so the footer can be reached there.
  void _onLoadMore() {
    final HomeBloc bloc = sl<HomeBloc>();
    if (_tab.value == _OrdersTab.active) {
      if (bloc.activeList.isEmpty) {
        _refreshController.loadComplete();
      } else {
        bloc.add(BikerGetOrdersAcceptPagination());
      }
    } else {
      if (bloc.completeList.isEmpty) {
        _refreshController.loadComplete();
      } else {
        bloc.add(BikerGetOrdersCompletePagination());
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
              title: message.notification!.title!,
              body: message.notification!.body!,
            );
          });
          firebaseCloudMessagingService.listenToBackgroundNotifications((
            RemoteMessage message,
          ) async {
            pushPage(context, NotificationScreen());
          });
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          final Duration timeGap = DateTime.now().difference(preBackPress);
          final bool cantExit = timeGap >= const Duration(seconds: 2);
          preBackPress = DateTime.now();
          if (cantExit) {
            final SnackBar snack = SnackBar(
              content: Text(translate(AppStrings.backButton)),
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
          } else {
            SystemNavigator.pop();
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
          floatingActionButton: FloatingActionButton(
            onPressed: _openSupportWhatsApp,
            backgroundColor: c.success,
            tooltip: 'WhatsApp',
            child: SvgPicture.asset(
              "assets/svg/whatsapp_icon.svg",
              width: KSpace.xxl,
              height: KSpace.xxl,
              colorFilter: ColorFilter.mode(c.surface, BlendMode.srcIn),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, bool online) {
    const Widget gap = SliverToBoxAdapter(child: SizedBox(height: KSpace.l));
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoadMore,
      enablePullDown: true,
      enablePullUp: online,
      header: const CustomHeader(
        builder: _refreshHeader,
        height: _indicatorHeight,
      ),
      footer: const CustomFooter(
        builder: _loadMoreFooter,
        height: _indicatorHeight,
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
                if (online)
                  _buildOrders()
                else
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

  Widget _buildOrders() {
    return ValueListenableBuilder<_OrdersTab>(
      valueListenable: _tab,
      builder: (BuildContext context, _OrdersTab tab, Widget? child) {
        return SliverMainAxisGroup(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: KSegmented<_OrdersTab>(
                segments: <_OrdersTab, String>{
                  _OrdersTab.active: tr(context, AppStrings.active),
                  _OrdersTab.completed: tr(context, AppStrings.completed),
                },
                selected: tab,
                onChanged: (_OrdersTab value) => _tab.value = value,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: KSpace.l)),
            // Only the selected tab is mounted: each loads its list on mount.
            if (tab == _OrdersTab.active)
              AcceptWidget(refreshController: _refreshController)
            else
              CompleteWidget(refreshController: _refreshController),
          ],
        );
      },
    );
  }
}
