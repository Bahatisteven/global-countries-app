import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/countries/data/datasources/country_remote_datasource.dart';
import '../../features/countries/data/repositories/country_repository_impl.dart';
import '../../features/countries/domain/repositories/country_repository.dart';
import '../../features/countries/domain/usecases/get_all_countries.dart';
import '../../features/countries/domain/usecases/get_country_details.dart';
import '../../features/countries/domain/usecases/search_countries.dart';
import '../../features/countries/presentation/blocs/country_detail/country_detail_bloc.dart';
import '../../features/countries/presentation/blocs/country_list/country_list_bloc.dart';
import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/add_favorite.dart';
import '../../features/favorites/domain/usecases/get_favorites.dart';
import '../../features/favorites/domain/usecases/is_favorite.dart';
import '../../features/favorites/domain/usecases/remove_favorite.dart';
import '../../features/favorites/presentation/blocs/favorites_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Countries
  // Blocs
  sl.registerLazySingleton(
    () => CountryListBloc(
      getAllCountries: sl(),
      searchCountries: sl(),
    ),
  );

  sl.registerFactory(
    () => CountryDetailBloc(
      getCountryDetails: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllCountries(sl()));
  sl.registerLazySingleton(() => SearchCountries(sl()));
  sl.registerLazySingleton(() => GetCountryDetails(sl()));

  // Repository
  sl.registerLazySingleton<CountryRepository>(
    () => CountryRepositoryImpl(remoteDatasource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CountryRemoteDatasource>(
    () => CountryRemoteDatasourceImpl(dio: sl()),
  );

  //! Features - Favorites
  // Blocs
  sl.registerLazySingleton(
    () => FavoritesBloc(
      getFavorites: sl(),
      addFavorite: sl(),
      removeFavorite: sl(),
      isFavorite: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));

  // Repository
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDatasource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FavoritesLocalDatasource>(
    () => FavoritesLocalDatasourceImpl(),
  );

  //! Core
  await _initHive();
  sl.registerLazySingleton(() => _createDio());
}

Future<void> _initHive() async {
  await Hive.openBox('favorites');
}

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://restcountries.com/v3.1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(null),
        policy: CachePolicy.request,
        maxStale: const Duration(days: 7),
        priority: CachePriority.high,
        hitCacheOnErrorExcept: [401, 403],
      ),
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: false,
      error: true,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  return dio;
}
