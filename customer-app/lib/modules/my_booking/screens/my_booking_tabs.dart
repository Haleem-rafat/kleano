import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_segmented.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_active.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_history.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_scheduled.dart';
import 'package:thewasher/modules/my_vehicles/widgets/guest_my_vehicles.dart';

class MyBookingMainTabsScreen extends StatefulWidget {
  const MyBookingMainTabsScreen({super.key});

  @override
  State<MyBookingMainTabsScreen> createState() =>
      _MyBookingMainTabsScreenState();
}

class _MyBookingMainTabsScreenState extends State<MyBookingMainTabsScreen> {
  static const List<Widget> _tabs = <Widget>[
    MyBookingActive(),
    MyBookingHistory(),
    MyBookingScheduled(),
  ];

  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        title: Text(
          translate(AppStrings.myBookings),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: isGuestUser
          ? GuestMyVehicles()
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KSpace.xl,
                    KSpace.s,
                    KSpace.xl,
                    KSpace.s,
                  ),
                  child: KSegmented<int>(
                    segments: <int, String>{
                      0: translate(AppStrings.active),
                      1: translate(AppStrings.history),
                      2: translate(AppStrings.schedule),
                    },
                    selected: currentTabIndex,
                    onChanged: (int index) =>
                        setState(() => currentTabIndex = index),
                  ),
                ),
                Expanded(child: _tabs[currentTabIndex]),
              ],
            ),
    );
  }
}
