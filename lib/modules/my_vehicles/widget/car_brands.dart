import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_picker_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/car_model.dart';
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
          return Padding(
            padding: const EdgeInsets.only(top: KSpace.l),
            child: KPickerField<CarBrandsModel>(
              label: translate(AppStrings.carBrand),
              placeholder: translate("hint1"),
              items: const <CarBrandsModel>[],
              itemLabel: (CarBrandsModel b) => b.name,
              onSelected: onSelectBrand,
              loading: true,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: KSpace.l),
          child: KPickerField<CarBrandsModel>(
            label: translate(AppStrings.carBrand),
            placeholder: translate("hint1"),
            items: carBrands,
            itemLabel: (CarBrandsModel b) => b.name,
            value: notEmptyCarBrand ? selectBrandName : null,
            onSelected: onSelectBrand,
          ),
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
      context
          .read<CarsBloc>()
          .add(GetCarModelByBrandId(brandId: selectBrandId!));
    }
  }
}
