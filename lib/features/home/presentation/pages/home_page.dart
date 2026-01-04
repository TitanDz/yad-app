import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/availability_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/active_users_bloc.dart';
import 'package:yad_app/features/home/domain/entities/active_user_marker.dart';
import 'package:yad_app/features/home/presentation/pages/minyan_page.dart';
import 'package:yad_app/features/home/presentation/widgets/index.dart';
import 'package:yad_app/features/home/presentation/widgets/home_refinements.dart';
import 'package:yad_app/features/home/presentation/widgets/next_prayer_countdown.dart';
import 'package:yad_app/features/home/presentation/bloc/notification_bloc.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';
import 'package:yad_app/core/services/user_preferences_manager.dart';
import 'package:yad_app/features/home/presentation/pages/prayers_page.dart';
import 'package:yad_app/features/home/presentation/pages/notifications_home_page.dart';
import 'package:yad_app/features/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:yad_app/features/invitation/presentation/widgets/send_invitations_sheet.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_state.dart';
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
  String _userId = 'user_123'; // Will be updated from AuthBloc
  bool _refreshTriggered = false; // Flag to prevent duplicate refresh triggers
  late PrayerCountdownService _prayerCountdownService;
  List<PrayerTimeInfo> _prayerTimes = [];
  String _cityCountry = '';
  bool _prayerTimesLoading = true;
  late ActiveUsersBloc _activeUsersBloc;
  bool _activeUsersLoaded = false;
  late InvitationBloc _invitationBloc;
  String? _currentUserId; // Track current user to detect account switches

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
    // Initialize ActiveUsersBloc for nearby user markers
    _activeUsersBloc = getIt<ActiveUsersBloc>();
    debugPrint(
      '✅ [HomePage initState] ActiveUsersBloc initialized: ${_activeUsersBloc.hashCode}',
    );
    // Initialize PrayerCountdownService
    _prayerCountdownService = getIt<PrayerCountdownService>();
    // Initialize InvitationBloc for invitation system
    _invitationBloc = getIt<InvitationBloc>();


    // Set up listener to detect user changes
    _updateCurrentUserId(); // Initialize user ID from auth state
    _setupAuthListener();
    debugPrint(
      '[HomePage initState] Auth listener setup complete, _currentUserId=$_currentUserId',
    );

    // Add initialization event to HomeBloc only once
    _homeBloc.add(const InitializeMapEvent());
    // Initialize availability tracking
    _availabilityBloc.add(InitializeAvailabilityEvent(userId: _userId));
    // Load nearby active users (will trigger after map initializes)
    _loadNearbyActiveUsers();

    // Reset refresh flag when the page comes back into focus
    _refreshTriggered = false;

    // Initialize prayer times with default location
    _initializePrayerTimes();

    // Get user location and city/country
    _getUserLocationAndCity();

  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always check for user changes when widget updates
    // This catches cases where user navigates back after logging in with a different account

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndHandleUserChange();
    });
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

  /// Set up listener to detect user account changes and reload nearby users
  void _setupAuthListener() {
    try {
      final authBloc = getIt<AuthBloc>();
      // Get current user ID from auth state
      _updateCurrentUserId();



      // Listen for auth state changes using stream listener
      authBloc.stream.listen(
        (authState) {
          // AuthBloc emitted state: ${authState.runtimeType}
          final userId = _extractUserIdFromAuthState(authState);
          // Extracted userId from state: $userId
          _checkAndHandleUserChange();
        },
        onError: (error) {
          // Stream error: $error
        },
        onDone: () {
          // Stream closed/done
        },
      );


    } catch (e) {
      // Could not set up auth listener: $e
    }
  }

  /// Extract and return the current user ID from AuthBloc
  String? _extractUserIdFromAuthState(AuthState authState) {
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    } else if (authState is AuthLoginSuccess) {
      return authState.user.id;
    } else if (authState is AuthRegistrationSuccess) {
      return authState.user.id;
    }
    return null;
  }

  /// Update the stored current user ID from AuthBloc state
  void _updateCurrentUserId() {
    try {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;
      final newUserId = _extractUserIdFromAuthState(authState);
      _currentUserId = newUserId;
      if (newUserId != null) {
        _userId = newUserId; // Update the _userId from auth state
      }
      // Current user ID: $_currentUserId
    } catch (e) {
      // Error: $e
    }
  }

  /// Check if user has changed and reload nearby users if so
  void _checkAndHandleUserChange() {
    try {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;
      final newUserId = _extractUserIdFromAuthState(authState);

      // Current: $_currentUserId, New: $newUserId, AuthState: ${authState.runtimeType}

      // If user ID changed, reset and reload nearby users
      if (newUserId != null && _currentUserId != newUserId) {
        debugPrint(
          '[_checkAndHandleUserChange] **USER SWITCHED** from $_currentUserId to $newUserId',
        );
        debugPrint('[_checkAndHandleUserChange] Resetting flags for new user');
        _currentUserId = newUserId;
        if (newUserId != null) {
          _userId = newUserId; // Update the _userId when user changes
        }
        _activeUsersLoaded = false; // CRITICAL: Reset flag to allow reload
        _refreshTriggered = false; // Reset refresh flag
        debugPrint(
          '[_checkAndHandleUserChange] Calling _loadNearbyActiveUsers(forceReload: true)',
        );
        _loadNearbyActiveUsers(forceReload: true);
        debugPrint('[_checkAndHandleUserChange] User switch handling complete');
      } else {
        debugPrint(
          '[_checkAndHandleUserChange] No user change detected (newUserId=$newUserId, _currentUserId=$_currentUserId)',
        );
      }
    } catch (e) {
      debugPrint('[_checkAndHandleUserChange] Error checking user: $e');
    }
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

  /// Load nearby active users on the map
  void _loadNearbyActiveUsers({bool forceReload = false}) {
    debugPrint(
      '🔵 [_loadNearbyActiveUsers] Called, checking HomeBloc state...',
    );
    debugPrint('   Current state type: ${_homeBloc.state.runtimeType}');
    debugPrint('   _activeUsersLoaded flag: $_activeUsersLoaded');
    debugPrint('   forceReload: $forceReload');

    // Check if map is ready right away
    final homeState = _homeBloc.state;
    if (homeState is HomeMapReady) {
      if (_activeUsersLoaded && !forceReload) {
        debugPrint(
          '🔵 [_loadNearbyActiveUsers] Users already loaded, skipping...',
        );
        return;
      }

      // Use user location or fallback to NYC
      final latitude = homeState.userLocation?.latitude ?? 40.7128;
      final longitude = homeState.userLocation?.longitude ?? -74.0060;

      debugPrint(
        '🔵 [_loadNearbyActiveUsers] Map is ready! Loading nearby active users from ($latitude, $longitude)...',
      );
      _activeUsersBloc.add(
        LoadNearbyUsersEvent(
          latitude: latitude,
          longitude: longitude,
          radiusKm: 10.0, // 10 km search radius
        ),
      );
      // CRITICAL FIX: Don't set flag here - only set it after markers are successfully created
      // This is now handled by the BlocListener for ActiveUsersBloc
    } else {
      // If not ready yet, schedule a retry
      debugPrint(
        '⏳ [_loadNearbyActiveUsers] Map not ready yet (state: ${homeState.runtimeType})',
      );
      debugPrint('   Will retry in 500ms...');
      Future.delayed(const Duration(milliseconds: 500), () {
        debugPrint('🔵 [_loadNearbyActiveUsers] Retrying after delay...');
        _loadNearbyActiveUsers(forceReload: forceReload);
      });
    }
  }

  /// Handle sending invitations to nearby users
  void _handleSendInvitations() {
    final homeState = _homeBloc.state;

    // Check if map is ready
    if (homeState is! HomeMapReady) {
      debugPrint('❌ [_handleSendInvitations] Map not ready');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map is initializing. Please wait.')),
      );
      return;
    }

    // Check if nearby users have been loaded
    final activeUsersState = _activeUsersBloc.state;
    if (activeUsersState is! ActiveUsersLoaded ||
        activeUsersState.users.isEmpty) {
      debugPrint('❌ [_handleSendInvitations] No nearby users loaded');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No nearby users found. Try moving to a different location.',
          ),
        ),
      );
      return;
    }

    debugPrint(
      '✅ [_handleSendInvitations] Opening invitation sheet with ${activeUsersState.users.length} nearby users',
    );

    // Show the SendInvitationsSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SendInvitationsSheet(
        nearbyUsers: activeUsersState.users,
        minyanDetails: 'Minyan - Prayer Time TBD',
        onSendInvitations: (selectedUserIds) {
          // Send invitations to selected users
          if (selectedUserIds.isEmpty) return;

          debugPrint(
            '📤 [_handleSendInvitations] Sending invitations to ${selectedUserIds.length} users',
          );

          // Extract recipient names and distances from active users
          final selectedNames = <String>[];
          final selectedDistances = <double>[];

          if (activeUsersState is ActiveUsersLoaded) {
            for (final userId in selectedUserIds) {
              final user = activeUsersState.users.firstWhere(
                (u) => u.userId == userId,
                orElse: () => ActiveUserMarker(
                  userId: userId,
                  name: 'Unknown User',
                  latitude: 0,
                  longitude: 0,
                  address: '',
                  isAvailable: false,
                  minutesUnavailable: 0,
                  distance: 0.5,
                ),
              );
              selectedNames.add(user.name);
              selectedDistances.add(user.distance ?? 0.5);
            }
          }

          // Use InvitationBloc to send invitations
          _invitationBloc.add(
            SendInvitationsEvent(
              minyanId: 'minyan_${DateTime.now().millisecondsSinceEpoch}',
              senderId: _userId,
              senderName: 'Current User',
              recipientIds: selectedUserIds,
              minyanDetails: 'Minyan - Prayer Time TBD',
              recipientNames: selectedNames,
              distances: selectedDistances,
            ),
          );

          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sent invitations to ${selectedUserIds.length} users',
              ),
            ),
          );
        },
      ),
    );
  }

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
            final city =
                placemark.locality ?? placemark.administrativeArea ?? '';
            final country = placemark.country ?? '';
            final cityCountry = [
              city,
              country,
            ].where((s) => s.isNotEmpty).join(', ');

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

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final status = json['status'] as String?;

        if (status == 'OK') {
          final predictions = json['predictions'] as List<dynamic>? ?? [];
          final results = <Map<String, dynamic>>[];

          for (var i = 0; i < predictions.length && i < 5; i++) {
            final prediction = predictions[i] as Map<String, dynamic>;
            final placeId = prediction['place_id'] as String?;
            final structuredFormatting =
                prediction['structured_formatting'] as Map<String, dynamic>?;
            final mainText = structuredFormatting?['main_text'] as String?;
            final secondaryText =
                structuredFormatting?['secondary_text'] as String?;

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

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

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
                CameraPosition(target: LatLng(lat, lng), zoom: 17.0),
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
            Icon(Icons.notifications, color: AppTheme.divinity, size: 24),
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
          colorFilter: ColorFilter.mode(AppTheme.divinity, BlendMode.srcIn),
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
        child: Icon(Icons.schedule, color: AppTheme.divinity, size: 24),
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
                icon: _buildBottomNavIcon(
                  'assets/images/Navbar/calendar.svg',
                  1,
                ),
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
              isAvailable:
                  _availabilityBloc.state is AvailabilityLoaded &&
                  !(_availabilityBloc.state as AvailabilityLoaded)
                      .status
                      .isCurrentlyUnavailable,
              onSendInvitations: () {
                _handleSendInvitations();
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
      return BlocProvider<ActiveUsersBloc>.value(
        value: _activeUsersBloc,
        child: HomeRefinements.buildRefinedHomeLayout(
          context: context,
          cityCountry: _cityCountry,
          prayerTimes: _prayerTimes,
          availabilityBloc: _availabilityBloc,
          userId: _userId,
          homeBloc: _homeBloc,
          onMapCreated: _onMapCreated,
          getDarkMapStyle: _getDarkMapStyle,
        ),
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
        child: NotificationsHomePage(),
      );
    }

    return const SizedBox();
  }
}
