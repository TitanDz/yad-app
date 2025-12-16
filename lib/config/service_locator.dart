import 'package:get_it/get_it.dart';
import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/core/local_storage/isar_service.dart';
import 'package:yad_app/core/services/app_initialization_service.dart';
import 'package:yad_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yad_app/features/auth/data/datasources/auth_unified_datasource.dart';
import 'package:yad_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/home/data/datasources/location_service.dart';
import 'package:yad_app/features/home/data/datasources/minyan_remote_datasource.dart';
import 'package:yad_app/features/home/data/datasources/minyan_unified_datasource.dart';
import 'package:yad_app/features/home/data/datasources/place_remote_datasource.dart';
import 'package:yad_app/features/home/data/datasources/place_unified_datasource.dart';
import 'package:yad_app/features/home/data/datasources/active_users_datasource.dart';
import 'package:yad_app/features/home/data/repositories/minyan_repository.dart';
import 'package:yad_app/features/home/data/repositories/place_repository.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/availability_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/user_status_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/active_users_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/prayer_timer_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_formation_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/location_voting_bloc.dart';
import 'package:yad_app/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:yad_app/shared/constants/app_constants.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Theme bloc - singleton for app-wide theme management
  getIt.registerSingleton<ThemeBloc>(
    ThemeBloc(),
  );
  getIt.registerSingleton<NetworkService>(
    NetworkService(baseUrl: AppConstants.baseUrl),
  );

  // Initialize Isar and app initialization service
  final isarService = IsarService();
  await isarService.initialize();
  getIt.registerSingleton<IsarService>(isarService);
  
  getIt.registerSingleton<AppInitializationService>(
    AppInitializationService(isarService),
  );

  // Auth datasources - using unified datasource that can switch between mock and real
  getIt.registerSingleton<AuthRemoteDataSource>(
    UnifiedAuthDataSource(networkService: getIt<NetworkService>()),
  );

  // Auth repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Auth bloc
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(repository: getIt<AuthRepository>()),
  );

  // Home datasources and repositories
  getIt.registerSingleton<MinyanRemoteDataSource>(
    UnifiedMinyanDataSource(networkService: getIt<NetworkService>()),
  );
  getIt.registerSingleton<MinyanRepository>(
    MinyanRepositoryImpl(getIt<MinyanRemoteDataSource>()),
  );

  getIt.registerSingleton<PlaceRemoteDataSource>(
    UnifiedPlaceDataSource(networkService: getIt<NetworkService>()),
  );
  getIt.registerSingleton<PlaceRepository>(
    PlaceRepositoryImpl(getIt<PlaceRemoteDataSource>()),
  );

  // Home services
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<PrayerCountdownService>(PrayerCountdownService());

  // Home blocs
  getIt.registerSingleton<HomeBloc>(
    HomeBloc(
      locationService: getIt<LocationService>(),
      placeRepository: getIt<PlaceRepository>(),
      minyanRepository: getIt<MinyanRepository>(),
    ),
  );

  getIt.registerSingleton<MinyanBloc>(
    MinyanBloc(minyanRepository: getIt<MinyanRepository>()),
  );

  // Availability bloc for 30-minute unavailable feature
  getIt.registerSingleton<AvailabilityBloc>(
    AvailabilityBloc(),
  );

  // User status bloc for tracking user online/offline/searching status
  getIt.registerSingleton<UserStatusBloc>(
    UserStatusBloc(),
  );

  // Active users bloc for detecting nearby users
  getIt.registerSingleton<ActiveUsersBloc>(
    ActiveUsersBloc(dataSource: MockActiveUsersDataSource()),
  );

  // Prayer timer bloc for 30-minute pre-prayer detection
  getIt.registerSingleton<PrayerTimerBloc>(
    PrayerTimerBloc(prayerCountdownService: getIt<PrayerCountdownService>()),
  );

  // Minyan formation bloc for automatic minyan creation
  getIt.registerSingleton<MinyanFormationBloc>(
    MinyanFormationBloc(),
  );

  // Location voting bloc for consensus-based location selection
  getIt.registerSingleton<LocationVotingBloc>(
    LocationVotingBloc(),
  );
}