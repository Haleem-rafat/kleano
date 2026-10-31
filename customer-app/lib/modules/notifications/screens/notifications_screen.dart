import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/notifications/widgets/all_notification.dart';
import 'package:thewasher/utilties/navigator.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 60,
        leading: GlassBackButton(color: c.brand, onPressed: () => pop(context)),
        title: Text(
          translate(AppStrings.notifications),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: const AllNotifications(),
    );
  }
}
