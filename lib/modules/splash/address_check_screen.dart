import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/screens/home_screen.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

/// Decides where a signed-in user lands: Home with a saved address, the map
/// to add a first one, or a retry when the check itself failed. A failed check
/// must not look like "no address": that sends existing users to the map.
class AddressCheckScreen extends StatefulWidget {
  const AddressCheckScreen({super.key});

  @override
  State<AddressCheckScreen> createState() => _AddressCheckScreenState();
}

class _AddressCheckScreenState extends State<AddressCheckScreen> {
  bool _hasNavigated = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    sl<LocationBloc>().add(GetSavedLocation());
  }

  void _retry() {
    setState(() => _failed = false);
    sl<LocationBloc>().add(GetSavedLocation());
  }

  void _openMap() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    popALlAndPushPage(context, const HomeScreen(isFromSignUp: true));
  }

  void _openHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    popALlAndPushPage(context, const MainNavigationScreen(selectedIndex: 0));
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return BlocListener<LocationBloc, LocationState>(
      listener: (BuildContext context, LocationState state) {
        if (state is GetSavedLocationFailed) {
          setState(() => _failed = true);
        } else if (state is GetSavedLocationSuccess) {
          state.savedLocation.isEmpty ? _openMap() : _openHome();
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: _failed ? _buildFailed() : _buildChecking(c),
      ),
    );
  }

  Widget _buildFailed() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          KErrorState(
            message: translate(AppStrings.failedToLoadLocations),
            onRetry: _retry,
          ),
          // Keeps a user with no way past the check from being stuck here.
          KButton(
            label: translate(AppStrings.addAddress),
            variant: KButtonVariant.text,
            expand: false,
            onPressed: _openMap,
          ),
        ],
      ),
    );
  }

  Widget _buildChecking(KColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.location_on_rounded, size: 56, color: c.brand),
            const KLoadingState(),
            Text(
              translate(AppStrings.checkingYourAddress),
              textAlign: TextAlign.center,
              style: KType.title.copyWith(color: c.text),
            ),
            const SizedBox(height: KSpace.xs),
            Text(
              translate(AppStrings.verifyingSavedLocation),
              textAlign: TextAlign.center,
              style: KType.subhead.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
