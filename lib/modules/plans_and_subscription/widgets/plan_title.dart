
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:thewasher/core/resources/app_styles.dart';
// import 'package:thewasher/core/resources/assets_manager.dart';
// import 'package:thewasher/core/resources/color_manager.dart';

// class PlanType extends StatefulWidget {
//   final String colorPlan;
//   final String type;
//   // final VoidCallback onTap;
//   const PlanType({
//     super.key,
//     required this.colorPlan,
//     required this.type,
//     // required this.onTap,
//     });

//   @override
//   State<PlanType> createState() => _PlanTypeState();
// }

// class _PlanTypeState extends State<PlanType> with SingleTickerProviderStateMixin{
//    bool showInfoPlan = true;
//    late AnimationController _controller;
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//       upperBound: 0.5,
//     );
//   }
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//   void _showInfo(){
//     setState(() {
//        showInfoPlan =! showInfoPlan;
//      if (_controller.isDismissed) {
//            _controller.forward();
//          } else {
//            _controller.reverse();
//          }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   SizedBox(
//                     height: 80.h,
//                     width: 80.w,
//                     child: Stack(
//                       children: [SvgPicture.asset(
//                         ImageAssets.planColor,
//                         fit: BoxFit.cover,
//                         color: Color(int.parse("0xFF${widget.colorPlan}")),
//                         ),
//                       ]
//                     ),
//                   ),
//                   Text(
//                      widget.type,
//                      style: AppStyles.title16Bold.copyWith(
//                        color: Color(int.parse("0xFF${widget.colorPlan}")),
//                      ),
//                    ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 13.w, right: 13.w),
//                     child: RotationTransition(
//                           turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.arrow_forward_ios,
//                                size: 15,
//                                color: ColorManager.darkGrey,
//                               ),
//                             onPressed: _showInfo,
//                           ),
//                         ),
//                   )
//                 ],
//               );
//   }
// }