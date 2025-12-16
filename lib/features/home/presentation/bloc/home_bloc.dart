import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yad_app/features/home/data/datasources/location_service.dart';
import 'package:yad_app/features/home/data/repositories/place_repository.dart';
import 'package:yad_app/features/home/data/repositories/minyan_repository.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';
import 'package:yad_app/features/home/domain/entities/user_location.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';
import 'package:yad_app/core/services/marker_builder.dart';
import 'package:yad_app/core/services/routing_service.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMapEvent extends HomeEvent {
  const InitializeMapEvent();
}

class SearchPlacesEvent extends HomeEvent {
  final String query;
  final bool jewishVenuesOnly;

  const SearchPlacesEvent(this.query, {this.jewishVenuesOnly = false});

  @override
  List<Object?> get props => [query, jewishVenuesOnly];
}

class SelectPlaceEvent extends HomeEvent {
  final Place place;

  const SelectPlaceEvent(this.place);

  @override
  List<Object?> get props => [place];
}

class GetCurrentLocationEvent extends HomeEvent {
  const GetCurrentLocationEvent();
}

class UpdateMapCameraEvent extends HomeEvent {
  final LatLng position;
  final double zoom;

  const UpdateMapCameraEvent(this.position, {this.zoom = 15.0});

  @override
  List<Object?> get props => [position, zoom];
}

class LoadJewishVenuesEvent extends HomeEvent {
  const LoadJewishVenuesEvent();
}

class ClearSearchEvent extends HomeEvent {
  const ClearSearchEvent();
}

class LoadPrayerLocationsEvent extends HomeEvent {
  /// Load both user-created minyanim and Jewish synagogues on the map
  const LoadPrayerLocationsEvent();
}

class SelectMarkerEvent extends HomeEvent {
  final String markerId;
  final bool isMinyan;

  const SelectMarkerEvent(this.markerId, {this.isMinyan = false});

  @override
  List<Object?> get props => [markerId, isMinyan];
}

class RefreshNearbyMiniyansEvent extends HomeEvent {
  /// Refresh the list of nearby minyans (e.g., after creating a new minyan)
  /// Optional: provide specific coordinates to search from (used when creating a minyan at a new location)
  final double? latitude;
  final double? longitude;

  const RefreshNearbyMiniyansEvent({this.latitude, this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class DrawRouteEvent extends HomeEvent {
  /// Draw a route from user's current location to the selected minyan
  final LatLng origin;
  final LatLng destination;
  final String minyanId;

  const DrawRouteEvent({
    required this.origin,
    required this.destination,
    required this.minyanId,
  });

  @override
  List<Object?> get props => [origin, destination, minyanId];
}

class ClearRouteEvent extends HomeEvent {
  /// Clear the displayed route from the map
  const ClearRouteEvent();
}

class ShowMinyanDetailsEvent extends HomeEvent {
  /// Show minyan details in a bottom sheet
  final Minyan minyan;
  
  const ShowMinyanDetailsEvent(this.minyan);
  
  @override
  List<Object?> get props => [minyan];
}

class ClearSelectedMinyanEvent extends HomeEvent {
  /// Clear the selected minyan to allow re-selection of the same marker
  const ClearSelectedMinyanEvent();
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeMapReady extends HomeState {
  final UserLocation? userLocation;
  final List<Place> searchResults;
  final Place? selectedPlace;
  final Set<Marker> markers;
  final List<Minyan> minyans;
  final List<Place> synagogues;
  final Minyan? selectedMinyan;
  final Place? selectedSynagogue;
  final Set<Polyline> polylines;
  final String? selectedRouteMinyanId;

  const HomeMapReady({
    this.userLocation,
    this.searchResults = const [],
    this.selectedPlace,
    this.markers = const {},
    this.minyans = const [],
    this.synagogues = const [],
    this.selectedMinyan,
    this.selectedSynagogue,
    this.polylines = const {},
    this.selectedRouteMinyanId,
  });

  HomeMapReady copyWith({
    UserLocation? userLocation,
    List<Place>? searchResults,
    Place? selectedPlace,
    Set<Marker>? markers,
    List<Minyan>? minyans,
    List<Place>? synagogues,
    Minyan? selectedMinyan,
    Place? selectedSynagogue,
    Set<Polyline>? polylines,
    String? selectedRouteMinyanId,
  }) {
    return HomeMapReady(
      userLocation: userLocation ?? this.userLocation,
      searchResults: searchResults ?? this.searchResults,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      markers: markers ?? this.markers,
      minyans: minyans ?? this.minyans,
      synagogues: synagogues ?? this.synagogues,
      selectedMinyan: selectedMinyan ?? this.selectedMinyan,
      selectedSynagogue: selectedSynagogue ?? this.selectedSynagogue,
      polylines: polylines ?? this.polylines,
      selectedRouteMinyanId: selectedRouteMinyanId ?? this.selectedRouteMinyanId,
    );
  }

  @override
  List<Object?> get props => [
        userLocation,
        searchResults,
        selectedPlace,
        markers,
        minyans,
        synagogues,
        selectedMinyan,
        selectedSynagogue,
        polylines,
        selectedRouteMinyanId,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LocationService _locationService;
  final PlaceRepository _placeRepository;
  final MinyanRepository _minyanRepository;

  HomeBloc({
    LocationService? locationService,
    required PlaceRepository placeRepository,
    required MinyanRepository minyanRepository,
  })  : _locationService = locationService ?? LocationService(),
        _placeRepository = placeRepository,
        _minyanRepository = minyanRepository,
        super(const HomeInitial()) {
    on<InitializeMapEvent>(_onInitializeMap);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<LoadJewishVenuesEvent>(_onLoadJewishVenues);
    on<LoadPrayerLocationsEvent>(_onLoadPrayerLocations);
    on<SelectPlaceEvent>(_onSelectPlace);
    on<SelectMarkerEvent>(_onSelectMarker);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<UpdateMapCameraEvent>(_onUpdateMapCamera);
    on<ClearSearchEvent>(_onClearSearch);
    on<RefreshNearbyMiniyansEvent>(_onRefreshNearbyMinyans);
    on<DrawRouteEvent>(_onDrawRoute);
    on<ClearRouteEvent>(_onClearRoute);
    on<ShowMinyanDetailsEvent>(_onShowMinyanDetails);
    on<ClearSelectedMinyanEvent>(_onClearSelectedMinyan);
  }

  Future<void> _onInitializeMap(
    InitializeMapEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      // Get current location with fallback and timeout
      UserLocation? userLocation;
      try {
        // Add a timeout at the BLoC level for extra safety
        userLocation = await _locationService.getCurrentLocation().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏱️ Location service timeout at BLoC level');
            return null;
          },
        );
        if (userLocation != null) {
          debugPrint('📍 Current location obtained: $userLocation');
        } else {
          debugPrint('⚠️ Location service returned null');
        }
      } catch (locationError) {
        debugPrint('⚠️ Location service error: $locationError');
        // Continue with null location - map will show default location
      }

      // Load saved places from repository with timeout
      List<Place> savedPlaces = [];
      try {
        savedPlaces = await _placeRepository.getSavedPlaces(limit: 50).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏱️ Place repository timeout');
            return [];
          },
        );
        debugPrint('📍 Loaded ${savedPlaces.length} saved places');
      } catch (placesError) {
        debugPrint('⚠️ Failed to load places: $placesError');
        // Continue with empty places list
      }

      // Create markers for saved places (using custom pinMap.svg violet markers)
      final synagogueMarkerIcon = await _createSynagogueMarker();
      final placeMarkers = savedPlaces.asMap().entries.map((entry) {
        final place = entry.value;
        return Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.placeType}\n${place.address}',
          ),
          icon: synagogueMarkerIcon,
          onTap: () {
            debugPrint('🛍️ Synagogue marker tapped: place_${place.id}');
            // Dispatch marker select event to BLoC
            add(SelectMarkerEvent(place.id, isMinyan: false));
            // Dispatch route drawing event
            if (state is HomeMapReady) {
              final currentState = state as HomeMapReady;
              // Use current location or fallback to NYC
              final originLocation = currentState.userLocation ?? 
                UserLocation(latitude: 40.7128, longitude: -74.0060, accuracy: 0, address: 'NYC');
              final userLocation = LatLng(
                originLocation.latitude,
                originLocation.longitude,
              );
              final synagogueLocation = LatLng(place.latitude, place.longitude);
              add(DrawRouteEvent(
                origin: userLocation,
                destination: synagogueLocation,
                minyanId: place.id,
              ));
            }
          },
        );
      }).toSet();

      // Load nearby minyans (with 100km radius)
      List<Minyan> nearbyMinyans = [];
      try {
        final userLocationForMinyans = userLocation ?? 
          UserLocation(latitude: 40.7128, longitude: -74.0060, accuracy: 0, address: 'Default Location');
        
        debugPrint('\n📍 [HomeBloc] Loading minyans from user location: (${userLocationForMinyans.latitude}, ${userLocationForMinyans.longitude})');
        
        nearbyMinyans = await _minyanRepository.getNearbyMinyans(
          latitude: userLocationForMinyans.latitude,
          longitude: userLocationForMinyans.longitude,
          radiusKm: 100.0, // 100km radius to show minyans from farther away
          limit: 50,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏱️ Minyan repository timeout');
            return [];
          },
        );
        debugPrint('🕯️ Loaded ${nearbyMinyans.length} nearby minyans for map display');
      } catch (minyansError) {
        debugPrint('⚠️ Failed to load minyans: $minyansError');
        // Continue with empty minyans list
      }

      // Create markers for minyans (using custom pinMap-styled blue markers)
      final minyanMarkerIcon = await _createMinyanMarker();
      final minyanMarkers = nearbyMinyans.map((minyan) {
        debugPrint('   🛍️ Creating marker for minyan: ${minyan.id} | ${minyan.locationName}');
        return Marker(
          markerId: MarkerId('minyan_${minyan.id}'),
          position: LatLng(minyan.latitude, minyan.longitude),
          infoWindow: InfoWindow(
            title: minyan.locationName,
            snippet: '${minyan.prayerType} at ${minyan.time}\nParticipants: ${minyan.participantCount}',
          ),
          icon: minyanMarkerIcon,
          onTap: () {
            debugPrint('🛍️ Minyan marker tapped: minyan_${minyan.id}');
            // Dispatch marker select event to BLoC
            add(SelectMarkerEvent(minyan.id, isMinyan: true));
            // Show minyan details sheet
            add(ShowMinyanDetailsEvent(minyan));
            // Dispatch route drawing event
            if (state is HomeMapReady) {
              final currentState = state as HomeMapReady;
              // Use current location or fallback to NYC
              final originLocation = currentState.userLocation ?? 
                UserLocation(latitude: 40.7128, longitude: -74.0060, accuracy: 0, address: 'NYC');
              final userLocation = LatLng(
                originLocation.latitude,
                originLocation.longitude,
              );
              final minyanLocation = LatLng(minyan.latitude, minyan.longitude);
              add(DrawRouteEvent(
                origin: userLocation,
                destination: minyanLocation,
                minyanId: minyan.id,
              ));
            }
          },
        );
      }).toSet();

      // Add current location marker
      final allMarkers = {...placeMarkers, ...minyanMarkers};
      final updatedMarkers = await _addCurrentLocationMarker(
        allMarkers,
        userLocation,
      );

      emit(HomeMapReady(
        userLocation: userLocation,
        markers: updatedMarkers,
        synagogues: savedPlaces,
        minyans: nearbyMinyans,
      ));
      debugPrint('✅ Map initialization complete with ${updatedMarkers.length} markers (${placeMarkers.length} synagogues, ${minyanMarkers.length} minyans)');
    } catch (e, stackTrace) {
      debugPrint('❌ Fatal map initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(HomeError('Failed to initialize map: ${e.toString()}'));
    }
  }

  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;

    try {
      final results = await _placeRepository.searchPlaces(
        query: event.query,
      );

      final newMarkers = _createMarkersFromPlaces(results);

      // Add current location marker if available
      final updatedMarkers = await _addCurrentLocationMarker(
        newMarkers,
        currentState.userLocation,
      );

      emit(currentState.copyWith(
        searchResults: results,
        markers: updatedMarkers,
      ));
    } catch (e) {
      emit(HomeError('Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoadJewishVenues(
    LoadJewishVenuesEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;

    try {
      final results = await _placeRepository.getSavedPlaces(limit: 50);

      final newMarkers = _createMarkersFromPlaces(results);

      // Add current location marker if available
      final updatedMarkers = await _addCurrentLocationMarker(
        newMarkers,
        currentState.userLocation,
      );

      emit(currentState.copyWith(
        searchResults: results,
        markers: updatedMarkers,
      ));
    } catch (e) {
      emit(HomeError('Failed to load Jewish venues: ${e.toString()}'));
    }
  }

  Future<void> _onSelectPlace(
    SelectPlaceEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;

    try {
      final updatedMarkers = await _updateMarkerForPlace(
        currentState.markers,
        event.place,
        currentState.userLocation,
      );

      emit(currentState.copyWith(
        selectedPlace: event.place,
        markers: updatedMarkers,
      ));
    } catch (e) {
      emit(HomeError('Failed to select place: ${e.toString()}'));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    try {
      final userLocation = await _locationService.getCurrentLocation();
      if (userLocation != null) {
        final currentState = state as HomeMapReady;
        final updatedMarkers = await _addCurrentLocationMarker(
          currentState.markers,
          userLocation,
        );

        emit(currentState.copyWith(
          userLocation: userLocation,
          markers: updatedMarkers,
        ));
      }
    } catch (e) {
      emit(HomeError('Failed to get location: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateMapCamera(
    UpdateMapCameraEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;
    // Camera update is typically handled by GoogleMapController
    // This event is here for future extensibility
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;
    final markers = await _addCurrentLocationMarker(
      {},
      currentState.userLocation,
    );

    emit(currentState.copyWith(
      searchResults: [],
      selectedPlace: null,
      markers: markers,
    ));
  }

  Set<Marker> _createMarkersFromPlaces(List<Place> places) {
    return places.asMap().entries.map((entry) {
      final place = entry.value;

      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();
  }

  Future<BitmapDescriptor> _createCustomLocationMarker() async {
    // Use location.svg for current location marker
    return await MarkerBuilder.createCurrentLocationMarker();
  }

  Future<BitmapDescriptor> _createMinyanMarker() async {
    // Use the custom pinMap.svg marker for minyan locations (blue variant)
    return await MarkerBuilder.createMinyanMarker();
  }

  Future<BitmapDescriptor> _createSynagogueMarker() async {
    // Use the custom pinMap.svg marker for synagogue locations (same as minyan marker)
    return await MarkerBuilder.createMinyanMarker();
  }

  Future<Set<Marker>> _addCurrentLocationMarker(
    Set<Marker> markers,
    UserLocation? userLocation,
  ) async {
    // Use fallback location if userLocation is null
    final locationForMarker = userLocation ?? 
      UserLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 0,
        address: 'Default Location (New York)',
      );

    final updatedMarkers = Set<Marker>.from(markers);
    updatedMarkers.removeWhere(
      (marker) => marker.markerId.value == 'current_location',
    );

    // Create custom marker
    final customIcon = await _createCustomLocationMarker();

    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(
          locationForMarker.latitude,
          locationForMarker.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: customIcon,
      ),
    );

    return updatedMarkers;
  }

  Future<Set<Marker>> _updateMarkerForPlace(
    Set<Marker> markers,
    Place place,
    UserLocation? userLocation,
  ) async {
    final updatedMarkers = _createMarkersFromPlaces([place]);
    return await _addCurrentLocationMarker(updatedMarkers, userLocation);
  }

  Future<void> _onLoadPrayerLocations(
    LoadPrayerLocationsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;

    try {
      // Load nearby saved places
      final savedPlaces = await _placeRepository.getSavedPlaces(limit: 50);

      // Create markers for places (using custom pinMap.svg violet markers)
      final synagogueMarkerIcon = await _createSynagogueMarker();
      final placeMarkers = savedPlaces.asMap().entries.map((entry) {
        final place = entry.value;
        return Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.placeType}\n${place.address}',
          ),
          icon: synagogueMarkerIcon,
          onTap: () {
            debugPrint('🛍️ Synagogue marker tapped: place_${place.id}');
            add(SelectMarkerEvent(place.id, isMinyan: false));
            // Dispatch route drawing event
            if (state is HomeMapReady) {
              final currentState = state as HomeMapReady;
              // Use current location or fallback to NYC
              final originLocation = currentState.userLocation ?? 
                UserLocation(latitude: 40.7128, longitude: -74.0060, accuracy: 0, address: 'NYC');
              final userLocation = LatLng(
                originLocation.latitude,
                originLocation.longitude,
              );
              final synagogueLocation = LatLng(place.latitude, place.longitude);
              add(DrawRouteEvent(
                origin: userLocation,
                destination: synagogueLocation,
                minyanId: place.id,
              ));
            }
          },
        );
      }).toSet();

      // Note: Minyanim would be loaded from MinyanBloc in a real scenario
      // For now, we're demonstrating the structure
      final updatedMarkers = await _addCurrentLocationMarker(
        placeMarkers,
        currentState.userLocation,
      );

      emit(currentState.copyWith(
        synagogues: savedPlaces,
        markers: updatedMarkers,
      ));
    } catch (e) {
      emit(HomeError('Failed to load prayer locations: ${e.toString()}'));
    }
  }

  /// Handle marker selection on map
  Future<void> _onSelectMarker(
    SelectMarkerEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;

    try {
      if (event.isMinyan) {
        // Handle minyan marker selection
        final minyan = currentState.minyans.firstWhere(
          (m) => m.id == event.markerId,
          orElse: () => throw Exception('Minyan not found'),
        );
        emit(currentState.copyWith(selectedMinyan: minyan));
      } else {
        // Handle synagogue marker selection
        final synagogue = currentState.synagogues.firstWhere(
          (s) => s.id == event.markerId,
          orElse: () => Place(
            id: '',
            name: '',
            address: '',
            latitude: 0,
            longitude: 0,
          ),
        );
        if (synagogue.id.isNotEmpty) {
          emit(currentState.copyWith(selectedSynagogue: synagogue));
        }
      }
    } catch (e) {
      emit(HomeError('Failed to select marker: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshNearbyMinyans(
    RefreshNearbyMiniyansEvent event,
    Emitter<HomeState> emit,
  ) async {
    debugPrint('\n🔄 [_onRefreshNearbyMinyans] EVENT RECEIVED - Checking state...');
    debugPrint('   Current state type: ${state.runtimeType}');
    debugPrint('   Event coordinates: lat=${event.latitude}, lon=${event.longitude}');
    
    if (state is! HomeMapReady) {
      debugPrint('   ❌ State is NOT HomeMapReady - ignoring refresh event');
      return;
    }

    final currentState = state as HomeMapReady;
    
    debugPrint('   ✅ State is HomeMapReady - proceeding with refresh');

    try {
      // Load nearby minyans (with 100km radius)
      List<Minyan> nearbyMinyans = [];
      try {
        // Use provided coordinates if available, otherwise use current user location
        double latForSearch = event.latitude ?? currentState.userLocation?.latitude ?? 40.7128;
        double lonForSearch = event.longitude ?? currentState.userLocation?.longitude ?? -74.0060;
        
        nearbyMinyans = await _minyanRepository.getNearbyMinyans(
          latitude: latForSearch,
          longitude: lonForSearch,
          radiusKm: 100.0,
          limit: 50,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏱️ Minyan repository timeout during refresh');
            return [];
          },
        );
        debugPrint('🕯️ Refreshed: Loaded ${nearbyMinyans.length} nearby minyans');
      } catch (minyansError) {
        debugPrint('⚠️ Failed to load minyans during refresh: $minyansError');
        rethrow;
      }

      // Create markers for minyans
      final minyanMarkerIcon = await _createMinyanMarker();
      final minyanMarkers = nearbyMinyans.map((minyan) {
        debugPrint('   🛍️ [REFRESH] Creating marker for minyan: ${minyan.id} | ${minyan.locationName}');
        return Marker(
          markerId: MarkerId('minyan_${minyan.id}'),
          position: LatLng(minyan.latitude, minyan.longitude),
          infoWindow: InfoWindow(
            title: minyan.locationName,
            snippet: '${minyan.prayerType} at ${minyan.time}\nParticipants: ${minyan.participantCount}',
          ),
          icon: minyanMarkerIcon,
          onTap: () {
            debugPrint('🛍️ Minyan marker tapped: minyan_${minyan.id}');
            // Dispatch marker select event to BLoC
            add(SelectMarkerEvent(minyan.id, isMinyan: true));
            // Show minyan details sheet
            add(ShowMinyanDetailsEvent(minyan));
            // Dispatch route drawing event
            if (state is HomeMapReady) {
              final currentState = state as HomeMapReady;
              // Use current location or fallback to NYC
              final originLocation = currentState.userLocation ?? 
                UserLocation(latitude: 40.7128, longitude: -74.0060, accuracy: 0, address: 'NYC');
              final userLocation = LatLng(
                originLocation.latitude,
                originLocation.longitude,
              );
              final minyanLocation = LatLng(minyan.latitude, minyan.longitude);
              add(DrawRouteEvent(
                origin: userLocation,
                destination: minyanLocation,
                minyanId: minyan.id,
              ));
            }
          },
        );
      }).toSet();
      debugPrint('   📍 Total minyan markers created during refresh: ${minyanMarkers.length}');

      // Combine with existing place markers (synagogues)
      final synagogueMarkerIcon = await _createSynagogueMarker();
      final placeMarkers = currentState.synagogues.asMap().entries.map((entry) {
        final place = entry.value;
        debugPrint('   🛍️ [REFRESH] Creating marker for place: ${place.id} | ${place.name}');
        return Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.placeType}\n${place.address}',
          ),
          icon: synagogueMarkerIcon,
          onTap: () {
            debugPrint('🛍️ Synagogue marker tapped: place_${place.id}');
            add(SelectMarkerEvent(place.id, isMinyan: false));
            // Dispatch route drawing event
            if (state is HomeMapReady) {
              final currentState = state as HomeMapReady;
              // Use current location or fallback to NYC
              final originLocation = currentState.userLocation ?? 
                UserLocation(latitude: 40.7128, longitude: -74.0060, accuracy: 0, address: 'NYC');
              final userLocation = LatLng(
                originLocation.latitude,
                originLocation.longitude,
              );
              final synagogueLocation = LatLng(place.latitude, place.longitude);
              add(DrawRouteEvent(
                origin: userLocation,
                destination: synagogueLocation,
                minyanId: place.id,
              ));
            }
          },
        );
      }).toSet();
      debugPrint('   📍 Total place markers created during refresh: ${placeMarkers.length}');

      final allMarkers = {...placeMarkers, ...minyanMarkers};
      debugPrint('   📊 All markers combined: ${allMarkers.length} (places + minyans)');
      final updatedMarkers = await _addCurrentLocationMarker(
        allMarkers,
        currentState.userLocation,
      );
      debugPrint('   🗺️ Final markers after adding current location: ${updatedMarkers.length}');

      debugPrint('\n📤 [REFRESH] Emitting new HomeMapReady state with ${updatedMarkers.length} markers');

      emit(currentState.copyWith(
        minyans: nearbyMinyans,
        markers: updatedMarkers,
      ));
      debugPrint('   ✅ State emitted! HomeMapReady should now rebuild with new markers');
      debugPrint('✅ Nearby minyans refresh complete');
    } catch (e) {
      debugPrint('❌ Error refreshing nearby minyans: $e');
      emit(HomeError('Failed to refresh nearby minyans: ${e.toString()}'));
    }
  }

  /// Handle drawing a route from user location to selected minyan
  Future<void> _onDrawRoute(
    DrawRouteEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (state is! HomeMapReady) {
        debugPrint('❌ DrawRouteEvent received but state is not HomeMapReady: ${state.runtimeType}');
        return;
      }
      final currentState = state as HomeMapReady;

      debugPrint('🛣️ DrawRouteEvent received: origin=${event.origin}, destination=${event.destination}');
      debugPrint('🛣️ Starting route calculation from ${event.origin} to ${event.destination}');
      
      // Use Google Directions API to get real routing
      final routingService = RoutingService();
      final routePoints = await routingService.getDirectionsRoute(
        origin: event.origin,
        destination: event.destination,
        travelMode: 'driving',
      );

      debugPrint('🔍 Route points from API: ${routePoints?.length ?? 0}');

      // If API fails, use fallback geodesic approximation
      final finalRoutePoints = routePoints ?? RoutingService.generateSimpleRoute(
        event.origin,
        event.destination,
        pointCount: 30,
      );

      debugPrint('🔍 Final route points (with fallback): ${finalRoutePoints.length}');

      // Create polyline for the route
      final routePolyline = RoutingService.createRoutePolyline(
        polylineId: 'route_${event.minyanId}',
        points: finalRoutePoints,
        color: const Color(0xFF4285F4), // Google Blue
        width: 5.0,
      );

      debugPrint('📄 Polyline created: ${routePolyline.polylineId}');

      // Update state with ONLY the new polyline (clear previous routes)
      emit(currentState.copyWith(
        polylines: {routePolyline},
        selectedRouteMinyanId: event.minyanId,
      ));

      debugPrint('✅ Route displayed with ${finalRoutePoints.length} points');
    } catch (e) {
      debugPrint('❌ Error drawing route: $e');
      debugPrint('📄 Stack trace: ${StackTrace.current}');
    }
  }

  /// Handle clearing the route from the map
  Future<void> _onClearRoute(
    ClearRouteEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (state is! HomeMapReady) return;
      final currentState = state as HomeMapReady;

      emit(currentState.copyWith(
        polylines: const {},
        selectedRouteMinyanId: null,
      ));

      debugPrint('✅ Route cleared from map');
    } catch (e) {
      debugPrint('❌ Error clearing route: $e');
    }
  }

  /// Handle showing minyan details in bottom sheet
  Future<void> _onShowMinyanDetails(
    ShowMinyanDetailsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // This event is handled by the UI layer (home_page.dart) via BlocListener
    // The BLoC just acknowledges receipt of the event for potential logging/tracking
    debugPrint('👀 ShowMinyanDetailsEvent received for minyan: ${event.minyan.id}');
  }

  /// Handle clearing the selected minyan
  Future<void> _onClearSelectedMinyan(
    ClearSelectedMinyanEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;
    final currentState = state as HomeMapReady;
    
    // Clear the selected minyan so tapping the same marker again will trigger selection
    emit(currentState.copyWith(selectedMinyan: null as Minyan?));
  }
}