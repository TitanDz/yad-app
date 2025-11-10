import 'package:get_it/get_it.dart';
import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yad_app/features/auth/data/datasources/auth_unified_datasource.dart';
import 'package:yad_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/home/data/datasources/location_service.dart';
import 'package:yad_app/features/home/data/datasources/minyan_remote_datasource.dart';
import 'package:yad_app/features/home/data/datasources/minyan_unified_datasource.dart';
import 'package:yad_app/features/home/data/datasources/place_remote_datasource.dart';
import 'package:yad_app/features/home/data/datasources/place_unified_datasource.dart';
import 'package:yad_app/features/home/data/repositories/minyan_repository.dart';
import 'package:yad_app/features/home/data/repositories/place_repository.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';
import 'package:yad_app/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:yad_app/shared/constants/app_constants.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Theme bloc - singleton for app-wide theme management
  getIt.registerSingleton<ThemeBloc>(
    ThemeBloc(),
  );

  // Core services
  getIt.registerSingleton<NetworkService>(
    NetworkService(baseUrl: AppConstants.baseUrl),
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

  // Home blocs
  getIt.registerSingleton<HomeBloc>(
    HomeBloc(
      locationService: getIt<LocationService>(),
      placeRepository: getIt<PlaceRepository>(),
    ),
  );

  getIt.registerSingleton<MinyanBloc>(
    MinyanBloc(minyanRepository: getIt<MinyanRepository>()),
  );
}