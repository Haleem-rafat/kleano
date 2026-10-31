import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/biker_shell.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/notification/data/model/notification_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  RefreshController refreshControllers = RefreshController();

  @override
  void initState() {
    super.initState();
    sl<NotificationBloc>().add(GetBikerNotification());
  }

  @override
  void dispose() {
    refreshControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        title: Text(
          tr(context, AppStrings.notifications),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: BlocListener<HomeBloc, HomeState>(
          bloc: sl<HomeBloc>(),
          listener: (BuildContext context, HomeState state) {
            if (state is BikerOrderFailed) {
              showSnackBar(buildContext: context, message: state.error);
            } else if (state is BikerOrderSuccess) {
              if (sl<HomeBloc>().orderDetails.status == "COMPLETED") {
                popALlAndPushPage(context, const BikerShell(initialIndex: 2));
              } else {
                Navigator.of(context).push(
                  createRoute(
                    OrderChangeStatus(
                      order: sl<HomeBloc>().orderDetails,
                      notification: true,
                      markerBikerLocation: state.markerBikerLocation,
                      markerUserLocation: state.markerUserLocation,
                    ),
                  ),
                );
              }
            }
          },
          child: BlocConsumer<NotificationBloc, NotificationState>(
            listener: (BuildContext context, NotificationState state) {
              if (state is BikerNotificationSuccess) {
                refreshControllers.loadComplete();
                if (refreshControllers.isRefresh) {
                  refreshControllers.refreshCompleted();
                }
              }
            },
            bloc: sl<NotificationBloc>(),
            builder: (BuildContext context, NotificationState state) {
              if (state is BikerNotificationLoading) {
                return const KLoadingState();
              } else if (state is BikerNotificationEmpty) {
                return Center(
                  child: EmptyScreen(
                    notification: true,
                    text: AppStrings.letYouKnow,
                  ),
                );
              } else if (state is BikerNotificationFailed) {
                return KErrorState(
                  message: translate('defaultError'),
                  onRetry: () =>
                      sl<NotificationBloc>().add(GetBikerNotification()),
                );
              }
              return SmartRefresher(
                controller: refreshControllers,
                enablePullUp: true,
                header: const CustomHeader(
                  builder: orderRefreshHeader,
                  height: orderIndicatorHeight,
                ),
                footer: const CustomFooter(
                  builder: orderLoadMoreFooter,
                  height: orderIndicatorHeight,
                ),
                onRefresh: () {
                  sl<NotificationBloc>().add(GetBikerNotification());
                },
                onLoading: () {
                  sl<NotificationBloc>().add(GetBikerNotificationPagination());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(KSpace.l),
                  itemCount: sl<NotificationBloc>().notificationList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: KSpace.m),
                  itemBuilder: (BuildContext context, int index) =>
                      _NotificationRow(index: index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.index});

  final int index;

  void _onTap(BuildContext context, NotificationModel item) {
    // Some notifications are not about an order: only mark those as read.
    if (item.clickableItem == null) return;
    item.isRead!
        ? sl<HomeBloc>().add(
            BikerOrder(orderId: item.clickableItem!, context: context),
          )
        : sl<NotificationBloc>().add(
            MakeNotificationIsRead(
              notificationId: item.sId!,
              notificationIndex: index,
              context: context,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final NotificationModel item =
        sl<NotificationBloc>().notificationList[index];
    final bool english = Localizations.localeOf(context).languageCode == 'en';
    final String title = english
        ? item.message!.enTitle!
        : item.message!.arTitle!;
    final String body = english ? item.message!.enBody! : item.message!.arBody!;
    return KCard(
      onTap: () => _onTap(context, item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(
            ImageAssets.notificationSvg,
            width: KSpace.xxxl,
            height: KSpace.xxxl,
          ),
          const SizedBox(width: KSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title.isEmpty ? 'Notification Title' : title,
                        style: KType.headline.copyWith(color: c.text),
                      ),
                    ),
                    if (!item.isRead!) ...<Widget>[
                      const SizedBox(width: KSpace.s),
                      Padding(
                        padding: const EdgeInsets.only(top: KSpace.xs),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.brand,
                          ),
                          child: const SizedBox.square(dimension: KSpace.s),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: KSpace.xs),
                Text(
                  body.isEmpty ? 'Notification Body' : body,
                  style: KType.subhead.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: KSpace.xs),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    item.createdAt! == item.timeNow
                        ? item.createdAtTime!
                        : item.createdAt!,
                    style: KType.footnote.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
