import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/widgets/index.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/availability_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/active_users_bloc.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';
import 'package:go_router/go_router.dart';

/// Helper class for refined home screen UI components and methods
class HomeRefinements {
  /// Get user's first name from auth state
  static String getUserFirstName() {
    try {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;
      if (authState is AuthAuthenticated) return authState.user.firstName;
      if (authState is AuthLoginSuccess) return authState.user.firstName;
      if (authState is AuthRegistrationSuccess) return authState.user.firstName;
    } catch (e) {
      debugPrint('⚠️ Could not get user first name: $e');
    }
    return 'User';
  }

  /// Get time-aware greeting based on current hour
  static String getTimeAwareGreeting() {
    final hour = DateTime.now().hour;
    final firstName = getUserFirstName();
    
    if (hour >= 5 && hour < 12) {
      return 'Good Morning, $firstName';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon, $firstName';
    } else {
      return 'Good Evening, $firstName';
    }
  }

  /// Format Gregorian and Hebrew dates
  static String getFormattedDates() {
    try {
      final now = DateTime.now();
      final gregorianFormat = DateFormat('EEEE, MMMM d, y', 'en_US').format(now);
      final hebrewMonth = _getHebrewMonth(now.month);
      final hebrewDay = now.day;
      final hebrewYear = now.year + 3760;
      return '$gregorianFormat\n$hebrewDay $hebrewMonth $hebrewYear';
    } catch (e) {
      debugPrint('⚠️ Error formatting dates: $e');
      return DateFormat('EEEE, MMMM d, y', 'en_US').format(DateTime.now());
    }
  }

  /// Get Hebrew month name
  static String _getHebrewMonth(int month) {
    const months = [
      'Tevet', 'Shevat', 'Adar', 'Nisan', 'Iyar', 'Sivan',
      'Tammuz', 'Av', 'Elul', 'Tishrei', 'Cheshvan', 'Kislev',
    ];
    return months[month - 1];
  }

  /// Get next prayer details formatted
  static String getNextPrayerDetails(List<PrayerTimeInfo> prayerTimes) {
    try {
      if (prayerTimes.isEmpty) return 'Prayer times loading...';
      final now = DateTime.now();
      PrayerTimeInfo? nextPrayer;
      for (final prayer in prayerTimes) {
        if (prayer.startTime.isAfter(now)) {
          nextPrayer = prayer;
          break;
        }
      }
      nextPrayer ??= prayerTimes.isNotEmpty ? prayerTimes.first : null;
      if (nextPrayer == null) return 'No prayer times available';
      final prayerName = _getPrayerName(nextPrayer.name);
      final startTime = DateFormat('h:mm a').format(nextPrayer.startTime);
      final endTime = DateFormat('h:mm a').format(nextPrayer.endTime);
      return '$prayerName\nFrom $startTime to $endTime';
    } catch (e) {
      debugPrint('⚠️ Error getting prayer details: $e');
      return 'Prayer times unavailable';
    }
  }

  /// Get prayer name from type
  static String _getPrayerName(String? type) {
    if (type == null) return 'Prayer';
    switch (type.toLowerCase()) {
      case 'shacharit': return 'Shacharit';
      case 'mincha': return 'Mincha';
      case 'arvit':
      case 'maariv': return 'Arvit';
      default: return type;
    }
  }

  /// Build top section with greeting, location, and dates
  static Widget buildTopSection({
    required BuildContext context,
    required String cityCountry,
    required AvailabilityBloc availabilityBloc,
    required String userId,
  }) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Greeting + Settings & Buttons (Reorganized)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting text (left side, takes up space)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time-aware greeting
                    Text(
                      getTimeAwareGreeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings & Invitations buttons (right side, compact)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mail_outline,
                          color: Colors.white, size: 20),
                      onPressed: () => context.push('/invitations'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Invitations',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings,
                          color: Colors.white, size: 20),
                      onPressed: () => context.push('/settings'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Settings',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  cityCountry.isNotEmpty
                      ? 'You\'re in $cityCountry'
                      : 'Location loading...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dates (Gregorian & Hebrew)
          Text(
            getFormattedDates(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Availability Toggle - Positioned at bottom of header for better visual flow
          BlocProvider<AvailabilityBloc>.value(
            value: availabilityBloc,
            child: AvailabilityToggleWidget(
              userId: userId,
              onAvailabilityChanged: () {},
            ),
          ),
        ],
      ),
    );
  }

  /// Build prayer information section
  static Widget buildPrayerInformationSection({
    required BuildContext context,
    required List<PrayerTimeInfo> prayerTimes,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.schedule, color: AppTheme.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  getNextPrayerDetails(prayerTimes),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build reduced map section showing only active users
  static Widget buildReducedMapSection({
    required BuildContext context,
    required HomeBloc homeBloc,
    required Function(GoogleMapController) onMapCreated,
    required String Function() getDarkMapStyle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: homeBloc,
        buildWhen: (previous, current) {
          // Only rebuild when state actually changes to prevent semantic issues
          return previous.runtimeType != current.runtimeType ||
              (previous is HomeMapReady &&
                  current is HomeMapReady &&
                  previous.markers.length != current.markers.length);
        },
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
            
            // Filter: only active users (no minyan/selected markers)
            final activeUserMarkers = state.markers
                .where((marker) =>
                    !marker.markerId.value.contains('minyan') &&
                    !marker.markerId.value.contains('selected'))
                .toSet();

            return GoogleMap(
              key: ValueKey('map_reduced_${activeUserMarkers.length}'),
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 15.0,
              ),
              markers: activeUserMarkers,
              polylines: const <Polyline>{},
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              style: Theme.of(context).brightness == Brightness.dark
                  ? getDarkMapStyle()
                  : null,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Build the complete refined home layout
  static Widget buildRefinedHomeLayout({
    required BuildContext context,
    required String cityCountry,
    required List<PrayerTimeInfo> prayerTimes,
    required AvailabilityBloc availabilityBloc,
    required String userId,
    required HomeBloc homeBloc,
    required Function(GoogleMapController) onMapCreated,
    required String Function() getDarkMapStyle,
  }) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Top header section (non-scrollable, fixed)
          buildTopSection(
            context: context,
            cityCountry: cityCountry,
            availabilityBloc: availabilityBloc,
            userId: userId,
          ),
          // Map positioned prominently below header (fixed height, visible immediately)
          SizedBox(
            height: 220,
            child: buildReducedMapSection(
              context: context,
              homeBloc: homeBloc,
              onMapCreated: onMapCreated,
              getDarkMapStyle: getDarkMapStyle,
            ),
          ),
          // Prayer info and scrollable content below map
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildPrayerInformationSection(
                    context: context,
                    prayerTimes: prayerTimes,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
