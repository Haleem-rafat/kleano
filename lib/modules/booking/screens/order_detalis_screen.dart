import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:moyasar/moyasar.dart';
import 'package:thewasher/core/config/api_keys.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/utilis/card_formatters.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/piked_model.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
import 'package:thewasher/modules/booking/data/models/payment_type_model.dart';
import 'package:thewasher/modules/booking/widgets/card_form.dart';
import 'package:thewasher/modules/booking/widgets/card_payment_type.dart';
import 'package:thewasher/modules/booking/widgets/functions/create_order_data_request.dart';
import 'package:thewasher/modules/booking/widgets/location/fixed_map.dart';
import 'package:thewasher/modules/booking/widgets/payment_webview.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';
import 'package:thewasher/modules/points/data/repo/point_repo.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

String? orderIdd;

class OrderDetalisScreen extends StatefulWidget {
  const OrderDetalisScreen({super.key});

  @override
  State<OrderDetalisScreen> createState() => _OrderDetalisScreenState();
}

class _OrderDetalisScreenState extends State<OrderDetalisScreen> {
  late final PickedLocationModel location;
  late final PlansAndSubscriptionBloc subscriptionBloc;
  late final OffersBloc offersBloc;
  late final BookingOrderBloc createOrderBloc;
  int? selectedPaymentType;
  GeneralSingleton generalSingleton = GeneralSingleton();
  String? applePayId;
  bool _isProcessingPayment = false;
  final TextEditingController _promoCode = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  bool _isPromoApplied = false;
  late bool _inputMode; // true = input mode, false = applied mode
  double? _applePayTotal;
  bool _isPointsLoading = false;
  bool _isPointsApplied = false;
  num? _pointsDiscountAmount;

  @override
  void initState() {
    super.initState();
    location = sl<LocationBloc>().pickedLocationModel;
    subscriptionBloc = sl<PlansAndSubscriptionBloc>();
    offersBloc = sl<OffersBloc>();
    createOrderBloc = sl<BookingOrderBloc>();
    selectedPaymentType = createOrderBloc.paymentType;
    // _promoCode.text = copiedPromoCode?.promoCode ?? '';
    _inputMode = copiedPromoCode == null;
    _applePayTotal = generalSingleton.totalPay?.toDouble();
    // KTextField has no onChanged: the buttons below follow these fields.
    _promoCode.addListener(_onFieldChanged);
    _pointsController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _promoCode.dispose();
    _pointsController.dispose();
    createOrderBloc.paymentType = 0;
    selectedPaymentType = null;
    super.dispose();
  }

  String humanReadableDateTime(DateTime dateTime) {
    return intl.DateFormat(
      'EEE, MMM dd, yyyy • hh:mm a',
      'en',
    ).format(dateTime);
  }

  void _onFieldChanged() => setState(() {});

  void _onPromoState(BuildContext context, PromoState state) {
    if (state is GetPromoCodeDetailSuccess) {
      // Set copiedPromoCode so it gets included in order creation
      // copiedPromoCode = CopyPromoCode(
      //   promoCode: _promoCode.text,
      //   id: _promoCode.text,
      // );

      // Set promo as applied
      setState(() {
        _isPromoApplied = true;
      });

      // Show success message with promo code details
      showSnackBar(
        buildContext: context,
        message: translate(
          AppStrings.promoCodeAppliedSuccessfully,
        ).replaceAll('{amount}', '${state.promoCodeDetail.discountAmount}'),
      );
    } else if (state is GetPromoCodeDetailError) {
      // Show error message from API response
      String errorMessage;
      if (state.errorModel != null) {
        errorMessage = Localizations.localeOf(context).languageCode == 'en'
            ? (state.errorModel!.en ??
                  state.errorModel!.ar ??
                  translate(AppStrings.promoCodeNotValid))
            : (state.errorModel!.ar ??
                  state.errorModel!.en ??
                  translate(AppStrings.promoCodeNotValid));
      } else {
        errorMessage = state.error ?? translate(AppStrings.promoCodeNotValid);
      }
      showSnackBar(buildContext: context, message: errorMessage);
      setState(() {
        _isPromoApplied = false;
      });
    } else if (state is PromoCodeDetailCleared) {
      // Reset promo applied state when cleared
      setState(() {
        _isPromoApplied = false;
      });
    }
  }

  void _onBack() {
    // Clear promo code when going back
    sl<PromoBloc>().add(ClearPromoCodeDetail());
    copiedPromoCode = null;
    _promoCode.clear();

    // Clear order details when going back
    generalSingleton.orderId = null;
    generalSingleton.totalPay = null;
    generalSingleton.orderTime = null;
    generalSingleton.nearByDescription = null;
    generalSingleton.isCarFreshened = false;
    generalSingleton.appliedPoints = 0;
    selectedPaymentType = null;

    // Clear points discount
    setState(() {
      _isPointsApplied = false;
      _pointsDiscountAmount = null;
      _pointsController.clear();
    });

    orderIdd = null;

    setState(() {
      _isPromoApplied = false;
      _inputMode = true;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final PreferredSizeWidget appBar = _buildAppBar();
    // Not a ListView: the payment rows hold the order listeners and must stay
    // mounted while scrolled away.
    final Widget body = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.l,
        KSpace.xl,
        MediaQuery.viewPaddingOf(context).bottom + 96,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildVehicleCard(),
          _buildLocationCard(),
          _buildNotesCard(),
          _buildPromoSection(),
          _buildPointsCard(),
          _buildOrderSummaryCard(),
          _buildPaymentMethodsCard(),
        ],
      ),
    );
    final Widget bottomBar = SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.s,
        KSpace.xl,
        KSpace.l,
      ),
      child: _buildBottomAction(),
    );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocListener<PromoBloc, PromoState>(
        listener: _onPromoState,
        // Only the scaffold rebuilds as the keyboard moves.
        child: Builder(
          builder: (BuildContext context) => Scaffold(
            backgroundColor: c.background,
            // The details scroll under the floating button. With the keyboard
            // up they stop at the keyboard, so a focused field stays visible.
            extendBody: MediaQuery.viewInsetsOf(context).bottom == 0,
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomBar,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: GlassBackButton(onPressed: _onBack),
      title: Text(translate(AppStrings.orderDetails)),
    );
  }

  Widget _buildPromoSection() {
    final bool showInput = copiedPromoCode == null || _inputMode;
    final bool showToggle =
        copiedPromoCode != null ||
        _inputMode == false && _promoCode.text.isEmpty;
    return _Section(
      title: showInput ? translate(AppStrings.addPromoCode) : null,
      action: showToggle
          ? KButton(
              label: _inputMode == false
                  ? translate(AppStrings.addPromoCode)
                  : translate(AppStrings.back),
              variant: KButtonVariant.text,
              expand: false,
              onPressed: () {
                setState(() {
                  _inputMode = !_inputMode;
                  sl<PromoBloc>().add(ClearPromoCodeDetail());
                });
              },
            )
          : null,
      child: KCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (showInput) _buildPromoInput() else _buildPromoApplied(),
            _buildPromoDetails(showHeader: showInput),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoInput() {
    return Padding(
      padding: const EdgeInsets.all(KSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          KTextField(
            label: translate(AppStrings.promoCodeHint),
            controller: _promoCode,
          ),
          if (_promoCode.text.isNotEmpty) ...<Widget>[
            const SizedBox(height: KSpace.m),
            _applyOrRemoveButton(
              applied: _isPromoApplied,
              onPressed: _isPromoApplied
                  ? () {
                      sl<PromoBloc>().add(ClearPromoCodeDetail());
                      setState(() {
                        _isPromoApplied = false;
                      });
                    }
                  : () {
                      copiedPromoCode = CopyPromoCode(
                        promoCode: _promoCode.text,
                        id: _promoCode.text,
                      );
                      final totalPrice =
                          generalSingleton.totalPay ?? offersBloc.total;
                      sl<PromoBloc>().add(
                        GetPromoCodeDetail(
                          promoCode: _promoCode.text,
                          totalPrice: totalPrice.toString(),
                        ),
                      );
                      setState(() {
                        _isPromoApplied = true;
                      });
                    },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromoApplied() {
    return KListRow(
      leading: Icon(Icons.local_offer, color: KColors.of(context).brand),
      title: translate(AppStrings.promoCodeApplied),
      subtitle: "${copiedPromoCode?.promoCode}",
      trailing: _applyOrRemoveButton(
        applied: _isPromoApplied,
        expand: false,
        onPressed: _isPromoApplied
            ? () {
                setState(() {
                  // _promoCode.clear();
                  _isPromoApplied = false;
                });
                // Clear copiedPromoCode so it doesn't get included in order creation
                // copiedPromoCode = null; // Keep promo code data for re-application
                // Clear promo code state and reset to initial state
                sl<PromoBloc>().add(ClearPromoCodeDetail());
              }
            : () {
                final totalPrice =
                    generalSingleton.totalPay ?? offersBloc.total;
                sl<PromoBloc>().add(
                  GetPromoCodeDetail(
                    promoCode: copiedPromoCode?.promoCode ?? '',
                    totalPrice: totalPrice.toString(),
                  ),
                );
              },
      ),
    );
  }

  Widget _buildPromoDetails({required bool showHeader}) {
    return BlocBuilder<PromoBloc, PromoState>(
      builder: (context, state) {
        if (state is GetPromoCodeDetailSuccess) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(KSpace.l, 0, KSpace.l, KSpace.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (showHeader)
                  _appliedChip(translate(AppStrings.promoCodeApplied)),
                _AmountRow(
                  label: translate(AppStrings.originalPrice),
                  amount: "${generalSingleton.totalPay ?? offersBloc.total}",
                ),
                _AmountRow(
                  label: translate(AppStrings.discount),
                  amount: "-${state.promoCodeDetail.discountAmount}",
                ),
                _AmountRow(
                  label: translate(AppStrings.finalPrice),
                  amount: "${state.promoCodeDetail.totalPayAfterDiscount}",
                  emphasized: true,
                ),
              ],
            ),
          );
        } else if (state is GetPromoCodeDetailLoading) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(KSpace.l, 0, KSpace.l, KSpace.l),
            child: _InlineProgress(
              message: translate(AppStrings.validatingPromoCode),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Apply is an action in the content; Remove is a quiet destructive link.
  Widget _applyOrRemoveButton({
    required bool applied,
    required VoidCallback? onPressed,
    bool loading = false,
    bool expand = true,
  }) {
    return KButton(
      label: applied
          ? translate(AppStrings.removeButton)
          : translate(AppStrings.apply),
      variant: applied ? KButtonVariant.text : KButtonVariant.secondary,
      color: applied ? KColors.of(context).error : null,
      loading: loading,
      expand: expand,
      onPressed: onPressed,
    );
  }

  Widget _appliedChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSpace.s),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: KStatusChip(label: label, status: KStatus.success),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final KColors c = KColors.of(context);
    return _Section(
      child: KCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.schedule, color: c.textSecondary, size: KSpace.xl),
                const SizedBox(width: KSpace.s),
                Expanded(
                  child: Text(
                    humanReadableDateTime(
                      GeneralSingleton().orderTime ?? DateTime.now(),
                    ),
                    style: KType.subhead.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KSpace.s),
            _buildServicesSummary(),
            Divider(height: KSpace.xxl, color: c.separator),
            _buildTotal(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal() {
    final KColors c = KColors.of(context);
    return BlocBuilder<PromoBloc, PromoState>(
      builder: (context, state) {
        double totalAmount = offersBloc.total.toDouble();
        bool hasPromoCode = false;
        bool hasPointsDiscount =
            _isPointsApplied && _pointsDiscountAmount != null;

        if (state is GetPromoCodeDetailSuccess) {
          totalAmount =
              state.promoCodeDetail.totalPayAfterDiscount?.toDouble() ??
              offersBloc.total.toDouble();
          hasPromoCode = true;
        } else if (state is PromoCodeDetailCleared) {
          // Reset to original amount when cleared
          totalAmount = offersBloc.total.toDouble();
          hasPromoCode = false;
        }

        // Apply points discount
        if (hasPointsDiscount && _pointsDiscountAmount != null) {
          totalAmount = totalAmount - _pointsDiscountAmount!.toDouble();
          if (totalAmount < 0) totalAmount = 0;
        }

        final bool hasAnyDiscount = hasPromoCode || hasPointsDiscount;

        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                translate(AppStrings.totalPay),
                style: KType.headline.copyWith(color: c.text),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (hasAnyDiscount)
                  // Show original price with strikethrough
                  _Amount(
                    "${offersBloc.total}",
                    style: KType.subhead.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                    color: c.textSecondary,
                  ),
                _Amount("$totalAmount", style: KType.title, color: c.text),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildServicesSummary() {
    final TextStyle style = KType.subhead.copyWith(
      color: KColors.of(context).text,
    );
    if (sl.call<GetUserProfileBloc>().profile.isSubscribed! &&
        offersBloc.cartServicesList.isEmpty &&
        offersBloc.cartAddOnsList.isEmpty) {
      return Text(
        '${subscriptionBloc.subscription.remainingWashes} ${translate(AppStrings.outOf)} ${subscriptionBloc.subscription.plan!.usageCount!} ${subscriptionBloc.subscription.plan!.type!} ${translate(AppStrings.washes)}',
        style: style,
      );
    }

    // Filter and format services
    final services = offersBloc.cartServicesList
        .where((s) => s.name != null && s.name!.isNotEmpty)
        .toList();
    final addOns = offersBloc.cartAddOnsList
        .where((a) => a.name != null && a.name!.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (services.isNotEmpty)
          Text(
            '${translate(AppStrings.services)}: ${services.map((s) => s.name).join(', ')}',
            style: style,
          ),
        if (services.isNotEmpty && addOns.isNotEmpty)
          const SizedBox(height: KSpace.xs),
        if (addOns.isNotEmpty)
          Text(
            '${translate(AppStrings.addOns)}: ${addOns.map((a) => a.name).join(', ')}',
            style: style,
          ),
      ],
    );
  }

  Widget _buildVehicleCard() {
    final KColors c = KColors.of(context);
    final vehicleBloc = sl<VehiclesBloc>();
    final vehicle = vehicleBloc.selectedVehicle;

    // Check if vehicle is available
    final bool hasVehicle = !(vehicle.sId == null || vehicle.sId!.isEmpty);

    return _Section(
      title: translate(AppStrings.myVehicle),
      child: KCard(
        padding: EdgeInsets.zero,
        child: hasVehicle
            ? KListRow(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(KRadius.field),
                  child: ColoredBox(
                    color: c.fill,
                    child: SizedBox.square(
                      dimension: _vehiclePhotoSize,
                      child: vehicle.imageLink != null
                          ? CachedNetworkImage(
                              imageUrl: vehicle.imageLink!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.directions_car, color: c.textSecondary),
                    ),
                  ),
                ),
                title: "${vehicle.brand} ${vehicle.model}",
                subtitle:
                    '${vehicle.color ?? "N/A"} · ${vehicle.plateNumber ?? "N/A"}',
              )
            : KListRow(
                leading: Icon(Icons.warning_amber_rounded, color: c.warning),
                title: translate(AppStrings.noVehicleSelected),
              ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return _Section(
      title: translate(AppStrings.serviceLocation),
      child: KCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FixedMap(
              height: _mapHeight,
              latLng: LatLng(blcoPosition.latitude, blcoPosition.longitude),
            ),
            KListRow(
              leading: Icon(Icons.place, color: KColors.of(context).brand),
              title: blcoCountry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    final notes = GeneralSingleton().nearByDescription;
    if (notes == null || notes.isEmpty) return const SizedBox.shrink();

    return _Section(
      title: translate(AppStrings.additionalNotes),
      child: KCard(
        child: Text(
          notes,
          style: KType.body.copyWith(color: KColors.of(context).text),
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    final KColors c = KColors.of(context);

    final userProfileBloc = sl<GetUserProfileBloc>();
    final availablePoints = userProfileBloc.profile.points ?? 0;
    final enteredPoints = num.tryParse(_pointsController.text.trim()) ?? 0;
    final exceedsLimit = enteredPoints > availablePoints;
    final hasError = _pointsController.text.isNotEmpty && exceedsLimit;

    return _Section(
      title: translate(AppStrings.points),
      action: KStatusChip(
        label: translate(
          AppStrings.availablePoints,
        ).replaceAll('{points}', '$availablePoints'),
        status: KStatus.brand,
      ),
      child: KCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            KTextField(
              label: translate(AppStrings.enterPointsToApply),
              controller: _pointsController,
              keyboardType: TextInputType.number,
            ),
            if (hasError) ...<Widget>[
              const SizedBox(height: KSpace.s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.error_outline, size: KSpace.l, color: c.error),
                  const SizedBox(width: KSpace.xs),
                  Expanded(
                    child: Text(
                      '${translate(AppStrings.pointsExceedAvailableLimit)}\n'
                      '${translate(AppStrings.youCanOnlyUseUpToPointsSimple).replaceAll('{points}', '$availablePoints')}',
                      style: KType.footnote.copyWith(color: c.error),
                    ),
                  ),
                ],
              ),
            ],
            if (_pointsController.text.isNotEmpty) ...<Widget>[
              const SizedBox(height: KSpace.m),
              _applyOrRemoveButton(
                applied: _isPointsApplied,
                loading: _isPointsLoading,
                onPressed: _isPointsLoading || exceedsLimit
                    ? null
                    : _isPointsApplied
                    ? _removePointsDiscount
                    : _applyPointsDiscount,
              ),
            ],
            // Points Discount Details Display
            if (_isPointsApplied && _pointsDiscountAmount != null) ...<Widget>[
              const SizedBox(height: KSpace.m),
              _appliedChip(translate(AppStrings.pointsApplied)),
              _AmountRow(
                label: translate(AppStrings.discount),
                amount: "-$_pointsDiscountAmount",
              ),
            ],
            if (_isPointsLoading) ...<Widget>[
              const SizedBox(height: KSpace.m),
              _InlineProgress(
                message: translate(AppStrings.calculatingDiscount),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _removePointsDiscount() {
    // Recalculate total without points discount
    final promoState = context.read<PromoBloc>().state;
    double baseTotal =
        generalSingleton.totalPay?.toDouble() ?? offersBloc.total.toDouble();

    // Apply promo code discount if exists
    if (promoState is GetPromoCodeDetailSuccess) {
      baseTotal =
          promoState.promoCodeDetail.totalPayAfterDiscount?.toDouble() ??
          baseTotal;
    } else {
      final discount = sl<PromoBloc>().totalPayModel.discount ?? 0;
      baseTotal = baseTotal - discount;
    }

    setState(() {
      _isPointsApplied = false;
      _pointsDiscountAmount = null;
      generalSingleton.appliedPoints = 0;
      // Update Apple Pay total to remove points discount
      _applePayTotal = baseTotal;
    });
  }

  Future<void> _applyPointsDiscount() async {
    final pointsText = _pointsController.text.trim();
    if (pointsText.isEmpty) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.pleaseEnterPointsToApply),
      );
      return;
    }

    final points = num.tryParse(pointsText);
    if (points == null || points <= 0) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.pleaseEnterValidNumberOfPoints),
      );
      return;
    }

    // Validate against available points
    final userProfileBloc = sl<GetUserProfileBloc>();
    final availablePoints = userProfileBloc.profile.points ?? 0;
    if (points > availablePoints) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.youCanOnlyUseUpToPoints)
            .replaceAll('{points}', '$availablePoints')
            .replaceAll('{entered}', '$points'),
      );
      return;
    }

    setState(() {
      _isPointsLoading = true;
      _isPointsApplied = false;
    });

    try {
      final discountModel = await PointRepo.calculatePointsDiscount(
        points: points,
      );

      // Calculate new total with points discount
      if (!mounted) return;
      final promoState = context.read<PromoBloc>().state;
      double baseTotal =
          generalSingleton.totalPay?.toDouble() ?? offersBloc.total.toDouble();

      // Apply promo code discount if exists
      if (promoState is GetPromoCodeDetailSuccess) {
        baseTotal =
            promoState.promoCodeDetail.totalPayAfterDiscount?.toDouble() ??
            baseTotal;
      } else {
        final discount = sl<PromoBloc>().totalPayModel.discount ?? 0;
        baseTotal = baseTotal - discount;
      }

      // Apply points discount
      final newTotal = baseTotal - discountModel.discountAmount!.toDouble();
      final finalTotal = newTotal < 0 ? 0.0 : newTotal;

      setState(() {
        _isPointsLoading = false;
        _isPointsApplied = true;
        _pointsDiscountAmount = discountModel.discountAmount;
        generalSingleton.appliedPoints = discountModel.points ?? 0;
        // Update Apple Pay total to include points discount
        _applePayTotal = finalTotal;
      });

      if (!mounted) return;
      showSnackBar(
        buildContext: context,
        message: translate(
          AppStrings.pointsAppliedSuccessfully,
        ).replaceAll('{amount}', '${discountModel.discountAmount}'),
      );
    } catch (e) {
      setState(() {
        _isPointsLoading = false;
      });
      if (!mounted) return;
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.failedToApplyPoints),
      );
    }
  }

  void _onBookingOrderState(BuildContext context, BookingOrderState state) {
    if (state is CreateOrderSuccess) {
      final orderData = state.reviewOrderModel.data;
      final newOrderId = orderData?.sId;
      final newTotalPay = orderData?.totalPay?.toDouble();

      if (newOrderId != null && newOrderId.isNotEmpty) {
        generalSingleton.orderId = newOrderId;
        orderIdd = newOrderId;
      }

      if (newTotalPay != null) {
        generalSingleton.totalPay = newTotalPay;
        if (_applePayTotal != newTotalPay) {
          if (mounted) {
            setState(() {
              _applePayTotal = newTotalPay;
            });
          } else {
            _applePayTotal = newTotalPay;
          }
        }
      }

      if ((newTotalPay ?? 0) == 0) {
        AlertHelper.createOrderSuccess(context);
      }
    } else if (state is CreateOrderFailed) {
      setState(() {
        _isProcessingPayment = false;
      });

      if (state.errorModel!.en == AppStrings.yourWalletBalanceIsNotValid ||
          state.errorModel!.ar == AppStrings.yourWalletBalanceIsNotValid) {
        AlertHelper.payWithWalletNotEnoughAmount(context);
      } else {
        showSnackBar(
          buildContext: context,
          message: Localizations.localeOf(context).languageCode == 'en'
              ? state.errorModel!.en!
              : state.errorModel!.ar!,
        );
      }
    } else if (state is PlaceOrderSuccess) {
      // Prevent multiple success handling
      if (_isProcessingPayment) {
        setState(() {
          _isProcessingPayment = false;
        });
        _onOrderSuccess(context, transactionUrl: state.paymentUrl);
      }
    } else if (state is PlaceOrderFailed) {
      setState(() {
        _isProcessingPayment = false;
      });
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'en'
            ? state.errormodel!.en!
            : state.errormodel!.ar!,
      );
    }
  }

  Widget _buildPaymentMethodsCard() {
    return BlocBuilder<PromoBloc, PromoState>(
      builder: (context, promoState) {
        final double totalAmount = _calculateTotalAmount(promoState);

        if (totalAmount <= 0) {
          _resetPaymentSelectionForZeroTotal();
          return const SizedBox.shrink();
        }

        // Deselect wallet if balance is insufficient
        final bool isWalletLocked = (walletBalance ?? 0) < totalAmount;
        if (isWalletLocked && createOrderBloc.paymentType == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              createOrderBloc.paymentType = 0;
              selectedPaymentType = null;
            });
          });
        }

        List<PaymentMethodModel> paymentMethods =
            PaymentMethodModel.listPaymentMethods;
        if (!Platform.isIOS) {
          paymentMethods = paymentMethods.where((m) => m.value != 3).toList();
        }

        return _Section(
          title: translate(AppStrings.choosePaymentMethod),
          child: KCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < paymentMethods.length; i++) ...<Widget>[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: CardPaymentMethod.dividerIndent,
                      color: KColors.of(context).separator,
                    ),
                  _buildPaymentRow(paymentMethods[i], promoState),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentRow(PaymentMethodModel type, PromoState promoState) {
    return BlocConsumer<BookingOrderBloc, BookingOrderState>(
      listener: _onBookingOrderState,
      builder: (context, state) {
        final double currentTotalAmount = _calculateTotalAmount(promoState);
        final bool isWalletLocked =
            type.value == 2 && (walletBalance ?? 0) < currentTotalAmount;

        return CardPaymentMethod(
          walletBalance: walletBalance ?? 0,
          isWallet: type.value == 2,
          type: type,
          groupValue: createOrderBloc.paymentType,
          onTap: isWalletLocked
              ? () {
                  showSnackBar(
                    buildContext: context,
                    message:
                        '${translate(AppStrings.yourWalletBalanceIsNotValid)} Required: ${currentTotalAmount.toStringAsFixed(2)}',
                  );
                }
              : () => _handlePaymentSelection(type),
        );
      },
    );
  }

  double _calculateTotalAmount(PromoState promoState) {
    double totalAmount =
        generalSingleton.totalPay?.toDouble() ?? offersBloc.total.toDouble();

    if (promoState is GetPromoCodeDetailSuccess) {
      totalAmount =
          promoState.promoCodeDetail.totalPayAfterDiscount?.toDouble() ??
          totalAmount;
    } else if (promoState is PromoCodeDetailCleared) {
      totalAmount =
          generalSingleton.totalPay?.toDouble() ?? offersBloc.total.toDouble();
    } else {
      final discount = sl<PromoBloc>().totalPayModel.discount ?? 0;
      totalAmount = totalAmount - discount;
    }

    // Subtract points discount if applied
    // if (_isPointsApplied && _pointsDiscountAmount != null) {
    //   totalAmount = totalAmount - _pointsDiscountAmount!.toDouble();
    //   if (totalAmount < 0) totalAmount = 0;
    // }

    return totalAmount;
  }

  void _resetPaymentSelectionForZeroTotal() {
    if (createOrderBloc.paymentType != 0 || selectedPaymentType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          createOrderBloc.paymentType = 0;
          selectedPaymentType = null;
        });
      });
    }
  }

  Widget _buildBottomAction() {
    return BlocBuilder<PromoBloc, PromoState>(
      builder: (context, promoState) {
        final double totalAmount = _calculateTotalAmount(promoState);

        if (totalAmount <= 0) {
          return _buildRegularConfirmButton();
        }

        // Show Apple Pay widget only if Apple Pay is selected
        if (selectedPaymentType == 3 && createOrderBloc.paymentType == 3) {
          return _buildApplePayWidget(totalAmount);
        }

        // Show confirm button for wallet and credit card payment methods
        if ((selectedPaymentType == 2 && createOrderBloc.paymentType == 2) ||
            (selectedPaymentType == 1 && createOrderBloc.paymentType == 1)) {
          return _buildRegularConfirmButton();
        }

        // No button for unselected payment methods
        return const SizedBox();
      },
    );
  }

  Widget _buildApplePayWidget(double calculatedAmount) {
    debugPrint("asddsaasddsasaddsaadsasdadsads: ${ApiKeys.publishApiKey}");

    // Ensure orderId exists before showing Apple Pay button
    final String currentOrderId = generalSingleton.orderId ?? orderIdd ?? "";
    if (currentOrderId.isEmpty) {
      return const SizedBox(height: KSpace.tapTarget, child: _InlineProgress());
    }

    // Always use calculatedAmount which includes all discounts (promo code + points)
    // calculatedAmount already has points discount subtracted in _calculateTotalAmount
    final double amountToCharge = calculatedAmount;

    return SizedBox(
      width: double.infinity,
      child: ApplePay(
        config: PaymentConfig(
          currency: "SAR",
          publishableApiKey: ApiKeys.publishApiKey,
          amount: (amountToCharge * 100).round(), // Convert to cents/halalas
          description: 'Payment for Order #$currentOrderId',
          metadata: {
            "orderId": currentOrderId,
            "userId": sl<GetUserProfileBloc>().profile.sId ?? "",
            "totalAmount": amountToCharge.toString(),
            "createdAt": DateTime.now().toIso8601String(),
            "orderType": "SERVICE_BOOKING",
          },
          applePay: ApplePayConfig(
            saveCard: false,
            merchantId: 'merchant.kleanoDev',
            label: 'KleanO',
            manual: false,
          ),
        ),
        onPaymentResult: _handleApplePayResult,
      ),
    );
  }

  Widget _buildRegularConfirmButton() {
    return KButton(
      label: translate(AppStrings.confirmOrder),
      // A card payment continues in its own sheet, which shows its own progress.
      loading: _isProcessingPayment && createOrderBloc.paymentType != 1,
      onPressed: _isProcessingPayment ? null : _handleConfirmOrder,
    );
  }

  Future<void> _handleApplePayResult(dynamic result) async {
    debugPrint("Apple Pay Result: $result");

    // Prevent multiple processing
    if (_isProcessingPayment) return;

    if (result is UnprocessableTokenError) {
      debugPrint("Apple Pay Error: ${result.message}");
      _showPaymentErrorBottomSheet(
        title: Localizations.localeOf(context).languageCode == 'en'
            ? 'Payment Error'
            : 'خطأ في الدفع',
        message: Localizations.localeOf(context).languageCode == 'en'
            ? 'An error occurred while processing the payment: ${result.message}'
            : 'حدث خطأ في معالجة الدفع: ${result.message}',
        isError: true,
      );
      _resetPaymentState();
      return;
    }

    if (result is PaymentResponse) {
      try {
        setState(() {
          _isProcessingPayment = true;
        });

        applePayId = result.id;

        if (result.status == PaymentStatus.paid) {
          // Payment successful, now place the order with the new order ID
          final currentOrderId = generalSingleton.orderId ?? orderIdd ?? "";
          if (currentOrderId.isNotEmpty) {
            context.read<BookingOrderBloc>().add(
              PlaceOrder(applePayId: applePayId!, orderId: currentOrderId),
            );
          } else {
            _showPaymentErrorBottomSheet(
              title: Localizations.localeOf(context).languageCode == 'en'
                  ? 'Error'
                  : 'خطأ',
              message: Localizations.localeOf(context).languageCode == 'en'
                  ? 'Failed to get order ID. Please try again'
                  : 'فشل في الحصول على معرف الطلب. الرجاء المحاولة مرة أخرى',
              isError: true,
            );
            _resetPaymentState();
          }
        } else {
          _showPaymentErrorBottomSheet(
            title: Localizations.localeOf(context).languageCode == 'en'
                ? 'Payment Failed'
                : 'فشل الدفع',
            message: 'فشلت عملية الدفع: ${result.status}',
            isError: true,
          );
          _resetPaymentState();
        }
      } catch (e) {
        _showPaymentErrorBottomSheet(
          title: Localizations.localeOf(context).languageCode == 'en'
              ? 'Error'
              : 'خطأ',
          message: Localizations.localeOf(context).languageCode == 'en'
              ? 'An error occurred while processing the payment'
              : 'حدث خطأ أثناء معالجة الدفع',
          isError: true,
        );
        _resetPaymentState();
      }
    } else {
      debugPrint("Apple Pay cancelled or failed");
      _resetPaymentState();
    }
  }

  void _showPaymentErrorBottomSheet({
    required String title,
    required String message,
    required bool isError,
  }) {
    showKSheet<void>(
      context: context,
      builder: (context) {
        final KColors c = KColors.of(context);
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: KSpace.s),
              Icon(
                isError ? Icons.error_outline : Icons.info_outline,
                color: isError ? c.error : c.warning,
                size: 48,
              ),
              const SizedBox(height: KSpace.m),
              Text(
                title,
                style: KType.title.copyWith(color: c.text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KSpace.s),
              Text(
                message,
                style: KType.subhead.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KSpace.xl),
              KButton(
                label: isError
                    ? translate(AppStrings.tryAgain)
                    : translate(AppStrings.okButton),
                onPressed: () {
                  Navigator.pop(context);
                  // Retry payment if it was an error, otherwise just close
                  if (isError && createOrderBloc.paymentType == 3) {
                    _prepareApplePayOrder();
                  }
                },
              ),
              const SizedBox(height: KSpace.xs),
              KButton(
                label: translate(AppStrings.cancelButton),
                variant: KButtonVariant.text,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePaymentSelection(PaymentMethodModel type) {
    // Prevent multiple selections while processing
    if (_isProcessingPayment) return;

    // Check if wallet is locked (balance < order price)
    if (type.value == 2) {
      final promoState = context.read<PromoBloc>().state;
      final double totalAmount = _calculateTotalAmount(promoState);
      if ((walletBalance ?? 0) < totalAmount) {
        showSnackBar(
          buildContext: context,
          message:
              '${translate(AppStrings.yourWalletBalanceIsNotValid)}. Required: ${totalAmount.toStringAsFixed(2)}',
        );
        return;
      }
    }

    setState(() {
      createOrderBloc.paymentType = type.value;
      selectedPaymentType = type.value;
    });

    // Each payment method has its own independent logic
    switch (type.value) {
      case 1: // Credit Card
        _handleCreditCardSelection();
        break;
      case 3: // Apple Pay
        _handleApplePaySelection();
        break;
      case 2: // Wallet
        _handleWalletSelection();
        break;
      default:
        // Handle other payment methods
        break;
    }
  }

  // Validate order details before proceeding with payment
  bool _validateOrderDetails() {
    final vehicleBloc = sl<VehiclesBloc>();
    final profileBloc = sl<GetUserProfileBloc>();

    // Check if a vehicle is selected
    if (vehicleBloc.vehiclesList.isEmpty ||
        vehicleBloc.selectedVehicle.sId == null) {
      showSnackBar(buildContext: context, message: 'الرجاء اختيار مركبة');
      return false;
    }

    // Check if at least one service is selected or user has an active subscription
    if (offersBloc.cartServicesList.isEmpty &&
        (profileBloc.profile.isSubscribed != true)) {
      showSnackBar(
        buildContext: context,
        message: 'الرجاء اختيار خدمة واحدة على الأقل',
      );
      return false;
    }

    return true;
  }

  // Create a new order and return success status
  Future<bool> _createOrder({bool forceNewOrder = false}) async {
    // Prevent multiple order creation unless forced (for Apple Pay)
    if (!forceNewOrder &&
        generalSingleton.orderId != null &&
        generalSingleton.orderId!.isNotEmpty) {
      return true; // Order already exists
    }

    final completer = Completer<bool>();
    StreamSubscription? subscription;

    try {
      // Listen for order creation result
      subscription = context.read<BookingOrderBloc>().stream.listen((state) {
        if (!completer.isCompleted) {
          if (state is CreateOrderSuccess) {
            generalSingleton.orderId = state.reviewOrderModel.data!.sId!;
            generalSingleton.totalPay = state.reviewOrderModel.data!.totalPay;
            orderIdd = generalSingleton.orderId;
            completer.complete(true);
          } else if (state is CreateOrderFailed) {
            if (!mounted) {
              completer.complete(false);
              return;
            }
            _showPaymentErrorBottomSheet(
              title: Localizations.localeOf(context).languageCode == 'en'
                  ? 'Error'
                  : 'خطأ',
              message: Localizations.localeOf(context).languageCode == 'en'
                  ? state.errorModel?.en ??
                        'Failed to create the order. Please try again'
                  : state.errorModel?.ar ??
                        'فشل إنشاء الطلب. الرجاء المحاولة مرة أخرى',
              isError: true,
            );
            completer.complete(false);
          }
        }
      });

      // Trigger order creation
      CreateOrderFunction().createOrderDataRequest();

      // Wait for order creation with timeout
      final success = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (!completer.isCompleted) {
            if (!mounted) return false;
            _showPaymentErrorBottomSheet(
              title: Localizations.localeOf(context).languageCode == 'en'
                  ? 'Error'
                  : 'خطأ',
              message: Localizations.localeOf(context).languageCode == 'en'
                  ? 'The order creation timeout has expired. Please try again'
                  : 'انتهت مهلة انتظار إنشاء الطلب. الرجاء المحاولة مرة أخرى',
              isError: true,
            );
            completer.complete(false);
          }
          return false;
        },
      );

      return success;
    } catch (e) {
      if (!completer.isCompleted) {
        if (!mounted) return false;
        _showPaymentErrorBottomSheet(
          title: Localizations.localeOf(context).languageCode == 'en'
              ? 'Error'
              : 'خطأ',
          message: Localizations.localeOf(context).languageCode == 'en'
              ? 'An error occurred while creating the order. Please try again'
              : 'حدث خطأ أثناء إنشاء الطلب. الرجاء المحاولة مرة أخرى',
          isError: true,
        );
        completer.complete(false);
      }
      return false;
    } finally {
      await subscription?.cancel();
    }
  }

  // Apple Pay Selection Handler - Independent Logic
  void _handleApplePaySelection() {
    // Apple Pay creates its own order when selected
    _prepareApplePayOrder();
  }

  // Credit Card Selection Handler - Independent Logic
  void _handleCreditCardSelection() {
    // Credit Card shows payment form immediately
    _showCreditCardBottomSheet();
  }

  // Wallet Selection Handler - Independent Logic
  void _handleWalletSelection() {
    // Wallet payment type is set, no additional action needed on selection
    // Payment will be processed when confirm button is clicked
  }

  // Prepare Apple Pay order - Always create new order for Apple Pay
  Future<void> _prepareApplePayOrder() async {
    // Clear existing order ID to force creation of new order
    generalSingleton.orderId = null;
    orderIdd = null;

    // Always create a new order for Apple Pay
    final success = await _createOrder(forceNewOrder: true);
    if (!success) {
      _resetPaymentState();
    } else {
      if (mounted) setState(() {});
    }
  }

  // Process Wallet payment
  Future<void> _processWalletPayment() async {
    try {
      // Clear existing order ID to force creation of new order
      generalSingleton.orderId = null;
      orderIdd = null;

      // Always create a new order for wallet payment
      final success = await _createOrder(forceNewOrder: true);
      if (!success) {
        _resetPaymentState();
        return;
      }

      // Place order with wallet payment (no payment details needed)
      // The server will process wallet payment based on the payment type set during order creation
      if (!mounted) return;
      context.read<BookingOrderBloc>().add(
        PlaceOrder(orderId: generalSingleton.orderId!),
      );
    } catch (e) {
      if (!mounted) return;
      _showPaymentErrorBottomSheet(
        title: Localizations.localeOf(context).languageCode == 'en'
            ? 'Error'
            : 'خطأ',
        message: Localizations.localeOf(context).languageCode == 'en'
            ? 'Failed to process wallet payment. Please try again'
            : 'فشلت عملية الدفع من المحفظة. الرجاء المحاولة مرة أخرى',
        isError: true,
      );
      _resetPaymentState();
    }
  }

  // Process Apple Pay payment
  Future<void> _processApplePay() async {
    try {
      // Show loading indicator
      setState(() => _isProcessingPayment = true);

      // The actual Apple Pay widget will handle the payment UI
      // The result will be handled in _handleApplePayResult
    } catch (e) {
      _showPaymentErrorBottomSheet(
        title: Localizations.localeOf(context).languageCode == 'en'
            ? 'Error'
            : 'خطأ',
        message: Localizations.localeOf(context).languageCode == 'en'
            ? 'Failed to start payment process. Please try again'
            : 'فشل بدء عملية الدفع. الرجاء المحاولة مرة أخرى',
        isError: true,
      );
      _resetPaymentState();
    }
  }

  // // Process default payment method
  // Future<void> _processDefaultPayment() async {
  //   try {
  //     final success = await _createOrder();
  //     if (success) {
  //       // If order was created successfully, proceed with default payment flow
  //       context.read<BookingOrderBloc>().add(
  //             PlaceOrder(
  //               orderId: generalSingleton.orderId!,
  //             ),
  //           );
  //     }
  //   } catch (e) {
  //     _showPaymentErrorBottomSheet(
  //       title: 'خطأ',
  //       message: 'حدث خطأ أثناء معالجة الدفع. الرجاء المحاولة مرة أخرى',
  //       isError: true,
  //     );
  //     _resetPaymentState();
  //   }
  // }

  // Reset payment state
  void _resetPaymentState() {
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Future<void> _handleConfirmOrder() async {
    if (_isProcessingPayment) return;

    final paymentType = createOrderBloc.paymentType;
    final promoState = context.read<PromoBloc>().state;
    final double totalAmount = _calculateTotalAmount(promoState);

    // Validate required fields before proceeding
    debugPrint("sadashbsajb: $paymentType");
    if (!_validateOrderDetails()) {
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      if (totalAmount <= 0) {
        generalSingleton.orderId = null;
        orderIdd = null;
        final success = await _createOrder(forceNewOrder: true);

        if (success) {
          if (mounted) {
            setState(() {
              _isProcessingPayment = false;
            });
          }
          if (!mounted) return;
          AlertHelper.createOrderSuccess(context);
        } else {
          _resetPaymentState();
        }
        return;
      }

      // Each payment method has its own independent logic
      switch (paymentType) {
        case 1: // Credit Card
          _showCreditCardBottomSheet();
          break;
        case 2: // Wallet
          await _processWalletPayment();
          break;
        case 3: // Apple Pay
          await _processApplePay();
          break;
        default:
          // Default behavior - create order if needed
          if (generalSingleton.orderId == null ||
              generalSingleton.orderId!.isEmpty) {
            final success = await _createOrder();
            if (!success) {
              _resetPaymentState();
              return;
            }
          }
      }
    } catch (e) {
      if (!mounted) return;
      _showPaymentErrorBottomSheet(
        title: Localizations.localeOf(context).languageCode == 'en'
            ? 'Error'
            : 'خطأ',
        message: Localizations.localeOf(context).languageCode == 'en'
            ? 'An error occurred while processing your request. Please try again.'
            : 'حدث خطأ أثناء معالجة الطلب. الرجاء المحاولة مرة أخرى.',
        isError: true,
      );
      _resetPaymentState();
    }
  }

  void _showCreditCardBottomSheet() {
    showKSheet<void>(
      context: context,
      builder: (context) => _CreditCardPaymentBottomSheet(
        orderId: generalSingleton.orderId ?? "N/A",
      ),
    );
  }

  void _onOrderSuccess(BuildContext context, {String? transactionUrl}) async {
    // Prevent multiple webview openings
    if (_isProcessingPayment) {
      setState(() {
        _isProcessingPayment = false;
      });
    }

    // Don't clear cart data here - only clear when returning to main nav
    // context.read<BookingOrderBloc>().add(ClearCartOrder());
    // sl<PromoBloc>().totalPayModel = TotalPayModel();
    debugPrint("📝 Order success - cart data preserved for main nav clearing");

    if (transactionUrl != null && transactionUrl.isNotEmpty) {
      // Check if we're already in a webview to prevent multiple openings
      if (Navigator.canPop(context)) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebview(
              transactionUrl: transactionUrl,
              onPaymentComplete: (status) {
                if (status == 'Payment success') {
                  Navigator.pop(context, true);
                  AlertHelper.createOrderSuccess(context);
                } else {
                  _showPaymentErrorBottomSheet(
                    title: Localizations.localeOf(context).languageCode == 'en'
                        ? 'Payment Failed'
                        : 'فشل الدفع',
                    message:
                        Localizations.localeOf(context).languageCode == 'en'
                        ? 'Payment could not be processed. Please try again.'
                        : 'فشلت عملية الدفع. الرجاء المحاولة مرة أخرى.',
                    isError: true,
                  );
                }
              },
            ),
          ),
        );
      } else {
        // If we can't pop, show success directly
        AlertHelper.createOrderSuccess(context);
      }
    } else {
      // No transaction URL, payment was successful without webview
      AlertHelper.createOrderSuccess(context);
    }
  }
}

const double _vehiclePhotoSize = 64;
const double _mapHeight = 150;

/// A group on the order screen: an optional heading and action above [child].
class _Section extends StatelessWidget {
  const _Section({this.title, this.action, required this.child});

  final String? title;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null || action != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: KSpace.xs,
                bottom: KSpace.s,
              ),
              // Wraps instead of overflowing at large text sizes.
              child: Wrap(
                alignment: title == null
                    ? WrapAlignment.end
                    : WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: KSpace.s,
                runSpacing: KSpace.xs,
                children: <Widget>[
                  if (title != null)
                    Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: KType.headline.copyWith(
                          color: KColors.of(context).text,
                        ),
                      ),
                    ),
                  ?action,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// An amount with the riyal symbol, sized to match the text.
class _Amount extends StatelessWidget {
  const _Amount(this.amount, {required this.style, required this.color});

  final String amount;
  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // LTR so Arabic keeps the minus sign in front of the digits.
        Text(
          amount,
          textDirection: TextDirection.ltr,
          style: style.copyWith(color: color),
        ),
        const SizedBox(width: KSpace.xs),
        SvgPicture.asset(
          AssetsManager.saudiRiyalSymbol,
          height: style.fontSize,
          width: style.fontSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ],
    );
  }
}

/// One line of a price breakdown.
class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.emphasized = false,
  });

  final String label;
  final String amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final TextStyle style = emphasized ? KType.headline : KType.subhead;
    return Padding(
      padding: const EdgeInsets.only(top: KSpace.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: style.copyWith(
                color: emphasized ? c.text : c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: KSpace.s),
          _Amount(amount, style: style, color: c.text),
        ],
      ),
    );
  }
}

/// A small platform spinner with an optional message, for a wait inside a card.
class _InlineProgress extends StatelessWidget {
  const _InlineProgress({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox.square(
          dimension: KSpace.xl,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        if (message != null) ...<Widget>[
          const SizedBox(width: KSpace.m),
          Flexible(
            child: Text(
              message!,
              style: KType.subhead.copyWith(
                color: KColors.of(context).textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CreditCardPaymentBottomSheet extends StatefulWidget {
  final String orderId;

  const _CreditCardPaymentBottomSheet({required this.orderId});
  @override
  State<_CreditCardPaymentBottomSheet> createState() =>
      _CreditCardPaymentBottomSheetState();
}

class _CreditCardPaymentBottomSheetState
    extends State<_CreditCardPaymentBottomSheet> {
  late final GlobalKey<FormState> _cardFormKey;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _setupControllers() {
    _cardFormKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    final cleanNumber = value.replaceAll(' ', '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Invalid card number';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Format: MM/YY';
    }
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month';
    }
    if (year == null) {
      return 'Invalid year';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'Invalid CVV';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cardholder name is required';
    }
    return null;
  }

  void _submitPayment({required String orderId}) async {
    if (_isLoading) return; // Prevent multiple submissions

    if (_cardFormKey.currentState?.validate() == true) {
      setState(() => _isLoading = true);

      final bloc = sl<OffersBloc>();
      final expiryParts = _expiryController.text.split('/');

      bloc.cardNumber = _numberController.text.replaceAll(' ', '');
      bloc.expiryMonth = expiryParts[0].trim();
      bloc.cardCvv = _cvvController.text;
      bloc.cardHolderName = _nameController.text;
      bloc.expiryYear = '20${expiryParts[1].trim()}';

      debugPrint("🚀 Starting Credit Card payment process...");

      // Credit Card: Create new order, wait, then process payment
      _createNewOrderForCreditCard();
    } else {
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'en'
            ? "Please complete all fields correctly"
            : "يرجى إكمال جميع الحقول بشكل صحيح",
      );
    }
  }

  // Validate order data before creation
  bool _validateOrderDataForCreation() {
    try {
      final vehicleBloc = sl<VehiclesBloc>();
      final offersBloc = sl<OffersBloc>();
      final userProfileBloc = sl<GetUserProfileBloc>();

      // Check location data (blcoPosition is non-nullable, so just verify coordinates are valid)
      if (blcoPosition.latitude == 0 || blcoPosition.longitude == 0) {
        debugPrint("❌ Location data is missing");
        showSnackBar(
          buildContext: context,
          message: "بيانات الموقع غير مكتملة. الرجاء المحاولة مرة أخرى",
        );
        return false;
      }

      // Check vehicle data
      if (vehicleBloc.selectedVehicle.sId == null ||
          vehicleBloc.selectedVehicle.sId!.isEmpty) {
        debugPrint("❌ Vehicle data is missing");
        debugPrint(
          "🔍 Vehicle details: ${vehicleBloc.selectedVehicle.toString()}",
        );
        debugPrint(
          "🔍 Vehicles list length: ${vehicleBloc.vehiclesList.length}",
        );

        // Try to get the first vehicle if none is selected
        if (vehicleBloc.vehiclesList.isNotEmpty) {
          debugPrint("🔄 Attempting to use first available vehicle");
          vehicleBloc.selectedVehicle = vehicleBloc.vehiclesList.first;
          debugPrint("✅ Using vehicle: ${vehicleBloc.selectedVehicle.sId}");
        } else {
          showSnackBar(
            buildContext: context,
            message: "لا توجد مركبات متاحة. الرجاء إضافة مركبة أولاً",
          );
          return false;
        }
      }

      // Check services or subscription
      if (offersBloc.cartServicesList.isEmpty &&
          userProfileBloc.profile.isSubscribed != true) {
        debugPrint("❌ No services selected and no active subscription");
        showSnackBar(
          buildContext: context,
          message: "الرجاء اختيار خدمة واحدة على الأقل",
        );
        return false;
      }

      // Final check to ensure vehicle is still valid
      if (vehicleBloc.selectedVehicle.sId == null ||
          vehicleBloc.selectedVehicle.sId!.isEmpty) {
        debugPrint("❌ Vehicle validation failed after auto-selection");
        showSnackBar(
          buildContext: context,
          message: "فشل في تحديد المركبة. الرجاء المحاولة مرة أخرى",
        );
        return false;
      }

      debugPrint("✅ Order data validation passed");
      debugPrint("🚗 Final vehicle ID: ${vehicleBloc.selectedVehicle.sId}");
      return true;
    } catch (e) {
      debugPrint("❌ Error validating order data: $e");
      showSnackBar(
        buildContext: context,
        message: "حدث خطأ في التحقق من بيانات الطلب. الرجاء المحاولة مرة أخرى",
      );
      return false;
    }
  }

  // Create new order specifically for Credit Card payment
  void _createNewOrderForCreditCard() async {
    try {
      // Clear existing order ID to force creation of new order
      GeneralSingleton().orderId = null;
      orderIdd = null;

      debugPrint("🔄 Creating new order for Credit Card payment...");

      // Validate required data before creating order
      if (!_validateOrderDataForCreation()) {
        _resetCreditCardState();
        // Pop the credit card bottom sheet
        Navigator.pop(context);
        return;
      }

      // Double-check vehicle availability right before creating order
      final vehicleBloc = sl<VehiclesBloc>();
      if (vehicleBloc.selectedVehicle.sId == null ||
          vehicleBloc.selectedVehicle.sId!.isEmpty) {
        debugPrint(
          "❌ Vehicle lost before order creation - attempting recovery",
        );
        if (vehicleBloc.vehiclesList.isNotEmpty) {
          vehicleBloc.selectedVehicle = vehicleBloc.vehiclesList.first;
          debugPrint(
            "🔄 Vehicle recovered: ${vehicleBloc.selectedVehicle.sId}",
          );
        } else {
          debugPrint("❌ No vehicles available for recovery");
          _resetCreditCardState();
          // Pop the credit card bottom sheet
          Navigator.pop(context);
          showSnackBar(
            buildContext: context,
            message: "لا توجد مركبات متاحة. الرجاء إضافة مركبة أولاً",
          );
          return;
        }
      }

      // Create new order for Credit Card
      CreateOrderFunction().createOrderDataRequest();

      // Wait for order creation and listen for the result
      debugPrint("⏳ Waiting for order creation...");

      // Listen for order creation result
      final completer = Completer<String?>();
      String? errorMessageEn;
      String? errorMessageAr;
      StreamSubscription? subscription;

      subscription = context.read<BookingOrderBloc>().stream.listen((state) {
        if (!completer.isCompleted) {
          if (state is CreateOrderSuccess) {
            // Safe null checking
            if (state.reviewOrderModel.data?.sId != null) {
              final newOrderId = state.reviewOrderModel.data!.sId!;
              GeneralSingleton().orderId = newOrderId;
              orderIdd = newOrderId;
              debugPrint("📝 Order ID assigned: $newOrderId");
              completer.complete(newOrderId);
            } else {
              debugPrint("❌ Order created but no ID received");
              completer.complete(null);
            }
          } else if (state is CreateOrderFailed) {
            errorMessageEn = state.errorModel?.en ?? state.error;
            errorMessageAr = state.errorModel?.ar ?? state.error;
            debugPrint("❌ Order creation failed: $errorMessageAr");
            completer.complete(null);
          }
        }
      });

      // Wait for order creation with timeout
      final orderId = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return null;
        },
      );

      await subscription.cancel();

      // Check if order was created successfully
      if (orderId != null && orderId.isNotEmpty) {
        debugPrint("✅ Order created successfully: $orderId");
        // Then process payment
        _processCreditCardPayment();
      } else {
        debugPrint("❌ Failed to create order");
        setState(() => _isLoading = false);
        // Pop the credit card bottom sheet
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showSnackBar(
          buildContext: context,
          message: Localizations.localeOf(context).languageCode == 'en'
              ? errorMessageEn ?? "Failed to create order. Please try again"
              : errorMessageAr ??
                    "فشل في إنشاء الطلب. الرجاء المحاولة مرة أخرى",
        );
      }
    } catch (e) {
      debugPrint("❌ Error in _createNewOrderForCreditCard: $e");
      setState(() => _isLoading = false);
      // Pop the credit card bottom sheet
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      showSnackBar(
        buildContext: context,
        message: "حدث خطأ أثناء إنشاء الطلب. الرجاء المحاولة مرة أخرى",
      );
    }
  }

  void _processCreditCardPayment() async {
    try {
      // Enhanced null checking
      if (orderIdd == null || orderIdd!.isEmpty) {
        debugPrint("❌ No valid order ID available for payment");
        _resetCreditCardState();
        // Pop the credit card bottom sheet
        Navigator.pop(context);
        showSnackBar(
          buildContext: context,
          message: "فشل في الحصول على معرف الطلب. الرجاء المحاولة مرة أخرى",
        );
        return;
      }

      // Additional safety check
      if (GeneralSingleton().orderId == null ||
          GeneralSingleton().orderId!.isEmpty) {
        debugPrint("❌ GeneralSingleton order ID is null");
        _resetCreditCardState();
        // Pop the credit card bottom sheet
        Navigator.pop(context);
        showSnackBar(
          buildContext: context,
          message: "فشل في الحصول على معرف الطلب. الرجاء المحاولة مرة أخرى",
        );
        return;
      }

      debugPrint("💳 Processing Credit Card payment for order: $orderIdd");

      // Listen for place order result
      final completer = Completer<String?>();
      StreamSubscription? subscription;

      subscription = context.read<BookingOrderBloc>().stream.listen((state) {
        if (!completer.isCompleted) {
          if (state is PlaceOrderSuccess) {
            // Safe null checking for payment URL
            if (state.paymentUrl != null && state.paymentUrl!.isNotEmpty) {
              debugPrint(
                "✅ Place order successful, payment URL: ${state.paymentUrl}",
              );
              completer.complete(state.paymentUrl);
            } else {
              debugPrint(
                "❌ Place order successful but no payment URL received",
              );
              completer.complete(null);
            }
          } else if (state is PlaceOrderFailed) {
            debugPrint(
              "❌ Place order failed: ${state.errormodel?.ar ?? state.error}",
            );
            completer.complete(null);
          }
        }
      });

      // Place the order with payment details
      final offersBloc = sl<OffersBloc>();

      // Payment details should already be validated in the form
      debugPrint("💳 Payment details validated, proceeding with place order");

      context.read<BookingOrderBloc>().add(
        PlaceOrder(
          orderId: orderIdd!,
          paymentDetailsRequest: PaymentDetailsRequest(
            name: offersBloc.cardHolderName,
            number: offersBloc.cardNumber,
            cvc: offersBloc.cardCvv,
            month: offersBloc.expiryMonth,
            year: offersBloc.expiryYear,
          ),
        ),
      );

      // Wait for place order result
      final paymentUrl = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return null;
        },
      );

      await subscription.cancel();

      // Handle the result
      if (paymentUrl != null && paymentUrl != "free" && paymentUrl.isNotEmpty) {
        debugPrint("🌐 Opening webview with URL: $paymentUrl");
        // Close the bottom sheet before opening webview
        if (!mounted) return;
        Navigator.pop(context);
        _openPaymentWebview(paymentUrl);
      } else if (paymentUrl == "free") {
        if (!mounted) return;
        AlertHelper.createOrderSuccess(context);
      } else {
        debugPrint("❌ No payment URL received");
        _resetCreditCardState();

        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showSnackBar(
          buildContext: context,
          message: "فشل في الحصول على رابط الدفع. الرجاء المحاولة مرة أخرى",
        );
      }
    } catch (e) {
      debugPrint("❌ Error in _processCreditCardPayment: $e");
      _resetCreditCardState();
      // Pop the credit card bottom sheet
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      showSnackBar(
        buildContext: context,
        message: "حدث خطأ أثناء معالجة الدفع. الرجاء المحاولة مرة أخرى",
      );
    }
  }

  // Open payment webview for Credit Card
  void _openPaymentWebview(String paymentUrl) async {
    try {
      debugPrint("🌐 Opening payment webview...");

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebview(
            transactionUrl: paymentUrl,
            onPaymentComplete: (status) {
              if (status == 'Payment success') {
                debugPrint("✅ Payment completed successfully");
                Navigator.pop(context, true);
                AlertHelper.createOrderSuccess(context);
              } else {
                debugPrint("❌ Payment failed: $status");
                showSnackBar(
                  buildContext: context,
                  message: translate('paymentFailed'),
                );
              }
            },
          ),
        ),
      );

      // Reset state after webview closes (whether successful or cancelled)
      _resetCreditCardState();
    } catch (e) {
      debugPrint("❌ Error opening webview: $e");
      _resetCreditCardState();
      if (!mounted) return;
      showSnackBar(
        buildContext: context,
        message: translate('somethingWentWrong'),
      );
    }
  }

  // Reset Credit Card state to allow new order creation (without clearing data)
  void _resetCreditCardState() {
    setState(() => _isLoading = false);

    // Clear order IDs to allow new order creation
    GeneralSingleton().orderId = null;
    orderIdd = null;

    // Don't clear cart data - only reset loading state and order IDs
    // Cart data will be cleared only when returning to main navigation bar
    debugPrint("🔄 Credit Card state reset - ready for new order creation");
    debugPrint(
      "📝 Order IDs cleared: GeneralSingleton().orderId = null, orderIdd = null",
    );
    debugPrint(
      "📝 Cart data preserved - will be cleared only when returning to main nav",
    );
  }

  String _formatCardNumber(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'\D'), '');

    // Limit to 16 digits
    if (value.length > 16) {
      value = value.substring(0, 16);
    }

    // Add space every 4 digits
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  String _formatExpiryDate(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'\D'), '');

    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2, value.length > 4 ? 4 : value.length)}';
    }
    return value;
  }

  /// KTextField has no onChanged, so the field formats itself as a formatter.
  TextInputFormatter _reformatWith(String Function(String) format) {
    return TextInputFormatter.withFunction((_, TextEditingValue value) {
      final String formatted = format(value.text);
      if (formatted == value.text) return value;
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Form(
          key: _cardFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Title
              Row(
                children: <Widget>[
                  Icon(Icons.credit_card, color: c.brand),
                  const SizedBox(width: KSpace.m),
                  Expanded(
                    child: Text(
                      translate(AppStrings.enterCardDetails).trim(),
                      style: KType.headline.copyWith(color: c.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KSpace.l),

              // Card Number
              CardField(
                label: translate(AppStrings.cardNumber),
                hint: '1234 5678 9012 3456',
                prefix: Icon(Icons.credit_card, color: c.textSecondary),
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  _reformatWith(_formatCardNumber),
                ],
                validator: _validateCardNumber,
              ),
              const SizedBox(height: KSpace.m),

              // Cardholder Name
              CardField(
                label: translate(AppStrings.cardholderName),
                hint: 'Cardholder Name',
                prefix: Icon(Icons.person, color: c.textSecondary),
                controller: _nameController,
                inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                validator: _validateName,
              ),
              const SizedBox(height: KSpace.m),

              // Expiry and CVV Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: CardField(
                      label: translate(AppStrings.cardExpiryDate),
                      hint: 'MM/YY',
                      prefix: Icon(
                        Icons.calendar_month,
                        color: c.textSecondary,
                      ),
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        _reformatWith(_formatExpiryDate),
                      ],
                      validator: _validateExpiryDate,
                    ),
                  ),
                  const SizedBox(width: KSpace.m),
                  Expanded(
                    child: CardField(
                      label: translate(AppStrings.cvv),
                      hint: '123',
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscure: true,
                      validator: _validateCVV,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KSpace.xxl),

              // Payment Button
              KButton(
                label: translate(AppStrings.payNow),
                loading: _isLoading,
                onPressed: _isLoading
                    ? null
                    : () {
                        debugPrint("sadsadsassdadsdas ${widget.orderId}");
                        _submitPayment(orderId: widget.orderId);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
