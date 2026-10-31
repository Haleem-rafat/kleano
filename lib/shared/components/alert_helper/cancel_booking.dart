import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/utilties/navigator.dart';

class CancelBooking extends StatefulWidget {
  final String orderId;
  final bool? comeFromWashDetails;
  const CancelBooking({
    super.key,
    required this.orderId,
    this.comeFromWashDetails = false,
  });

  @override
  State<CancelBooking> createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking> {
  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(AssetsManager.cancelBooking),
      title: translate(AppStrings.areYouSureCancelOrder),
      message: translate(AppStrings.onceYourOrderIsCancelled),
      actions: <Widget>[
        BlocConsumer<BookingOrderBloc, BookingOrderState>(
          listener: (BuildContext context, BookingOrderState state) {
            if (state is CancelOrderSuccess) {
              if (widget.comeFromWashDetails == true) {
                pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return _buildSuccessDialog(context);
                  },
                );
              } else {
                popALlAndPushPage(
                  context,
                  MainNavigationScreen(selectedIndex: 0),
                );
              }
            } else if (state is CancelOrderFailed) {
              pop(context);
              _showErrorDialog(context);
            }
          },
          builder: (BuildContext context, BookingOrderState state) {
            final bool loading = state is CancelOrderLoading;
            return KButton(
              label: loading
                  ? (Localizations.localeOf(context).languageCode == 'en'
                        ? 'Cancelling order...'
                        : 'جاري إلغاء الطلب...')
                  : translate(AppStrings.cancelOrder),
              variant: KButtonVariant.destructive,
              loading: loading,
              onPressed: () {
                context.read<BookingOrderBloc>().add(
                  CancelOrder(orderId: widget.orderId),
                );
              },
            );
          },
        ),
        KButton(
          label: translate(AppStrings.back),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return KDialog(
      icon: Icon(
        Icons.check_circle_rounded,
        size: 48,
        color: KColors.of(context).success,
      ),
      title: isEnglish
          ? 'Order Cancelled Successfully!'
          : 'تم إلغاء الطلب بنجاح!',
      message: isEnglish
          ? 'The order is cancelled and we will refund your money'
          : 'تم إلغاء الطلب وسنقوم بإعادة المال',
      actions: <Widget>[
        KButton(
          label: isEnglish ? 'OK' : 'حسناً',
          onPressed: () {
            pop(context);
            if (widget.comeFromWashDetails == true) {
              pop(context); // Close the wash details screen too
            }
          },
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context) {
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return KDialog(
          icon: Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: KColors.of(context).error,
          ),
          title: isEnglish ? 'Failed to Cancel Order' : 'فشل إلغاء الطلب',
          message: isEnglish
              ? 'Something went wrong while cancelling your order. Please try again or contact support.'
              : 'حدث خطأ أثناء إلغاء طلبك. يرجى المحاولة مرة أخرى أو الاتصال بالدعم.',
          actions: <Widget>[
            KButton(
              label: isEnglish ? 'Try Again' : 'حاول مرة أخرى',
              onPressed: () => pop(context),
            ),
          ],
        );
      },
    );
  }
}
