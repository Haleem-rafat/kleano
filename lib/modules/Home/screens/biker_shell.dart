import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/screens/earnings_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/orders_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';

/// The app's four tabs. Today stays mounted, because what it sends on open must
/// be sent once and it listens for notifications. The other tabs are built when
/// selected, so each loads its data every time it is opened.
class BikerShell extends StatefulWidget {
  const BikerShell({super.key, required this.initialIndex});

  /// 0 opens Today; 2 opens Orders on Completed (notifications ask for that,
  /// from when Home had three order tabs).
  final int initialIndex;

  @override
  State<BikerShell> createState() => _BikerShellState();
}

class _BikerShellState extends State<BikerShell> {
  static const int _today = 0;
  static const int _orders = 1;
  static const int _earnings = 2;

  late int _index;
  late final ValueNotifier<OrdersSegment> _segment;
  DateTime _lastBack = DateTime.now();

  @override
  void initState() {
    super.initState();
    final bool openCompleted = widget.initialIndex != 0;
    _index = openCompleted ? _orders : _today;
    _segment = ValueNotifier<OrdersSegment>(
      openCompleted ? OrdersSegment.completed : OrdersSegment.active,
    );
  }

  @override
  void dispose() {
    _segment.dispose();
    super.dispose();
  }

  void _onBack(bool didPop, Object? result) {
    if (didPop) return;
    final bool canExit =
        DateTime.now().difference(_lastBack) < const Duration(seconds: 2);
    _lastBack = DateTime.now();
    if (canExit) {
      SystemNavigator.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(AppStrings.backButton)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  GlassTabItem _tab(String label, String icon, String selectedIcon) =>
      GlassTabItem(
        label: label,
        svgAsset: icon,
        iconBuilder: (bool selected, Color color) => SvgPicture.asset(
          selected ? selectedIcon : icon,
          width: KSpace.xxl,
          height: KSpace.xxl,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        backgroundColor: c.background,
        extendBody: true,
        body: IndexedStack(
          index: _index == _today ? 0 : 1,
          sizing: StackFit.expand,
          children: <Widget>[
            const HomeScreen(),
            switch (_index) {
              _today => const SizedBox.shrink(),
              _orders => OrdersScreen(segment: _segment),
              _earnings => const EarningsScreen(),
              _ => const ProfileScreen(isTab: true),
            },
          ],
        ),
        bottomNavigationBar: GlassTabBar(
          currentIndex: _index,
          activeColor: c.brand,
          inactiveColor: c.textSecondary,
          labelStyle: KType.caption,
          onTap: (int index) => setState(() => _index = index),
          items: <GlassTabItem>[
            _tab(
              tr(context, AppStrings.today),
              ImageAssets.tabBarHomeIconLogo,
              ImageAssets.tabBarHomeSelectedIconLogo,
            ),
            _tab(
              tr(context, AppStrings.ordersTab),
              ImageAssets.bookingsIconLogo,
              ImageAssets.bookingsSelectedIconLogo,
            ),
            _tab(
              tr(context, AppStrings.earnings),
              ImageAssets.serviceCoinSvg,
              ImageAssets.serviceCoinSvg,
            ),
            _tab(
              tr(context, AppStrings.profile),
              ImageAssets.profileIconLogo,
              ImageAssets.profileSelectedIconLogo,
            ),
          ],
        ),
      ),
    );
  }
}
