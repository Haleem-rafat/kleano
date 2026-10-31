import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/whatsapp_number.dart';
import 'package:url_launcher/url_launcher.dart';

/// The open order's car, status, customer, contact buttons and street.
class OrderUserDetails extends StatelessWidget {
  const OrderUserDetails({super.key});
  void openWhatsApp(String phoneBiker) async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/${whatsAppNumber(phoneBiker)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final order = sl<HomeBloc>().orderDetails;
    final String? phone = order.user?.phone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${order.vehicle?.brand} ${order.vehicle?.model}',
                style: KType.headline.copyWith(color: c.text),
              ),
            ),
            if (order.status != null) ...<Widget>[
              const SizedBox(width: KSpace.s),
              KStatusChip(
                label: orderStateName(order.status!),
                status: orderChipStatus(order.status),
              ),
            ],
          ],
        ),
        const SizedBox(height: KSpace.m),
        OrderCarRow(order: order, showName: false),
        const SizedBox(height: KSpace.s),
        Row(
          children: <Widget>[
            Expanded(child: OrderCustomerRow(order: order)),
            if (phone != null) ...<Widget>[
              const SizedBox(width: KSpace.s),
              OrderIconAction(
                label: tr(context, AppStrings.phoneNumber),
                onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                child: Icon(
                  Icons.call_rounded,
                  size: KSpace.xxl,
                  color: c.brand,
                ),
              ),
              const SizedBox(width: KSpace.s),
              OrderIconAction(
                label: 'WhatsApp',
                onTap: () => openWhatsApp(phone),
                child: SvgPicture.asset(
                  'assets/svg/whatsapp_icon.svg',
                  width: KSpace.xxl,
                  height: KSpace.xxl,
                  colorFilter: ColorFilter.mode(c.success, BlendMode.srcIn),
                ),
              ),
            ],
          ],
        ),
        if (order.location?.streetName != null) ...<Widget>[
          const SizedBox(height: KSpace.xs),
          OrderLocationRow(order: order),
        ],
      ],
    );
  }
}
