import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/active_promo_code.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/expired_promo_code.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/used_promo_code.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/shared/components/tab_bar/default_tab_bar.dart';

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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.promoCodes),
        ),
      ),
      body: Column(
        children: <Widget>[
          AppPadding.p10.ph,
          SizedBox(
              height: 30.h,
              width: Localizations.localeOf(context).languageCode == 'en'
                  ? 271.w
                  : null,
              child: DefaultTabBarShared(
                tabController: _tabController,
                tabWidget: <Tab>[
                  Tab(
                    text: translate(AppStrings.active),
                  ),
                  Tab(
                    text: translate(AppStrings.used),
                  ),
                  Tab(
                    text: translate(AppStrings.expired),
                  )
                ],
              )),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Row(
              children: [
                Text(
                  "Show Promo Codes",
                  style:
                      AppStyles.title16Bold.copyWith(color: ColorManager.black),
                ),
                const Spacer(),
                Switch(
                    value: isVisible,
                    onChanged: (value) {
                      setState(() {
                        isVisible = value;
                      });
                    }),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }
}
