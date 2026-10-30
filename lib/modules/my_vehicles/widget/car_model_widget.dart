import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/widget/edit_car_title.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/search_text_field.dart';

class CarModelWidget extends StatefulWidget {
  final TextEditingController carModelController;

  const CarModelWidget({super.key, required this.carModelController});

  @override
  State<CarModelWidget> createState() => _CarModelWidgetState();
}

class _CarModelWidgetState extends State<CarModelWidget> {
  late String selectedCarModel;
  List<String> carModels = [];

  @override
  void initState() {
    super.initState();
    selectedCarModel = widget.carModelController.text;
  }

  String getLocalizedModel(String model) {
    final parts = model.split('//');
    if (parts.length != 2) return model;
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'ar' ? parts[1] : parts[0];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarsBloc, CarsState>(
      listener: (context, carState) {
        if (carState is GetCarModelByBrandIdSuccess) {
          debugPrint("object");
          carModels = carState.carModels
              .map((model) => getLocalizedModel(model))
              .toList();
          setState(() {});
        }
      },
      builder: (context, carState) {
        final bool notEmptyCar = selectedCarModel.isNotEmpty;
        if (carState is GetCarModelByBrandIdloading) {
          return const LoadingWidget();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.verticalSpace,
            editCarTitle(AppStrings.carModel),
            AppPadding.p8.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorManager.divider),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: DropdownSearchShared(
                  hintText: notEmptyCar
                      ? getLocalizedModel(selectedCarModel)
                      : translate("hint2"),
                  onChanged: (value) {
                    setState(() {
                      widget.carModelController.text = value;
                      selectedCarModel = value;
                    });
                  },
                  items: carModels,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
