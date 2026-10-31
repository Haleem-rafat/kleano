import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/app_config.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_search_field.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class SearchMapScreen extends StatefulWidget {
  final Function showMap;
  final bool? showOptions;
  final String? currentAddress;
  final String? administrativeArea;
  final String? country;
  final dynamic currentPosition;
  final void Function() handlePressButton;

  const SearchMapScreen({
    super.key,
    required this.showMap,
    this.showOptions = false,
    this.currentAddress,
    this.administrativeArea,
    this.country,
    this.currentPosition,
    required this.handlePressButton,
  });

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  late bool showOptions;

  Timer? _debounce;

  final String googleApiKey = AppConfig.googlePlacecApi;

  @override
  void initState() {
    super.initState();
    showOptions = widget.showOptions ?? false;
    debugPrint('Platform: ${Platform.isAndroid ? "Android" : "iOS"}');

    // Load user country from preferences
    _loadUserCountry();

    // Temporary: Force Egypt for testing Alexandria search
    // TODO: Remove this after testing
    _forceCountryForTesting('Egypt');
  }

  // Temporary method for testing - remove after fixing the issue
  void _forceCountryForTesting(String country) {
    _userCountryName = country;
    _userCountry = _getCountryCode(country);
    debugPrint(
        'FORCED COUNTRY FOR TESTING: $_userCountryName -> $_userCountry');
  }

  String _userCountry = 'sa'; // Default to Saudi Arabia
  String _userCountryName = 'Saudi Arabia';
  bool _countryLoaded = false;

  Future<void> _loadUserCountry() async {
    await AppShared.getCountry();
    debugPrint('Stored country from AppShared: "${AppShared.country}"');
    debugPrint('Widget country: "${widget.country}"');

    if (AppShared.country.isNotEmpty) {
      _userCountryName = AppShared.country;
      _userCountry = _getCountryCode(AppShared.country);
      debugPrint('Using stored country: $_userCountryName -> $_userCountry');
    } else if (widget.country != null && widget.country!.isNotEmpty) {
      _userCountryName = widget.country!;
      _userCountry = _getCountryCode(widget.country!);
      // Update shared preferences with the country from widget
      await AppShared.setCountry(widget.country!);
      debugPrint('Using widget country: $_userCountryName -> $_userCountry');
    } else {
      debugPrint('No country found, using default: Saudi Arabia');
    }
    _countryLoaded = true;
    debugPrint('Final country: $_userCountryName (code: $_userCountry)');
  }

  String _getCountryCode(String countryName) {
    // Map country names to ISO country codes for Google Places API
    final countryMap = {
      'Saudi Arabia': 'sa',
      'saudi arabia': 'sa',
      'saudi': 'sa',
      'ksa': 'sa',
      'United Arab Emirates': 'ae',
      'united arab emirates': 'ae',
      'UAE': 'ae',
      'uae': 'ae',
      'emirates': 'ae',
      'Kuwait': 'kw',
      'kuwait': 'kw',
      'Qatar': 'qa',
      'qatar': 'qa',
      'Bahrain': 'bh',
      'bahrain': 'bh',
      'Oman': 'om',
      'oman': 'om',
      'Jordan': 'jo',
      'jordan': 'jo',
      'Lebanon': 'lb',
      'lebanon': 'lb',
      'Egypt': 'eg',
      'egypt': 'eg',
      'مصر': 'eg',
      'Turkey': 'tr',
      'turkey': 'tr',
      'türkiye': 'tr',
    };

    final normalizedName = countryName.toLowerCase().trim();
    debugPrint('Looking up country code for: "$normalizedName"');
    final result = countryMap[normalizedName] ?? 'sa';
    debugPrint('Country code result: $result');
    return result;
  }

  // void _testApiKey() async {
  //   try {
  //     final testUrl =
  //         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=cairo&key=$googleApiKey&language=ar';
  //     debugPrint('Testing API with URL: $testUrl');

  //     final response = await http.get(Uri.parse(testUrl));
  //     debugPrint('Test response status: ${response.statusCode}');
  //     debugPrint('Test response body: ${response.body}');
  //   } catch (e) {
  //     debugPrint('API test error: $e');
  //   }
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _selectSuggestion(dynamic suggestion) async {
    final Map<String, dynamic> details = await fetchPlaceDetails(
      suggestion['place_id'],
      googleApiKey,
    );
    if (!mounted) return;
    if (details['geometry']?['location']?['lat'] != null &&
        details['geometry']?['location']?['lng'] != null) {
      Navigator.pop(context, details);
    } else {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.cannotLocateAddress),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GlassBackButton(onPressed: () => Navigator.of(context).pop()),
          titleSpacing: KSpace.s,
          title: Padding(
            padding: const EdgeInsetsDirectional.only(end: KSpace.l),
            child: KSearchField(
              controller: _searchController,
              hint: translate(AppStrings.searchLocation),
              autofocus: true,
              onChanged: onSearchChanged,
            ),
          ),
        ),
        body: _buildBody(c),
      ),
    );
  }

  Widget _buildBody(KColors c) {
    if (_isLoading) {
      return const KLoadingState();
    }
    if (_suggestions.isEmpty) {
      return _searchController.text.isNotEmpty
          ? KEmptyState(
              icon: Icons.search_off_rounded,
              title: translate(AppStrings.noSearchResults),
            )
          : const SizedBox.shrink();
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.l,
        KSpace.xl,
        MediaQuery.viewPaddingOf(context).bottom + KSpace.xxl,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: <Widget>[
        KCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < _suggestions.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: KSpace.l + 24 + KSpace.m,
                    color: c.separator,
                  ),
                _buildSuggestion(c, _suggestions[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestion(KColors c, dynamic suggestion) {
    final dynamic formatted = suggestion['structured_formatting'];
    return KListRow(
      leading: SvgPicture.asset(
        AssetsManager.locationIconLogo,
        colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
      ),
      title: formatted?['main_text'] ?? suggestion['description'] ?? '',
      subtitle: formatted?['secondary_text'],
      onTap: () => _selectSuggestion(suggestion),
    );
  }

  Future<List<dynamic>> searchPlaces(String input, String apiKey) async {
    try {
      // Get country-specific coordinates for biasing
      final countryCoords = _getCountryCoordinates(_userCountry);

      // Try with user's country first
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&key=$apiKey'
          '&language=ar'
          '&components=country:$_userCountry'
          '&location=${countryCoords['lat']},${countryCoords['lng']}'
          '&radius=500000';

      debugPrint(
          'Searching for "$input" in country: $_userCountryName ($_userCountry)');

      var response = await http.get(Uri.parse(url));

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Status: ${data['status']}');

        if (data['status'] == 'OK' && data['predictions'] != null) {
          final predictions = data['predictions'] as List<dynamic>;
          debugPrint(
              'Found ${predictions.length} predictions in $_userCountryName');
          return predictions;
        } else if (data['status'] == 'ZERO_RESULTS') {
          debugPrint(
              'Zero results from API for $_userCountryName, trying without country restriction');
          // Try without country restriction as fallback
          url =
              'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey&language=ar';
          response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data2 = json.decode(response.body);
            debugPrint('Fallback API Status: ${data2['status']}');
            if (data2['status'] == 'OK' && data2['predictions'] != null) {
              debugPrint(
                  'Found ${data2['predictions'].length} results in global search');
              return data2['predictions'] as List<dynamic>;
            }
          }
          debugPrint('No results found even in global search');
          return [];
        } else if (data['status'] == 'REQUEST_DENIED') {
          debugPrint('Request denied, trying without region restriction');
          // Try without region restriction
          url =
              'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey&language=ar';
          response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data2 = json.decode(response.body);
            debugPrint('Fallback API Status: ${data2['status']}');
            if (data2['status'] == 'OK' && data2['predictions'] != null) {
              return data2['predictions'] as List<dynamic>;
            }
          }
          return [];
        } else {
          debugPrint('API Error: ${data['status']} - ${data['error_message']}');
          return [];
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception in searchPlaces: $e');
      return [];
    }
  }

  Map<String, double> _getCountryCoordinates(String countryCode) {
    // Country center coordinates for biasing search results
    final coords = {
      'sa': {'lat': 23.8859, 'lng': 45.0792}, // Saudi Arabia
      'ae': {'lat': 23.4241, 'lng': 53.8478}, // UAE
      'kw': {'lat': 29.3117, 'lng': 47.4818}, // Kuwait
      'qa': {'lat': 25.3548, 'lng': 51.1839}, // Qatar
      'bh': {'lat': 25.9304, 'lng': 50.6378}, // Bahrain
      'om': {'lat': 21.4735, 'lng': 55.9754}, // Oman
      'jo': {'lat': 30.5852, 'lng': 36.2384}, // Jordan
      'lb': {'lat': 33.8547, 'lng': 35.8623}, // Lebanon
      'eg': {'lat': 26.0975, 'lng': 30.0444}, // Egypt
      'tr': {'lat': 38.9637, 'lng': 35.2433}, // Turkey
    };

    return coords[countryCode] ?? coords['sa']!; // Default to Saudi Arabia
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(
      String placeId, String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&language=ar';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result'];
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    debugPrint('Searching for: "$value"');
    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      try {
        final results = await searchPlaces(value.trim(), googleApiKey);
        debugPrint('Search results: ${results.length} items');
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Search error: $e');
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isLoading = false;
          });
        }
      }
    });
  }
}
