
// void showActionSheet(BuildContext context) {
//     showCupertinoModalPopup<void>(
//       context: context,
//       builder: (BuildContext context) => CupertinoActionSheet(
//         title: Text(
//           'Choose your picture',
//           style: AppStyles.title16Bold,
//           ),
//         actions: <CupertinoActionSheetAction>[
//           CupertinoActionSheetAction(
//             onPressed: () {
//               Navigator.pop(context);
//               getGalleryIMage();
//             },
//             child:  Text(
//               'Choose from gallery',
//               style: AppStyles.title16Regular.copyWith(color: ColorManager.primary),
//               ),
//           ),
//           CupertinoActionSheetAction(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text(
//               'Take a photo',
//               style: AppStyles.title16Regular.copyWith(color: ColorManager.primary),
//               ),
//           ),
//         ],
//       ),
//     );
//   }
