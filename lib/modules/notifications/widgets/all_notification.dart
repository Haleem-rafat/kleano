import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/notifications/widgets/notifications_list.dart';
import 'package:thewasher/shared/components/connection_error/connection_error_screen.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/smart_refresh.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

class AllNotifications extends StatefulWidget {
  const AllNotifications({super.key});

  @override
  State<AllNotifications> createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {
  late NotificationsBloc notificationsBloc;
  late RefreshController refreshController;
  late GeneralSingleton generalSingleton;
  @override
  void initState() {
    super.initState();
    notificationsBloc = sl<NotificationsBloc>();
    refreshController = RefreshController();
    _getNotifications();
    generalSingleton = GeneralSingleton();
  }

  void _getNotifications() {
    notificationsBloc.add(FetchAllNotifications());
  }

  void _getNotificationsPerPage() {
    notificationsBloc.add(ViewNotificationsPerPage());
  }

  @override
  void dispose() {
    refreshController.dispose();
    generalSingleton.hasUnreadNotification = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listener: (BuildContext context, NotificationsState state) {
        if (state is NotificationsSuccess) {
          refreshController.loadComplete();
        } else if (state is NotificationsFailed) {
          refreshController.requestRefresh();
          showSnackBar(
            buildContext: context,
            message: Localizations.localeOf(context).languageCode == 'en' ? state.errorModel!.en! : state.errorModel!.ar!,
          );
        } else if (state is ReadNotificationSuccess) {
          sl<NotificationsBloc>().add(FetchAllNotifications(
            isRefresh: false,
          ));
        }
      },
      builder: (BuildContext context, NotificationsState state) {
        if (state is NotificationsLoading) {
          return const LoadingWidget();
        } else if (state is NotificationsConnectionError) {
          return Center(
            child: ConnectionErrorSharedScreen(onPressed: _getNotifications),
          );
        }
        return SmartRefresherCustomWidget(
          refreshController: refreshController,
          onLoading: _getNotificationsPerPage,
          onRefresh: _getNotifications,
          child: notificationsBloc.notifacations.isNotEmpty
              ? const NotificationsList()
              : const Center(
                  child: EmptyScreen(
                    image: AssetsManager.notificationsEmpty,
                    text: AppStrings.thereIsNoNotifivationsYet,
                  ),
                ),
        );
      },
    );
  }
}
