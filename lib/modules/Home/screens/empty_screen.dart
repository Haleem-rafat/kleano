import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';

/// Nothing to show: no requests on Home, or no notifications ([notification]).
class EmptyScreen extends StatelessWidget {
  final bool notification;
  final String text;
  const EmptyScreen({
    super.key,
    required this.notification,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (!notification) {
      return KEmptyState(
        title: tr(context, AppStrings.newRequests),
        message: tr(context, text),
      );
    }
    // The notification screen hosts this in a Row (unbounded width) under a
    // fixed height, so give it the screen's width and let it shrink to fit.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: KEmptyState(
          icon: Icons.notifications_none_rounded,
          title: tr(context, text),
        ),
      ),
    );
  }
}
