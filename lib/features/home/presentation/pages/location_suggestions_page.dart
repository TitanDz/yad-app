import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yad_app/features/invitation/domain/entities/group_lobby.dart';
import 'package:yad_app/core/models/user_preferences.dart';

class LocationSuggestionsPage extends StatefulWidget {
  final GroupLobby? lobby;

  const LocationSuggestionsPage({super.key, this.lobby});

  @override
  State<LocationSuggestionsPage> createState() => _LocationSuggestionsPageState();
}

class _LocationSuggestionsPageState extends State<LocationSuggestionsPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _suggestedLocations = [];
  bool _isLoadingSuggestions = true;
  String? _selectedLocationId;
  UserPreferences? _userPreferences;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _loadLocationSuggestions();
  }

  Future<void> _loadUserPreferences() async {
    // In a real app, this would come from the user preferences bloc
    // For now, we'll simulate loading user preferences
    setState(() {
      _userPreferences = UserPreferences(
        userId: 'user_123',
        latitude: 40.7128,
        longitude: -74.0060,
        address: 'New York, NY',
        searchRadiusMiles: 10,
      );
    });
  }

  Future<void> _loadLocationSuggestions() async {
    // Simulate loading location suggestions from an API or service
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock location suggestions
    final suggestions = [
      {
        'id': 'suggestion_1',
        'name': 'Central Synagogue',
        'address': '123 E 60th St, New York, NY 10022',
        'latitude': 40.7614,
        'longitude': -73.9710,
        'type': 'Synagogue',
        'distance': '0.8 miles',
        'rating': 4.7,
      },
      {
        'id': 'suggestion_2',
        'name': 'Congregation Beit Simchat Torah',
        'address': '349 W 19th St, New York, NY 10011',
        'latitude': 40.7522,
        'longitude': -74.0011,
        'type': 'Synagogue',
        'distance': '1.2 miles',
        'rating': 4.8,
      },
      {
        'id': 'suggestion_3',
        'name': 'The Jewish Center',
        'address': '1767 Broadway, New York, NY 10019',
        'latitude': 40.7682,
        'longitude': -73.9822,
        'type': 'Synagogue',
        'distance': '1.5 miles',
        'rating': 4.6,
      },
      {
        'id': 'suggestion_4',
        'name': 'Park Avenue Synagogue',
        'address': '170 E 87th St, New York, NY 10128',
        'latitude': 40.7823,
        'longitude': -73.9552,
        'type': 'Synagogue',
        'distance': '2.1 miles',
        'rating': 4.5,
      },
      {
        'id': 'suggestion_5',
        'name': 'Temple Emanu-El',
        'address': '1 E 65th St, New York, NY 10065',
        'latitude': 40.7737,
        'longitude': -73.9808,
        'type': 'Synagogue',
        'distance': '1.8 miles',
        'rating': 4.9,
      },
    ];

    setState(() {
      _suggestedLocations = suggestions;
      _isLoadingSuggestions = false;
      _addMarkersForSuggestions();
    });
  }

  void _addMarkersForSuggestions() {
    _markers.clear();
    
    // Add markers for each suggested location
    for (int i = 0; i < _suggestedLocations.length; i++) {
      final suggestion = _suggestedLocations[i];
      final marker = Marker(
        markerId: MarkerId('suggestion_${i + 1}'),
        position: LatLng(suggestion['latitude'] as double, suggestion['longitude'] as double),
        infoWindow: InfoWindow(
          title: suggestion['name'] as String,
          snippet: suggestion['address'] as String,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      _markers.add(marker);
    }
    
    // Add user's current location marker
    if (_userPreferences != null) {
      final userMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_userPreferences!.latitude!, _userPreferences!.longitude!),
        infoWindow: const InfoWindow(
          title: 'Your Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _markers.add(userMarker);
    }
    
    setState(() {});
  }

  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _selectedLocationId = location['id'];
    });
  }

  void _goToCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestResult = await Geolocator.requestPermission();
        if (requestResult == LocationPermission.denied ||
            requestResult == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get current location: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToCreateMinyan(Map<String, dynamic> location) {
    // Navigate to CreateMinyanPage with the selected location
    GoRouter.of(context).go('/create-minyan', extra: {
      'selectedLocation': {
        'name': location['name'],
        'address': location['address'],
        'latitude': location['latitude'],
        'longitude': location['longitude'],
      },
      'lobby': widget.lobby,
    });
  }

  void _navigateToManualLocation() {
    // Navigate to CreateMinyanPage without a pre-selected location
    // This allows users to choose their own location
    GoRouter.of(context).go('/create-minyan', extra: {
      'lobby': widget.lobby,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Suggestions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Map view showing suggested locations
          Expanded(
            flex: 2,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _userPreferences != null
                    ? LatLng(_userPreferences!.latitude!, _userPreferences!.longitude!)
                    : const LatLng(40.7128, -74.0060),
                zoom: 12,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          
          // Location suggestions list
          Expanded(
            flex: 1,
            child: _isLoadingSuggestions
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _suggestedLocations.length,
                    itemBuilder: (context, index) {
                      final location = _suggestedLocations[index];
                      final isSelected = _selectedLocationId == location['id'];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location['distance'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            location['name'] as String,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(location['address'] as String),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    location['rating'].toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      location['type'] as String,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            _selectLocation(location);
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  location['latitude'] as double,
                                  location['longitude'] as double,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Button to confirm selected location
            ElevatedButton(
              onPressed: _selectedLocationId != null
                  ? () {
                      final selectedLocation = _suggestedLocations
                          .firstWhere((loc) => loc['id'] == _selectedLocationId);
                      _navigateToCreateMinyan(selectedLocation);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Use This Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Button to choose a different location
            OutlinedButton(
              onPressed: _navigateToManualLocation,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Choose Different Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}