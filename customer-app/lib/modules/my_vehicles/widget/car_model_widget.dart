import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_picker_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';

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
          carModels = carState.carModels
              .map((model) => getLocalizedModel(model))
              .toList();
          setState(() {});
        }
      },
      builder: (context, carState) {
        final bool notEmptyCar = selectedCarModel.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(top: KSpace.l),
          child: KPickerField<String>(
            label: translate(AppStrings.carModel),
            placeholder: translate("hint2"),
            items: carModels,
            itemLabel: (String m) => m,
            value: notEmptyCar ? getLocalizedModel(selectedCarModel) : null,
            loading: carState is GetCarModelByBrandIdloading,
            onSelected: (String value) {
              setState(() {
                widget.carModelController.text = value;
                selectedCarModel = value;
              });
            },
          ),
        );
      },
    );
  }
}
