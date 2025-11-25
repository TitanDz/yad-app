import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MinyanData {
  String? prayerType;
  DateTime? date;
  TimeOfDay? time;
  String? notes;
  String? locationName;
  double? latitude;
  double? longitude;
  String? street;
  String? neighborhood;
  String? locality;
  String? administrativeArea;
  String? postalCode;
  String? country;
  String? fullAddress;

  MinyanData({
    this.prayerType,
    this.date,
    this.time,
    this.notes,
    this.locationName,
    this.latitude,
    this.longitude,
    this.street,
    this.neighborhood,
    this.locality,
    this.administrativeArea,
    this.postalCode,
    this.country,
    this.fullAddress,
  });
}

class CreateMinyanPage extends StatefulWidget {
  const CreateMinyanPage({super.key});

  @override
  State<CreateMinyanPage> createState() => _CreateMinyanPageState();
}

class _CreateMinyanPageState extends State<CreateMinyanPage> {
  int _currentStep = 0;
  late MinyanData _minyanData;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedPrayerType = '';
  late GoogleMapController _mapController;
  final LatLng _mapCenter = const LatLng(40.7128, -74.0060); // Default to NYC
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _minyanData = MinyanData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    // Don't dispose GoogleMapController - it's managed by the GoogleMap widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Minyan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildStepContent(_currentStep),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildPrayerTypeStep();
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildConfirmStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildPrayerTypeStep();
    }
  }

  Widget _buildPrayerTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer Type Section
          const Text(
            'Prayer Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: _buildPrayerTypeButton('Shacharit'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPrayerTypeButton('Mincha'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPrayerTypeButton('Maariv'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Date Section
          const Text(
            'Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _minyanData.date ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (selectedDate != null && mounted) {
                setState(() {
                  _minyanData.date = selectedDate;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Date selected: ${selectedDate.toString().split(' ')[0]}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _minyanData.date != null
                        ? _minyanData.date.toString().split(' ')[0]
                        : 'Select Date',
                    style: TextStyle(
                      color: _minyanData.date != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: _minyanData.date != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Time Section
          const Text(
            'Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: _minyanData.time ?? TimeOfDay.now(),
              );
              if (selectedTime != null && mounted) {
                setState(() {
                  _minyanData.time = selectedTime;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Time selected: ${selectedTime.format(context)}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _minyanData.time != null
                        ? _minyanData.time!.format(context)
                        : 'Select Time',
                    style: TextStyle(
                      color: _minyanData.time != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: _minyanData.time != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Notes Section
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            onChanged: (value) {
              setState(() {
                _minyanData.notes = value.isNotEmpty ? value : null;
              });
            },
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Add notes about your minyan...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPrayerType.isEmpty || _minyanData.date == null || _minyanData.time == null
                  ? null
                  : () {
                      setState(() => _currentStep = 1);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue to Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTypeButton(String label) {
    final isSelected = _selectedPrayerType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrayerType = isSelected ? '' : label;
          _minyanData.prayerType = isSelected ? null : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: Colors.white,
              ),
            if (isSelected) const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Google Maps
              GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _mapCenter,
                  zoom: 12,
                ),
                markers: _markers,
                onTap: (LatLng latLng) async {
                  // Add marker to map
                  final markerId = MarkerId('selected_location');
                  final marker = Marker(
                    markerId: markerId,
                    position: latLng,
                    infoWindow: const InfoWindow(
                      title: 'Selected Location',
                    ),
                  );
                  setState(() {
                    _markers.clear();
                    _markers.add(marker);
                  });

                  // Get detailed address from coordinates (reverse geocoding)
                  final addressDetails = await _getAddressDetails(latLng);
                  _showLocationConfirmDialog(
                    addressDetails['name'] ?? 'Unknown Location',
                    latLng.latitude,
                    latLng.longitude,
                    addressDetails['fullAddress'] ?? '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
                    street: addressDetails['street'],
                    neighborhood: addressDetails['neighborhood'],
                    locality: addressDetails['locality'],
                    administrativeArea: addressDetails['administrativeArea'],
                    postalCode: addressDetails['postalCode'],
                    country: addressDetails['country'],
                  );
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
              
              // Search Bar overlay with results dropdown
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _updateSearchResults(value);
                          });
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty && _searchResults.isNotEmpty) {
                            _selectSearchResult(_searchResults[0]);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for location',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    // Search results dropdown
                    if (_searchResults.isNotEmpty)
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
                        constraints: BoxConstraints(
                          maxHeight: 200,
                        ),
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return InkWell(
                              onTap: () => _selectSearchResult(result),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: index < _searchResults.length - 1
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
                                          if (result['address'] != null)
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

              // Zoom controls (bottom right)
              Positioned(
                bottom: 16,
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
                            _mapController.animateCamera(
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
                            _mapController.animateCamera(
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
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom Action Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _minyanData.locationName != null
                    ? () {
                        setState(() => _currentStep = 2);
                      }
                    : null,
                child: const Text('Continue to Confirm'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location privacy settings'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                label: const Text('Location Privacy'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Map<String, String>> _getAddressDetails(LatLng latLng) async {
    // Try Google Maps Geocoding API first (most reliable)
    try {
      final result = await _getAddressFromGoogleAPI(latLng);
      if (result != null) {
        return result;
      }
    } catch (e) {
      debugPrint('Google API geocoding error: $e');
    }

    // Fallback to native geocoding
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        return _parsePlacemark(placemarks.first);
      }
    } catch (e) {
      debugPrint('Native geocoding error: $e');
    }

    // Fallback to mock addresses
    return _getMockAddressForLocation(latLng);
  }

  Future<Map<String, String>?> _getAddressFromGoogleAPI(LatLng latLng) async {
    try {
      const apiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final result = results.first as Map<String, dynamic>;
          return _parseGoogleGeocodingResult(result, latLng);
        }
      }
    } catch (e) {
      debugPrint('Google API error: $e');
    }
    return null;
  }

  Map<String, String> _parseGoogleGeocodingResult(Map<String, dynamic> result, LatLng latLng) {
    final formattedAddress = result['formatted_address'] as String? ?? '';
    final addressComponents =
        result['address_components'] as List<dynamic>? ?? [];

    // Extract components
    String street = '';
    String neighborhood = '';
    String locality = '';
    String administrativeArea = '';
    String postalCode = '';
    String country = '';

    for (final component in addressComponents) {
      final types = (component['types'] as List<dynamic>?) ?? [];
      final longName = component['long_name'] as String? ?? '';
      final shortName = component['short_name'] as String? ?? '';

      if (types.contains('street_number')) {
        street = '$longName $street';
      } else if (types.contains('route')) {
        street = '$street $longName'.trim();
      } else if (types.contains('neighborhood')) {
        neighborhood = longName;
      } else if (types.contains('locality')) {
        locality = longName;
      } else if (types.contains('administrative_area_level_1')) {
        administrativeArea = shortName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      } else if (types.contains('country')) {
        country = longName;
      }
    }

    // Build name from available data
    final name = street.isNotEmpty
        ? street
        : neighborhood.isNotEmpty
            ? neighborhood
            : locality.isNotEmpty
                ? locality
                : 'Selected Location';

    return {
      'name': name.trim(),
      'fullAddress': formattedAddress.isNotEmpty
          ? formattedAddress
          : '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
      'street': street.trim(),
      'neighborhood': neighborhood,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'postalCode': postalCode,
      'country': country,
    };
  }

  Map<String, String> _parsePlacemark(Placemark placemark) {
    final street = placemark.street ?? '';
    final thoroughfare = placemark.thoroughfare ?? '';
    final subThoroughfare = placemark.subThoroughfare ?? '';
    final locality = placemark.locality ?? '';
    final subLocality = placemark.subLocality ?? '';
    final administrativeArea = placemark.administrativeArea ?? '';
    final postalCode = placemark.postalCode ?? '';
    final country = placemark.country ?? '';

    String name = '';
    if (street.isNotEmpty) {
      name = street;
    } else if (thoroughfare.isNotEmpty) {
      name = thoroughfare;
    } else if (locality.isNotEmpty) {
      name = locality;
    } else if (subLocality.isNotEmpty) {
      name = subLocality;
    } else {
      name = 'Unknown Location';
    }

    List<String> addressParts = [];
    if (subThoroughfare.isNotEmpty) addressParts.add(subThoroughfare);
    if (street.isNotEmpty) addressParts.add(street);
    if (subLocality.isNotEmpty) addressParts.add(subLocality);
    if (locality.isNotEmpty) addressParts.add(locality);
    if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
    if (postalCode.isNotEmpty) addressParts.add(postalCode);
    if (country.isNotEmpty) addressParts.add(country);

    final fullAddress = addressParts.join(', ');

    return {
      'name': name,
      'fullAddress': fullAddress.isNotEmpty
          ? fullAddress
          : 'No address available',
      'street': street,
      'neighborhood': subLocality,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'postalCode': postalCode,
      'country': country,
    };
  }

  Map<String, String> _getMockAddressForLocation(LatLng latLng) {
    // Provide offline mock addresses for common locations
    // This is a fallback when reverse geocoding is not available
    final lat = latLng.latitude;
    final lng = latLng.longitude;

    // Central Park
    if ((lat - 40.7829).abs() < 0.01 && (lng - (-73.9654)).abs() < 0.01) {
      return {
        'name': 'Central Park',
        'fullAddress': 'Central Park, Manhattan, New York, 10024, United States',
        'street': '',
        'neighborhood': 'Midtown',
        'locality': 'New York',
        'administrativeArea': 'New York',
        'postalCode': '10024',
        'country': 'United States',
      };
    }

    // Times Square
    if ((lat - 40.7580).abs() < 0.01 && (lng - (-73.9855)).abs() < 0.01) {
      return {
        'name': 'Times Square',
        'fullAddress': '1500 Broadway, Times Square, Manhattan, New York, 10036, United States',
        'street': 'Broadway',
        'neighborhood': 'Times Square',
        'locality': 'New York',
        'administrativeArea': 'New York',
        'postalCode': '10036',
        'country': 'United States',
      };
    }

    // Statue of Liberty
    if ((lat - 40.6892).abs() < 0.01 && (lng - (-74.0445)).abs() < 0.01) {
      return {
        'name': 'Statue of Liberty',
        'fullAddress': 'Liberty Island, New York, 10004, United States',
        'street': '',
        'neighborhood': 'Lower Manhattan',
        'locality': 'New York',
        'administrativeArea': 'New York',
        'postalCode': '10004',
        'country': 'United States',
      };
    }

    // Default for any other location
    return {
      'name': 'Selected Location',
      'fullAddress': '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
      'street': '',
      'neighborhood': '',
      'locality': '',
      'administrativeArea': '',
      'postalCode': '',
      'country': '',
    };
  }

  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    final resultLocation = result['location'] as LatLng;
    final resultName = result['name'] as String;
    final addressDetails = await _getAddressDetails(resultLocation);

    _searchController.clear();
    setState(() {
      _searchResults = [];
    });

    // Add marker to map
    final markerId = MarkerId('selected_location');
    final marker = Marker(
      markerId: markerId,
      position: resultLocation,
      infoWindow: InfoWindow(
        title: resultName,
      ),
    );
    setState(() {
      _markers.clear();
      _markers.add(marker);
    });

    // Animate camera to location
    _mapController.animateCamera(
      CameraUpdate.newLatLng(resultLocation),
    );

    // Show confirmation dialog
    _showLocationConfirmDialog(
      addressDetails['name'] ?? resultName,
      resultLocation.latitude,
      resultLocation.longitude,
      addressDetails['fullAddress'] ?? '${resultLocation.latitude.toStringAsFixed(4)}, ${resultLocation.longitude.toStringAsFixed(4)}',
      street: addressDetails['street'],
      neighborhood: addressDetails['neighborhood'],
      locality: addressDetails['locality'],
      administrativeArea: addressDetails['administrativeArea'],
      postalCode: addressDetails['postalCode'],
      country: addressDetails['country'],
    );
  }

  void _updateSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final results = await _getGooglePlacePredictions(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      debugPrint('Error fetching place predictions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getGooglePlacePredictions(
      String input) async {
    const apiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';
    const sessionToken = 'session_token';

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$input'
          '&components=country:us'
          '&key=$apiKey'
          '&sessiontoken=$sessionToken';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final predictions = json['predictions'] as List<dynamic>? ?? [];

        final results = <Map<String, dynamic>>[];

        for (var i = 0; i < predictions.length && i < 5; i++) {
          final prediction = predictions[i] as Map<String, dynamic>;
          final placeId = prediction['place_id'] as String?;
          final mainText = prediction['main_text'] as String?;
          final secondaryText = prediction['secondary_text'] as String?;

          if (placeId != null && mainText != null) {
            // Get place details to get coordinates
            final details = await _getPlaceDetails(placeId);
            if (details != null) {
              results.add({
                'name': mainText,
                'address': secondaryText ?? '',
                'location': details['location'] as LatLng,
                'placeId': placeId,
              });
            }
          }
        }

        return results;
      } else {
        debugPrint('Google Places API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception in _getGooglePlacePredictions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
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

          if (location != null) {
            return {
              'location': LatLng(
                location['lat'] as double,
                location['lng'] as double,
              ),
              'address': result['formatted_address'] as String?,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    }

    return null;
  }

  void _showLocationConfirmDialog(
    String locationName,
    double lat,
    double lng,
    String address, {
    String? street,
    String? neighborhood,
    String? locality,
    String? administrativeArea,
    String? postalCode,
    String? country,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            locationName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minyanData.locationName = locationName;
                          _minyanData.latitude = lat;
                          _minyanData.longitude = lng;
                          _minyanData.street = street ?? '';
                          _minyanData.neighborhood = neighborhood ?? '';
                          _minyanData.locality = locality ?? '';
                          _minyanData.administrativeArea = administrativeArea ?? '';
                          _minyanData.postalCode = postalCode ?? '';
                          _minyanData.country = country ?? '';
                          _minyanData.fullAddress = address;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Location set to: $locationName'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmStep() {
    final dateStr = _minyanData.date != null
        ? '${_minyanData.date!.toString().split(' ')[0]} (${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_minyanData.date!.weekday - 1]})'
        : 'Not selected';
    final timeStr = _minyanData.time != null
        ? _minyanData.time!.format(context)
        : 'Not selected';
    final prayerTypeStr = _minyanData.prayerType ?? 'Not selected';
    final locationStr = _minyanData.locationName ?? 'Not selected';
    final notesStr = _minyanData.notes ?? 'No notes added';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minyan Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailCard(Icons.menu_book, 'Prayer Type', prayerTypeStr),
          const SizedBox(height: 12),
          _buildDetailCard(Icons.calendar_today, 'Date', dateStr),
          const SizedBox(height: 12),
          _buildDetailCard(Icons.access_time, 'Time', timeStr),
          const SizedBox(height: 12),
          _buildDetailCard(Icons.location_on, 'Location', locationStr),
          // Display complete address details if location was selected
          if (_minyanData.fullAddress != null && _minyanData.fullAddress!.isNotEmpty) ...
            [
              const SizedBox(height: 12),
              _buildAddressDetailsSection(),
            ],
          const SizedBox(height: 12),
          _buildDetailCard(Icons.note, 'Notes', notesStr),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep = 0);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _currentStep = 3);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Publish Minyan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (_minyanData.street!.isNotEmpty)
            _buildAddressField('Street', _minyanData.street!),
          if (_minyanData.street!.isNotEmpty && _minyanData.neighborhood!.isNotEmpty)
            const SizedBox(height: 8),
          if (_minyanData.neighborhood!.isNotEmpty)
            _buildAddressField('Neighborhood', _minyanData.neighborhood!),
          if (_minyanData.neighborhood!.isNotEmpty && _minyanData.locality!.isNotEmpty)
            const SizedBox(height: 8),
          if (_minyanData.locality!.isNotEmpty)
            _buildAddressField('City', _minyanData.locality!),
          if (_minyanData.locality!.isNotEmpty && _minyanData.administrativeArea!.isNotEmpty)
            const SizedBox(height: 8),
          if (_minyanData.administrativeArea!.isNotEmpty)
            _buildAddressField('State', _minyanData.administrativeArea!),
          if (_minyanData.administrativeArea!.isNotEmpty && _minyanData.postalCode!.isNotEmpty)
            const SizedBox(height: 8),
          if (_minyanData.postalCode!.isNotEmpty)
            _buildAddressField('Postal Code', _minyanData.postalCode!),
          if (_minyanData.postalCode!.isNotEmpty && _minyanData.country!.isNotEmpty)
            const SizedBox(height: 8),
          if (_minyanData.country!.isNotEmpty)
            _buildAddressField('Country', _minyanData.country!),
        ],
      ),
    );
  }

  Widget _buildAddressField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        // Header illustration area
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Minyan is live!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Share the link below or the QR code to invite others to join your Minyan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Link and QR Code section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Share Link Label
                Text(
                  'Share This Link',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                // Link field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'https://a10th.app/minyan/abc123',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.content_copy,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // QR Code section
                Text(
                  'Or Share QR Code',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text(
                          'Share Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text(
                          'Share QR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
