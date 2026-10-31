import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_segmented.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/active_promo_code.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/expired_promo_code.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/used_promo_code.dart';
import 'package:thewasher/utilties/navigator.dart';

enum PromoCodeTypes { active, used, expired }

bool isVisible = false;

class PromoCodeScreen extends StatefulWidget {
  final String? highlightPromoId;
  const PromoCodeScreen({super.key, this.highlightPromoId});
  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasHandledHighlight = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handlePromoLocated(PromoCodeTypes type) {
    if (_hasHandledHighlight) return;
    _hasHandledHighlight = true;
    final targetIndex = PromoCodeTypes.values.indexOf(type);
    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }
  }

  List<Widget> get screens => <Widget>[
    ActivePromoCode(
      isVisible: isVisible,
      highlightPromoId: widget.highlightPromoId,
      onPromoLocated: _handlePromoLocated,
    ),
    UsedPromoCode(
      isVisible: isVisible,
      highlightPromoId: widget.highlightPromoId,
      onPromoLocated: _handlePromoLocated,
    ),
    ExpiredPromoCode(
      isVisible: isVisible,
      highlightPromoId: widget.highlightPromoId,
      onPromoLocated: _handlePromoLocated,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.promoCodes)),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KSpace.xl,
              KSpace.s,
              KSpace.xl,
              KSpace.s,
            ),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (BuildContext context, Widget? child) {
                return KSegmented<PromoCodeTypes>(
                  segments: <PromoCodeTypes, String>{
                    PromoCodeTypes.active: translate(AppStrings.active),
                    PromoCodeTypes.used: translate(AppStrings.used),
                    PromoCodeTypes.expired: translate(AppStrings.expired),
                  },
                  selected: PromoCodeTypes.values[_tabController.index],
                  onChanged: (PromoCodeTypes type) {
                    _tabController.animateTo(type.index);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Show Promo Codes',
                    style: KType.body.copyWith(color: c.text),
                  ),
                ),
                Switch.adaptive(
                  value: isVisible,
                  onChanged: (bool value) {
                    setState(() {
                      isVisible = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: screens),
          ),
        ],
      ),
    );
  }
}
