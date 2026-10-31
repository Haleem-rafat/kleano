import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/modules/profile/widgets/empty_promo_widget.dart';
import 'package:thewasher/modules/profile/widgets/promo_widget.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class ActivePromoCode extends StatefulWidget {
  final bool isVisible;
  final String? highlightPromoId;
  final ValueChanged<PromoCodeTypes>? onPromoLocated;
  const ActivePromoCode({
    super.key,
    required this.isVisible,
    this.highlightPromoId,
    this.onPromoLocated,
  });

  @override
  State<ActivePromoCode> createState() => _ActivePromoCodeState();
}

class _ActivePromoCodeState extends State<ActivePromoCode> {
  PromoBloc promoBloc = sl<PromoBloc>();
  final GlobalKey _highlightKey = GlobalKey();
  bool _didScrollToHighlight = false;
  @override
  void initState() {
    super.initState();
    promoBloc.add(GetActivePromo());
  }

  @override
  void didUpdateWidget(covariant ActivePromoCode oldWidget) {
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
      widget.onPromoLocated?.call(PromoCodeTypes.active);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromoBloc, PromoState>(
      bloc: promoBloc,
      builder: (context, state) {
        if (state is GetActivePromoLoading) {
          return const KLoadingState();
        } else if (state is GetActivePromoEmpty) {
          return const EmptyPromoWidget();
        } else if (state is GetActivePromoError) {
          return KErrorState(
            message: translate('somethingWentWrong'),
            onRetry: () => promoBloc.add(GetActivePromo()),
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(KSpace.xl),
            itemCount: promoBloc.activeList.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: KSpace.m);
            },
            itemBuilder: (context, index) {
              final promo = promoBloc.activeList[index];
              final bool isHighlighted =
                  widget.highlightPromoId != null &&
                  promo.sId == widget.highlightPromoId;
              if (isHighlighted) {
                _scrollHighlightIntoView();
              }
              return PromoContainerWidget(
                key: isHighlighted ? _highlightKey : null,
                promoCodeModel: promo,
                type: PromoCodeTypes.active.name,
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
