import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/modules/profile/widgets/empty_promo_widget.dart';
import 'package:thewasher/modules/profile/widgets/promo_widget.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class ExpiredPromoCode extends StatefulWidget {
  final bool isVisible;
  final String? highlightPromoId;
  final ValueChanged<PromoCodeTypes>? onPromoLocated;
  const ExpiredPromoCode({
    Key? key,
    required this.isVisible,
    this.highlightPromoId,
    this.onPromoLocated,
  }) : super(key: key);

  @override
  State<ExpiredPromoCode> createState() => _ExpiredPromoCodeState();
}

class _ExpiredPromoCodeState extends State<ExpiredPromoCode> {
  final PromoBloc promoBloc = sl<PromoBloc>();
  final GlobalKey _highlightKey = GlobalKey();
  bool _didScrollToHighlight = false;
  @override
  void initState() {
    super.initState();
    promoBloc.add(GetExpiredPromo());
  }

  @override
  void didUpdateWidget(covariant ExpiredPromoCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightPromoId != widget.highlightPromoId) {
      _didScrollToHighlight = false;
    }
  }

  void _scrollHighlightIntoView() {
    if (_didScrollToHighlight) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _highlightKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        alignment: 0.1,
        curve: Curves.easeInOut,
      );
      _didScrollToHighlight = true;
      widget.onPromoLocated?.call(PromoCodeTypes.expired);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromoBloc, PromoState>(
      bloc: promoBloc,
      builder: (context, state) {
        if (state is GetExpiredPromoLoading) {
          return const LoadingWidget();
        } else if (state is GetExpiredPromoEmpty) {
          return const EmptyPromoWidget();
        } else if (state is GetExpiredPromoError) {
          return Container();
        } else {
          return ListView.separated(
            itemCount: promoBloc.expiredList.length,
            separatorBuilder: (context, index) {
              return AppPadding.p18.ph;
            },
            itemBuilder: (context, index) {
              final promo = promoBloc.expiredList[index];
              final bool isHighlighted =
                  widget.highlightPromoId != null &&
                      widget.highlightPromoId == promo.sId;
              if (isHighlighted) {
                _scrollHighlightIntoView();
              }
              return PromoContainerWidget(
                key: isHighlighted ? _highlightKey : null,
                promoCodeModel: promo,
                type: PromoCodeTypes.expired.name,
                isVisible: widget.isVisible,
                isHighlighted: isHighlighted,
              );
            },
          );
        }
      },
    );
  }
}
