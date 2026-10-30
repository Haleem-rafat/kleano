import 'package:flutter/material.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_card.dart';

class MyBookingList extends StatelessWidget {
  final List<OrderModel> orderList;
  final bool? isActive;

  const MyBookingList({
    super.key,
    this.isActive = true,
    required this.orderList,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orderList.length,
      itemBuilder: (_, index) {
        return Column(
          children: <Widget>[
            GestureDetector(
              child: MyBookingCard(
                order: orderList[index],
                isActive: isActive!,
              ),
            ),
          ],
        );
      },
    );
  }
}
