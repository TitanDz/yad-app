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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
    // Add initialization event to HomeBloc only once
    _homeBloc.add(const InitializeMapEvent());
    // Initialize availability tracking
    _availabilityBloc.add(InitializeAvailabilityEvent(userId: _userId));
    
    // Reset refresh flag when the page comes back into focus
    // This ensures auto-refresh works when returning from create minyan
    _refreshTriggered = false;
    
    // BlocListener in build() will handle auto-refresh when map is ready
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    _autocompleteDebounceTimer?.cancel();
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

  /// Handle marker tap to show detailed information
  void _handleMarkerTap(MarkerId markerId, HomeMapReady state) {
    final markerIdValue = markerId.value;
    if (markerIdValue.startsWith('synagogue_')) {
      final synagogueId = markerIdValue.replaceFirst('synagogue_', '');
      context.read<HomeBloc>().add(SelectMarkerEvent(synagogueId, isMinyan: false));
      _showPrayerLocationDetailsSheet(state, synagogueId, false);
    } else if (markerIdValue.startsWith('minyan_')) {
      final minyanId = markerIdValue.replaceFirst('minyan_', '');
      context.read<HomeBloc>().add(SelectMarkerEvent(minyanId, isMinyan: true));
      _showPrayerLocationDetailsSheet(state, minyanId, true);
    }
  }

  /// Show detailed information sheet for prayer location
  void _showPrayerLocationDetailsSheet(
    HomeMapReady state,
    String locationId,
    bool isMinyan,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) {
          if (isMinyan && state.selectedMinyan != null) {
            return _buildMinyanDetailsSheet(state.selectedMinyan!, scrollController);
          } else if (!isMinyan && state.selectedSynagogue != null) {
            return _buildSynagogueDetailsSheet(state.selectedSynagogue!, scrollController);
          }
          return const SizedBox();
        },
      ),
    );
  }

  /// Build minyan details sheet
  Widget _buildMinyanDetailsSheet(dynamic minyan, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User-Created Minyan',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Location Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDetailRow('Name', 'Minyan'),
          _buildDetailRow('Date', 'Today'),
          _buildDetailRow('Time', '7:00 AM'),
          _buildDetailRow('Prayer Type', 'Shacharit'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build synagogue details sheet
  Widget _buildSynagogueDetailsSheet(dynamic synagogue, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Established Prayer Venue',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Venue Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDetailRow('Name', synagogue.name),
          _buildDetailRow('Type', synagogue.placeType ?? 'Synagogue'),
          _buildDetailRow('Address', synagogue.address),
          if (synagogue.phoneNumber != null) _buildDetailRow('Phone', synagogue.phoneNumber!),
          if (synagogue.website != null) _buildDetailRow('Website', synagogue.website!),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build detail row for information display
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
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
                icon: _buildNotificationBellIcon(2),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: _buildBottomNavIcon('assets/images/Navbar/user.svg', 3),
                label: 'Profile',
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
      // Map view
      return Column(
        children: [
          // Top Header Bar (Avatar, Title, Settings) - Extends to top
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Status bar spacing
                SizedBox(height: MediaQuery.of(context).padding.top),
        // Header content
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // Title
                    Text(
                      'The10th',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    // Settings Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          context.push('/settings');
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                // Availability Toggle
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
          // Divider
          Container(
            height: 0,
            color: Colors.transparent,
          ),
          // Map and Overlay
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
                            key: ValueKey('map_${state.markers.length}'),  // Force rebuild when markers change
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: initialPosition,
                              zoom: 15.0,
                            ),
                            markers: state.markers,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            style: Theme.of(context).brightness == Brightness.dark
                                ? _getDarkMapStyle()
                                : null,
                          ),
                          // Gradient overlay from header to map
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.primary.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),
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
      // Notifications view
      return Center(
        child: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    } else if (_selectedIndex == 3) {
      // Profile view
      return Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
