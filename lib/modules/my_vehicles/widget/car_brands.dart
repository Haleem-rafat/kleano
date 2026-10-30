import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/car_model.dart';
import 'package:thewasher/modules/my_vehicles/widget/edit_car_title.dart';
import 'package:thewasher/shared/components/search_text_field.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class CardBrandsWidget extends StatefulWidget {
  final TextEditingController carBrandController;
  const CardBrandsWidget({super.key, required this.carBrandController});

  @override
  State<CardBrandsWidget> createState() => _CardBrandsWidgetState();
}

class _CardBrandsWidgetState extends State<CardBrandsWidget> {
  String? selectBrandName;
  String? selectBrandId;
  List<CarBrandsModel> carBrands = [];
  CarBrandsModel? foundSelectedCarBrand;

  @override
  void initState() {
    super.initState();
    selectBrandName = widget.carBrandController.text;
  }

  String getLocalizedBrand(String brand) {
    final parts = brand.split('//');
    if (parts.length != 2) return brand;
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'ar' ? parts[1] : parts[0];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarsBloc, CarsState>(
      listener: (BuildContext context, CarsState state) {
        if (state is GetCarBrandsError) {
          showSnackBar(
            buildContext: context,
            message: state.error!,
          );
        } else if (state is GetCarBrandsSuccess) {
          // Apply localization to brand names
          carBrands = state.carBrands.map((brand) {
            return CarBrandsModel(
              id: brand.id,
              name: getLocalizedBrand(brand.name),
            );
          }).toList();

          selectBrandName = widget.carBrandController.text;

          bool carBrandExists =
              carBrands.any((element) => element.name == selectBrandName);

          if (carBrandExists) {
            foundSelectedCarBrand = carBrands
                .firstWhere((element) => element.name == selectBrandName);
          }
        }
      },
      builder: (context, state) {
        final bool notEmptyCarBrand =
            (selectBrandName != "" && carBrands.isNotEmpty);

        if (state is GetCarBrandsLoading) {
          return Center(
            child: SizedBox(
              height: 30.h,
              width: 30.w,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            editCarTitle(AppStrings.carBrand),
            AppPadding.p8.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorManager.divider),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: DropdownSearchShared(
                  hintText: translate("hint1"),
                  items: carBrands,
                  initItem: notEmptyCarBrand ? foundSelectedCarBrand : null,
                  onChanged: (value) {
                    if (value != null) {
                      onSelectBrand(value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onSelectBrand(CarBrandsModel value) {
    setState(() {
      selectBrandId = value.id;
      selectBrandName = value.name;
      widget.carBrandController.text = value.name;
    });
    if (selectBrandId != null) {
      debugPrint("sasndjiasnji");
      context
          .read<CarsBloc>()
          .add(GetCarModelByBrandId(brandId: selectBrandId!));
    }
  }
}
