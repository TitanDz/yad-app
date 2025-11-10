import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/features/home/data/datasources/location_service.dart';
import 'package:yad_app/features/home/data/repositories/place_repository.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';
import 'package:yad_app/features/home/domain/entities/user_location.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

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

  const HomeMapReady({
    this.userLocation,
    this.searchResults = const [],
    this.selectedPlace,
    this.markers = const {},
    this.minyans = const [],
    this.synagogues = const [],
    this.selectedMinyan,
    this.selectedSynagogue,
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

  HomeBloc({
    LocationService? locationService,
    required PlaceRepository placeRepository,
  })  : _locationService = locationService ?? LocationService(),
        _placeRepository = placeRepository,
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
  }

  Future<void> _onInitializeMap(
    InitializeMapEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final userLocation = await _locationService.getCurrentLocation();

      // Load saved places from repository
      final savedPlaces = await _placeRepository.getSavedPlaces(limit: 50);

      // Create markers for saved places (using violet color)
      final placeMarkers = savedPlaces.asMap().entries.map((entry) {
        final place = entry.value;
        return Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.placeType}\n${place.address}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        );
      }).toSet();

      // Add current location marker
      final updatedMarkers = _addCurrentLocationMarker(
        placeMarkers,
        userLocation,
      );

      emit(HomeMapReady(
        userLocation: userLocation,
        markers: updatedMarkers,
        synagogues: savedPlaces,
      ));
    } catch (e) {
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
      final updatedMarkers = _addCurrentLocationMarker(
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
      final updatedMarkers = _addCurrentLocationMarker(
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
      final updatedMarkers = _updateMarkerForPlace(
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
        final updatedMarkers = _addCurrentLocationMarker(
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
    final markers = _addCurrentLocationMarker(
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

  Set<Marker> _addCurrentLocationMarker(
    Set<Marker> markers,
    UserLocation? userLocation,
  ) {
    if (userLocation == null) return markers;

    final updatedMarkers = Set<Marker>.from(markers);
    updatedMarkers.removeWhere(
      (marker) => marker.markerId.value == 'current_location',
    );

    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(
          userLocation.latitude,
          userLocation.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      ),
    );

    return updatedMarkers;
  }

  Set<Marker> _updateMarkerForPlace(
    Set<Marker> markers,
    Place place,
    UserLocation? userLocation,
  ) {
    final updatedMarkers = _createMarkersFromPlaces([place]);
    return _addCurrentLocationMarker(updatedMarkers, userLocation);
  }

  /// Load both minyanim and synagogues on the map
  Future<void> _onLoadPrayerLocations(
    LoadPrayerLocationsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeMapReady) return;

    final currentState = state as HomeMapReady;

    try {
      // Load nearby saved places
      final savedPlaces = await _placeRepository.getSavedPlaces(limit: 50);

      // Create markers for places (using purple pins)
      final placeMarkers = savedPlaces.asMap().entries.map((entry) {
        final place = entry.value;
        return Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.placeType}\n${place.address}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        );
      }).toSet();

      // Note: Minyanim would be loaded from MinyanBloc in a real scenario
      // For now, we're demonstrating the structure
      final updatedMarkers = _addCurrentLocationMarker(
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
        // This would typically update the selected minyan
        emit(currentState); // Placeholder for minyan selection logic
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
}
