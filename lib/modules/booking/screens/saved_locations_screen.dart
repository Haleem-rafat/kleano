import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/modules/Home/screens/home_screen.dart';
import 'package:thewasher/modules/booking/widgets/location/saved_location_row.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(GetSavedLocation());
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      // The list scrolls under the floating glass button.
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.savedPlaces)),
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (BuildContext context, LocationState state) {
          if (state is DeleteLocationByIdSuccess) {
            // Refresh the saved locations after successful deletion
            context.read<LocationBloc>().add(GetSavedLocation());
            showSnackBar(
              buildContext: context,
              message: translate('locationDeletedSuccessfully'),
              icon: Icons.check_circle_outline,
              backgroundColor: c.success,
            );
          } else if (state is DeleteLocationByIdFailed) {
            showSnackBar(
              buildContext: context,
              message: '${translate('failedToDeleteLocation')}: ${state.error}',
              icon: Icons.error_outline,
              backgroundColor: c.error,
            );
          }
        },
        builder: (BuildContext context, LocationState state) {
          if (state is LocationInitial ||
              state is GetSavedLocationLoading ||
              state is SetDefaultLocationLoading) {
            return const KSkeleton.list();
          }
          if (state is GetSavedLocationFailed ||
              state is SetDefaultLocationFailed) {
            return KErrorState(
              message: state is GetSavedLocationFailed
                  ? translate(AppStrings.failedToGetSavedLocations)
                  : translate(AppStrings.failedToSetDefaultLocation),
              onRetry: () =>
                  context.read<LocationBloc>().add(GetSavedLocation()),
            );
          }
          final List<AddressModel> locations = context
              .read<LocationBloc>()
              .savedLocation;
          if (locations.isEmpty) {
            return KEmptyState(
              icon: Icons.location_on_outlined,
              title: translate(AppStrings.savedPlaces),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(
              KSpace.xl,
              KSpace.l,
              KSpace.xl,
              MediaQuery.viewPaddingOf(context).bottom + 96,
            ),
            children: <Widget>[
              KCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < locations.length; i++) ...<Widget>[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: SavedLocationRow.dividerIndent,
                          color: c.separator,
                        ),
                      _buildRow(c, locations[i]),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          KSpace.xl,
          KSpace.s,
          KSpace.xl,
          KSpace.l,
        ),
        child: KButton(
          label: translate(AppStrings.addAddress),
          onPressed: () => pushPage(context, const HomeScreen()),
        ),
      ),
    );
  }

  Widget _buildRow(KColors c, AddressModel location) {
    final bool isDefault = location.isDefault == true;
    return SavedLocationRow(
      location: location,
      onTap: () {
        context.read<LocationBloc>().add(
          SetDefaultLocation(locationId: location.sId!),
        );
      },
      // The default address can't be deleted, so it has no delete button.
      trailing: isDefault
          ? KStatusChip(
              label: translate(AppStrings.defaultLabel),
              status: KStatus.brand,
            )
          : IconButton(
              tooltip: translate('delete'),
              icon: Icon(Icons.delete_outline, color: c.error),
              onPressed: () => _showDeleteLocationDialog(location),
            ),
    );
  }

  void _showDeleteLocationDialog(AddressModel location) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return KDialog(
          title: translate('deleteLocation'),
          message: translate(
            'areYouSureDeleteLocation',
            args: <String, dynamic>{
              'locationName': SavedLocationRow.title(location),
            },
          ),
          actions: <Widget>[
            KButton(
              label: translate('delete'),
              variant: KButtonVariant.destructive,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<LocationBloc>().add(
                  DeleteLocationById(locationId: location.sId!),
                );
              },
            ),
            KButton(
              label: translate('cancel'),
              variant: KButtonVariant.text,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}
