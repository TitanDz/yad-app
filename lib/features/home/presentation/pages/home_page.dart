import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';
import 'package:yad_app/features/home/presentation/widgets/index.dart';
import 'package:yad_app/features/home/presentation/pages/minyan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  late MinyanBloc _minyanBloc;
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initialize MinyanBloc once and reuse it
    _minyanBloc = getIt<MinyanBloc>();
    // Initialize HomeBloc once and reuse it
    _homeBloc = getIt<HomeBloc>();
    // Add initialization event to HomeBloc only once
    _homeBloc.add(const InitializeMapEvent());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    // Don't dispose _minyanBloc here as it's managed by service locator
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showSearchResults = _searchController.text.isNotEmpty;
    });
    if (_searchController.text.isNotEmpty) {
      context.read<HomeBloc>().add(
            SearchPlacesEvent(_searchController.text),
          );
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
    });
    context.read<HomeBloc>().add(const ClearSearchEvent());
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildBottomNavIcon('assets/images/Navbar/calendar.svg', 1),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildBottomNavIcon('assets/images/Navbar/groups.svg', 2),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildBottomNavIcon('assets/images/Navbar/user.svg', 3),
                label: '',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/create-minyan');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Create Minyan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
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
                      final userLocation = state.userLocation;
                      final initialPosition = userLocation != null
                          ? LatLng(userLocation.latitude, userLocation.longitude)
                          : const LatLng(40.7128, -74.0060);

                      return Stack(
                        children: [
                          GoogleMap(
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

                // Floating Search Bar (overlaying map)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: SearchLocationBar(
                    controller: _searchController,
                    onSearch: (query) {},
                    onClear: _onClearSearch,
                  ),
                ),

                // Search Results Sheet
                if (_showSearchResults)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeMapReady) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: state.searchResults.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_off,
                                          size: 48,
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No places found',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    itemCount: state.searchResults.length,
                                    itemBuilder: (context, index) {
                                      final place = state.searchResults[index];
                                      final isSelected =
                                          state.selectedPlace?.id == place.id;

                                      return PlaceCard(
                                        place: place,
                                        isSelected: isSelected,
                                        onTap: () {
                                          context.read<HomeBloc>().add(
                                                SelectPlaceEvent(place),
                                              );

                                          _mapController?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: LatLng(
                                                  place.latitude,
                                                  place.longitude,
                                                ),
                                                zoom: 17.0,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      // Minyan view
      return BlocProvider<MinyanBloc>.value(
        value: _minyanBloc,
        child: const MinyanPage(),
      );
    } else if (_selectedIndex == 2) {
      // Messages view
      return Center(
        child: Text(
          'Messages',
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
