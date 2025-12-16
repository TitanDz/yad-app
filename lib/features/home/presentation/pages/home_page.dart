import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/availability_bloc.dart';
import 'package:yad_app/features/home/presentation/widgets/index.dart';
import 'package:yad_app/features/home/presentation/pages/minyan_page.dart';
import 'package:yad_app/features/home/presentation/pages/notifications_home_page.dart';
import 'package:yad_app/features/home/presentation/bloc/notification_bloc.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';
import 'package:yad_app/core/services/user_preferences_manager.dart';
import 'package:yad_app/features/home/presentation/pages/prayers_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late MinyanBloc _minyanBloc;
  late HomeBloc _homeBloc;
  late AvailabilityBloc _availabilityBloc;
  List<Map<String, dynamic>> _autocompleteResults = [];
  bool _isLoadingAutocomplete = false;
  Timer? _autocompleteDebounceTimer;
  final String _userId = 'user_123'; // Placeholder - should get from auth
  bool _refreshTriggered = false; // Flag to prevent duplicate refresh triggers
  late PrayerCountdownService _prayerCountdownService;
  List<PrayerTimeInfo> _prayerTimes = [];
  String _cityCountry = '';
  bool _prayerTimesLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initialize MinyanBloc once and reuse it
    _minyanBloc = getIt<MinyanBloc>();
    // Initialize HomeBloc once and reuse it
    _homeBloc = getIt<HomeBloc>();
    // Initialize AvailabilityBloc
    _availabilityBloc = getIt<AvailabilityBloc>();
    // Initialize PrayerCountdownService
    _prayerCountdownService = getIt<PrayerCountdownService>();
    
    // Add initialization event to HomeBloc only once
    _homeBloc.add(const InitializeMapEvent());
    // Initialize availability tracking
    _availabilityBloc.add(InitializeAvailabilityEvent(userId: _userId));
    
    // Reset refresh flag when the page comes back into focus
    _refreshTriggered = false;
    
    // Initialize prayer times with default location
    _initializePrayerTimes();
    
    // Get user location and city/country
    _getUserLocationAndCity();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    _autocompleteDebounceTimer?.cancel();
    _prayerCountdownService.dispose();
    // Don't dispose _minyanBloc here as it's managed by service locator
    super.dispose();
  }

  void _onSearchChanged() {
    // Removed - using Google Places API autocomplete instead
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _autocompleteResults = [];
    });
    context.read<HomeBloc>().add(const ClearSearchEvent());
  }

  /// Initialize prayer times with current location
  void _initializePrayerTimes() {
    try {
      // Default location (will be updated when user location is obtained)
      const double defaultLat = 40.7128; // NYC
      const double defaultLon = -74.0060;
      final timeZone = UserPreferencesManager.detectTimeZone();
      
      _prayerCountdownService.initialize(
        latitude: defaultLat,
        longitude: defaultLon,
        timeZone: timeZone,
      );
      
      _prayerCountdownService.addListener((prayerTimes) {
        if (mounted) {
          setState(() {
            _prayerTimes = prayerTimes;
            _prayerTimesLoading = false;
          });
        }
      });
      
      // Get initial prayer times
      setState(() {
        _prayerTimes = _prayerCountdownService.getPrayerTimes();
        _prayerTimesLoading = _prayerTimes.isEmpty;
      });
    } catch (e) {
      debugPrint('[HomePage] Error initializing prayer times: $e');
      setState(() => _prayerTimesLoading = false);
    }
  }

  /// Get user location and reverse geocode to city/country
  Future<void> _getUserLocationAndCity() async {
    try {
      final homeBloc = context.read<HomeBloc>();
      final state = homeBloc.state;
      
      if (state is HomeMapReady && state.userLocation != null) {
        final location = state.userLocation!;
        
        // Reinitialize prayer times with actual location
        final timeZone = UserPreferencesManager.detectTimeZone();
        _prayerCountdownService.dispose();
        _prayerCountdownService.initialize(
          latitude: location.latitude,
          longitude: location.longitude,
          timeZone: timeZone,
        );
        
        // Reverse geocode to get city and country
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final city = placemark.locality ?? placemark.administrativeArea ?? '';
            final country = placemark.country ?? '';
            final cityCountry = [city, country].where((s) => s.isNotEmpty).join(', ');
            
            if (mounted) {
              setState(() {
                _cityCountry = cityCountry;
              });
            }
          }
        } catch (e) {
          debugPrint('[HomePage] Error reverse geocoding: $e');
        }
      }
    } catch (e) {
      debugPrint('[HomePage] Error getting user location: $e');
    }
  }

  Future<void> _fetchAutocompleteResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
      });
      return;
    }

    const apiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';
    const sessionToken = 'session_token';

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&components=country:us'
          '&key=$apiKey'
          '&sessiontoken=$sessionToken';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final status = json['status'] as String?;

        if (status == 'OK') {
          final predictions = json['predictions'] as List<dynamic>? ?? [];
          final results = <Map<String, dynamic>>[];

          for (var i = 0; i < predictions.length && i < 5; i++) {
            final prediction = predictions[i] as Map<String, dynamic>;
            final placeId = prediction['place_id'] as String?;
            final structuredFormatting = prediction['structured_formatting'] as Map<String, dynamic>?;
            final mainText = structuredFormatting?['main_text'] as String?;
            final secondaryText = structuredFormatting?['secondary_text'] as String?;

            if (placeId != null && mainText != null) {
              results.add({
                'name': mainText,
                'address': secondaryText ?? '',
                'placeId': placeId,
              });
            }
          }

          if (mounted) {
            setState(() {
              _autocompleteResults = results;
              _isLoadingAutocomplete = false;
            });
          }
        } else if (status == 'ZERO_RESULTS') {
          if (mounted) {
            setState(() {
              _autocompleteResults = [];
              _isLoadingAutocomplete = false;
            });
          }
        } else {
          debugPrint('API Error: ${json['error_message'] ?? status}');
          if (mounted) {
            setState(() => _isLoadingAutocomplete = false);
          }
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        if (mounted) {
          setState(() => _isLoadingAutocomplete = false);
        }
      }
    } on TimeoutException {
      debugPrint('API request timeout');
      if (mounted) {
        setState(() => _isLoadingAutocomplete = false);
      }
    } catch (e) {
      debugPrint('Error fetching autocomplete: $e');
      if (mounted) {
        setState(() => _isLoadingAutocomplete = false);
      }
    }
  }

  Future<void> _selectAutocompleteResult(String placeId, String name) async {
    const apiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = json['result'] as Map<String, dynamic>?;

        if (result != null) {
          final geometry = result['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;

          if (location != null && _mapController != null) {
            final lat = location['lat'] as double;
            final lng = location['lng'] as double;

            // Animate camera to selected location
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 17.0,
                ),
              ),
            );

            // Clear search
            _searchController.clear();
            setState(() {
              _autocompleteResults = [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error selecting autocomplete result: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Widget _buildNotificationBellIcon(int tabIndex) {
    final isSelected = _selectedIndex == tabIndex;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFC9DDFC) : Colors.transparent,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Icon(
              Icons.notifications,
              color: AppTheme.divinity,
              size: 24,
            ),
            // Red dot badge for unread notifications
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(String assetPath, int tabIndex) {
    final isSelected = _selectedIndex == tabIndex;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFC9DDFC) : Colors.transparent,
      ),
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            AppTheme.divinity,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTabIcon(int tabIndex) {
    final isSelected = _selectedIndex == tabIndex;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFC9DDFC) : Colors.transparent,
      ),
      child: Center(
        child: Icon(
          Icons.schedule,
          color: AppTheme.divinity,
          size: 24,
        ),
      ),
    );
  }

  String _getDarkMapStyle() {
    return '''[
        {
          "elementType": "geometry",
          "stylers": [{"color": "#1a1815"}]
        },
        {
          "elementType": "labels.text",
          "stylers": [{"color": "#ffffff"}]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [{"color": "#1a1815"}]
        },
        {
          "featureType": "administrative",
          "elementType": "geometry.stroke",
          "stylers": [{"color": "#3a3530"}]
        },
        {
          "featureType": "administrative.land_parcel",
          "elementType": "labels.text",
          "stylers": [{"color": "#bdbdbd"}]
        },
        {
          "featureType": "poi",
          "elementType": "geometry",
          "stylers": [{"color": "#2a2520"}]
        },
        {
          "featureType": "poi",
          "elementType": "labels.text",
          "stylers": [{"color": "#d59563"}]
        },
        {
          "featureType": "poi.park",
          "elementType": "geometry",
          "stylers": [{"color": "#263c3f"}]
        },
        {
          "featureType": "poi.park",
          "elementType": "labels.text",
          "stylers": [{"color": "#6b9080"}]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [{"color": "#38414e"}]
        },
        {
          "featureType": "road",
          "elementType": "geometry.stroke",
          "stylers": [{"color": "#212a37"}]
        },
        {
          "featureType": "road",
          "elementType": "labels.text",
          "stylers": [{"color": "#9ca5b3"}]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry",
          "stylers": [{"color": "#746855"}]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry.stroke",
          "stylers": [{"color": "#1f2835"}]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels.text",
          "stylers": [{"color": "#f3751ff"}]
        },
        {
          "featureType": "transit",
          "elementType": "geometry",
          "stylers": [{"color": "#2f3948"}]
        },
        {
          "featureType": "transit.station",
          "elementType": "labels.text",
          "stylers": [{"color": "#d59563"}]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [{"color": "#17263c"}]
        },
        {
          "featureType": "water",
          "elementType": "labels.text",
          "stylers": [{"color": "#515c6d"}]
        }
      ]''';
  }

  /// Show minyan summary sheet with all details
  void _showMinyanSummarySheet(Minyan minyan) {
    final bloc = context.read<HomeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MinyanSummarySheet(minyan: minyan),
    ).then((_) {
      // Clear the selected minyan when sheet is closed
      // This ensures tapping the same marker again will trigger the listener
      bloc.add(const ClearSelectedMinyanEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(context),
      bottomNavigationBar: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.divinity,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: 24,
            items: [
              BottomNavigationBarItem(
                icon: _buildBottomNavIcon('assets/images/Navbar/home.svg', 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildBottomNavIcon('assets/images/Navbar/calendar.svg', 1),
                label: 'Minyans',
              ),
              BottomNavigationBarItem(
                icon: _buildPrayerTabIcon(2),
                label: 'Prayers',
              ),
              BottomNavigationBarItem(
                icon: _buildNotificationBellIcon(3),
                label: 'Notifications',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? QuickActionFAB(
              isAvailable: _availabilityBloc.state is AvailabilityLoaded &&
                  !(_availabilityBloc.state as AvailabilityLoaded).status.isCurrentlyUnavailable,
              onCreateMinyan: () {
                context.push('/create-minyan');
              },
              onSearch: () {
                // Focus on search bar
                _searchFocusNode.requestFocus();
              },
              onToggleAvailability: () {
                // Handled by availability bloc in the toggle widget
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPageContent(BuildContext context) {
    if (_selectedIndex == 0) {
      // Map view - optimized for maximum map visibility
      return Column(
        children: [
          // Enhanced app header bar (Avatar, Title, Settings) - improved for visibility and safe area
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side: Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      // Center: Next Prayer Info (Enhanced for readability, constrained width)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: _prayerTimes.isNotEmpty
                                    ? 'Next: ${_prayerTimes[0].name}'
                                    : 'Prayer Times',
                                child: Text(
                                  _prayerTimes.isNotEmpty
                                      ? _prayerTimes[0].name
                                      : 'Prayer Times',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_prayerTimes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    _prayerTimes[0].displayStartTime,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Right side: Settings Button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            context.push('/settings');
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Settings',
                        ),
                      ),
                    ],
                  ),
                  // Availability Toggle - enhanced spacing
                  const SizedBox(height: 12),
                  BlocProvider<AvailabilityBloc>.value(
                    value: _availabilityBloc,
                    child: AvailabilityToggleWidget(
                      userId: _userId,
                      onAvailabilityChanged: () {
                        // Trigger any additional updates needed
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Map area - expanded to use remaining space (no prayer panel above it)
          Expanded(
            child: Stack(
              children: [
                // Full screen map
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    debugPrint('[HomePage.BlocBuilder] Rebuilding with state type: ${state.runtimeType}');
                    if (state is HomeLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    if (state is HomeMapReady) {
                      debugPrint('[HomePage.BlocBuilder] HomeMapReady state - markers count: ${state.markers.length}, minyans count: ${state.minyans.length}');
                      final userLocation = state.userLocation;
                      final initialPosition = userLocation != null
                          ? LatLng(userLocation.latitude, userLocation.longitude)
                          : const LatLng(40.7128, -74.0060);

                      return Stack(
                        children: [
                          GoogleMap(
                            key: ValueKey('map_${state.markers.length}_${state.polylines.length}'),  // Force rebuild when markers or polylines change
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: initialPosition,
                              zoom: 15.0,
                            ),
                            markers: state.markers,
                            polylines: state.polylines,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            style: Theme.of(context).brightness == Brightness.dark
                                ? _getDarkMapStyle()
                                : null,
                          ),
                          // Remove gradient overlay (was shadowing prayer panel)
                        ],
                      );
                    }

                    if (state is HomeError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),

                // BlocListener to automatically refresh when map is ready
                BlocListener<HomeBloc, HomeState>(
                  listener: (context, state) {
                    if (state is HomeMapReady && !_refreshTriggered) {
                      debugPrint('\n🎯 [BlocListener] Map became ready! Triggering auto-refresh to load nearby minyans...');
                      _refreshTriggered = true;
                      _homeBloc.add(const RefreshNearbyMiniyansEvent());
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
                
                // BlocListener to show minyan details sheet when marker is tapped
                BlocListener<HomeBloc, HomeState>(
                  listenWhen: (previous, current) {
                    // Listen when selectedMinyan changes (and is not null)
                    if (previous is HomeMapReady && current is HomeMapReady) {
                      return previous.selectedMinyan != current.selectedMinyan && current.selectedMinyan != null;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    if (state is HomeMapReady && state.selectedMinyan != null) {
                      // Show the minyan summary sheet
                      _showMinyanSummarySheet(state.selectedMinyan!);
                    }
                  },
                  child: const SizedBox.shrink(),
                ),

                // Floating Search Bar (overlaying map)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchLocationBar(
                        controller: _searchController,
                        onSearch: (query) {
                          // Cancel previous timer
                          _autocompleteDebounceTimer?.cancel();

                          if (query.isEmpty) {
                            setState(() {
                              _autocompleteResults = [];
                              _isLoadingAutocomplete = false;
                            });
                            return;
                          }

                          // Show loading state immediately
                          if (!_isLoadingAutocomplete) {
                            setState(() => _isLoadingAutocomplete = true);
                          }

                          // Debounce API call by 300ms
                          _autocompleteDebounceTimer = Timer(
                            const Duration(milliseconds: 300),
                            () => _fetchAutocompleteResults(query),
                          );
                        },
                        onClear: _onClearSearch,
                      ),
                      // Autocomplete dropdown with loading state
                      if (_isLoadingAutocomplete)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: SizedBox(
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (_autocompleteResults.isEmpty && _searchController.text.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No locations found',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_autocompleteResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _autocompleteResults.length,
                            itemBuilder: (context, index) {
                              final result = _autocompleteResults[index];
                              return InkWell(
                                onTap: () => _selectAutocompleteResult(
                                  result['placeId'] as String,
                                  result['name'] as String,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: index < _autocompleteResults.length - 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result['name'] as String,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            if ((result['address'] as String).isNotEmpty)
                                              Text(
                                                result['address'] as String,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Map controls (Zoom + Current Location)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom In button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              _mapController?.animateCamera(
                                CameraUpdate.zoomBy(1),
                              );
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Zoom Out button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              _mapController?.animateCamera(
                                CameraUpdate.zoomBy(-1),
                              );
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Current Location button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              // Get current location from BLoC state
                              final state = context.read<HomeBloc>().state;
                              if (state is HomeMapReady && state.userLocation != null) {
                                _mapController?.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        state.userLocation!.latitude,
                                        state.userLocation!.longitude,
                                      ),
                                      zoom: 15.0,
                                    ),
                                  ),
                                );
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Map controls (Zoom + Current Location)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom In button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              _mapController?.animateCamera(
                                CameraUpdate.zoomBy(1),
                              );
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Zoom Out button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              _mapController?.animateCamera(
                                CameraUpdate.zoomBy(-1),
                              );
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Current Location button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              // Get current location from BLoC state
                              final state = context.read<HomeBloc>().state;
                              if (state is HomeMapReady && state.userLocation != null) {
                                _mapController?.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        state.userLocation!.latitude,
                                        state.userLocation!.longitude,
                                      ),
                                      zoom: 15.0,
                                    ),
                                  ),
                                );
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      // Minyans view
      return BlocProvider<MinyanBloc>.value(
        value: _minyanBloc,
        child: const MinyanPage(),
      );
    } else if (_selectedIndex == 2) {
      // Prayers view - dedicated prayer times tab
      return PrayersPage(
        prayerTimes: _prayerTimes,
        cityCountry: _cityCountry,
        isLoading: _prayerTimesLoading,
      );
    } else if (_selectedIndex == 3) {
      // Notifications view
      return BlocProvider<NotificationBloc>(
        create: (context) => NotificationBloc(),
        child: const NotificationsHomePage(),
      );
    }

    return const SizedBox();
  }
}
