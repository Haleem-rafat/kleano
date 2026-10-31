import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/whatsapp_number.dart';
import 'package:url_launcher/url_launcher.dart';

/// An active order: status, car, customer and street, with one primary action
/// and large call and WhatsApp targets next to it.
class AcceptContainer extends StatelessWidget {
  final OrderModel acceptOrder;
  final int index;
  const AcceptContainer({
    super.key,
    required this.acceptOrder,
    required this.index,
  });

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) {
      return;
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/${whatsAppNumber(phone)}');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  String? _timeLine(BuildContext context) {
    final String label = tr(context, AppStrings.washTime);
    if (acceptOrder.isAssigned == true) {
      final List<WashingServices>? services = acceptOrder.washingServices;
      if (services == null || services.isEmpty) return null;
      return '$label ${services.first.duration}';
    }
    final DateTime? start = acceptOrder.startTime;
    if (start == null) return null;
    return '$label ${AppDateFormatter.allDate(start)} '
        '${AppDateFormatter.dateToStringHHMMA(start)}';
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String? time = _timeLine(context);
    final String? car = acceptOrder.vehicle == null
        ? null
        : '${acceptOrder.vehicle!.brand} ${acceptOrder.vehicle!.model}';
    return KCard(
      onTap: () {
        pushPage(
          context,
          OrderDetailsScreen(data: acceptOrder, complete: true),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Wrap(
            spacing: KSpace.s,
            runSpacing: KSpace.xs,
            children: <Widget>[
              KStatusChip(
                label: orderStateName(acceptOrder.status ?? ''),
                status: orderChipStatus(acceptOrder.status),
              ),
              if (acceptOrder.isAssigned == true)
                KStatusChip(
                  label: tr(context, AppStrings.adminRequest),
                  status: KStatus.brand,
                ),
            ],
          ),
          if (car != null) ...<Widget>[
            const SizedBox(height: KSpace.m),
            OrderCarRow(order: acceptOrder),
          ],
          if (time != null) ...<Widget>[
            const SizedBox(height: KSpace.xs),
            Text(time, style: KType.footnote.copyWith(color: c.textSecondary)),
          ],
          const SizedBox(height: KSpace.m),
          OrderCustomerRow(order: acceptOrder),
          const SizedBox(height: KSpace.xs),
          OrderLocationRow(order: acceptOrder),
          const SizedBox(height: KSpace.m),
          Row(
            children: <Widget>[
              Expanded(
                child: KButton(
                  label: tr(context, AppStrings.washProgress),
                  onPressed: () {
                    Navigator.of(context).push(
                      createRoute(
                        OrderChangeStatus(
                          order: acceptOrder,
                          index: index,
                          notification: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: KSpace.s),
              OrderIconAction(
                label: tr(context, AppStrings.phoneNumber),
                onTap: () {
                  launchUrl(Uri(scheme: 'tel', path: acceptOrder.user?.phone));
                },
                child: SvgPicture.asset(
                  ImageAssets.phoneLogo,
                  width: OrderIconAction.size,
                  height: OrderIconAction.size,
                ),
              ),
              const SizedBox(width: KSpace.s),
              OrderIconAction(
                label: 'WhatsApp',
                onTap: () => _openWhatsApp(acceptOrder.user?.phone),
                child: SvgPicture.asset(
                  'assets/svg/whatsapp_icon.svg',
                  width: KSpace.xxl,
                  height: KSpace.xxl,
                  colorFilter: ColorFilter.mode(c.success, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
