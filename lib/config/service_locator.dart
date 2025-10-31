import 'package:get_it/get_it.dart';
import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yad_app/features/auth/data/datasources/auth_unified_datasource.dart';
import 'package:yad_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/home/data/datasources/location_service.dart';
import 'package:yad_app/features/home/data/datasources/places_service.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/shared/constants/app_constants.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
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

  // Home services
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<PlacesService>(PlacesService());

  // Home bloc
  getIt.registerSingleton<HomeBloc>(
    HomeBloc(
      locationService: getIt<LocationService>(),
      placesService: getIt<PlacesService>(),
    ),
  );
}