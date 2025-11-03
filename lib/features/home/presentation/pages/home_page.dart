import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/widgets/index.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
      ),
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
              if (index == 2) {
                // Settings tab
                context.push('/settings');
              } else {
                setState(() => _selectedIndex = index);
              }
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
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
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


}

