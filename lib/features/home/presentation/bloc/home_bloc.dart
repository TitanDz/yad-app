import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/features/home/data/datasources/location_service.dart';
import 'package:yad_app/features/home/data/datasources/places_service.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';
import 'package:yad_app/features/home/domain/entities/user_location.dart';

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

  const SearchPlacesEvent(this.query);

  @override
  List<Object?> get props => [query];
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

class ClearSearchEvent extends HomeEvent {
  const ClearSearchEvent();
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

  const HomeMapReady({
    this.userLocation,
    this.searchResults = const [],
    this.selectedPlace,
    this.markers = const {},
  });

  HomeMapReady copyWith({
    UserLocation? userLocation,
    List<Place>? searchResults,
    Place? selectedPlace,
    Set<Marker>? markers,
  }) {
    return HomeMapReady(
      userLocation: userLocation ?? this.userLocation,
      searchResults: searchResults ?? this.searchResults,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      markers: markers ?? this.markers,
    );
  }

  @override
  List<Object?> get props =>
      [userLocation, searchResults, selectedPlace, markers];
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
  final PlacesService _placesService;

  HomeBloc({
    LocationService? locationService,
    PlacesService? placesService,
  })  : _locationService = locationService ?? LocationService(),
        _placesService = placesService ?? PlacesService(),
        super(const HomeInitial()) {
    on<InitializeMapEvent>(_onInitializeMap);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<SelectPlaceEvent>(_onSelectPlace);
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

      emit(HomeMapReady(
        userLocation: userLocation,
        markers: userLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(
                    userLocation.latitude,
                    userLocation.longitude,
                  ),
                  infoWindow: const InfoWindow(title: 'Your Location'),
                ),
              }
            : {},
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
      final results = await _placesService.searchPlaces(
        event.query,
        latitude: currentState.userLocation?.latitude,
        longitude: currentState.userLocation?.longitude,
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
}
