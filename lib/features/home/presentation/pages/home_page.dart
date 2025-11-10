import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/notification_bloc.dart';
import 'package:yad_app/features/home/presentation/widgets/index.dart';
import 'package:yad_app/features/home/presentation/pages/notifications_home_page.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
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
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'MAP',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'MINYAN',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                label: 'NOTIFICATIONS',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.push('/create-minyan');
                },
                backgroundColor: AppTheme.primary,
                label: const Text(
                  'Create Minyan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
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
          // Top Header Bar (Avatar, Title, Settings)
          SafeArea(
            bottom: false,
            left: true,
            right: true,
            top: true,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  // Title
                  Text(
                    'YAD-YAD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                  // Settings Button
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () {
                      context.push('/settings');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
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

                      return GoogleMap(
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
      return BlocProvider<MinyanBloc>(
        create: (context) => getIt<MinyanBloc>()..add(const LoadMyMinyansEvent()),
        child: const MinyanPage(),
      );
    } else if (_selectedIndex == 2) {
      // Notifications view
      return BlocProvider<NotificationBloc>(
        create: (context) => NotificationBloc()..add(const LoadNotificationsEvent()),
        child: const NotificationsHomePage(),
      );
    }

    return const SizedBox();
  }
}
