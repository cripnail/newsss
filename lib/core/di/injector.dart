import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:newsss/core/database/isar_service.dart';
import 'package:newsss/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:newsss/features/auth/domain/repositories/auth_repository.dart';
import 'package:newsss/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:newsss/features/auth/presentation/cubit/auth_cubit.dart';

// News Feature Imports
import 'package:newsss/features/news/data/datasources/news_local_data_source.dart';
import 'package:newsss/features/news/data/datasources/news_remote_data_source.dart';
import 'package:newsss/features/news/domain/repositories/news_repository.dart';
import 'package:newsss/features/news/data/repositories/news_repository_impl.dart';
// Import News BLoC
import 'package:newsss/features/news/presentation/bloc/news_bloc.dart';

// Global service locator instance
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --- Core ---

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());

  final dir = await getApplicationDocumentsDirectory();
  final isar = await IsarService.openDB(dir.path);
  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton(() => IsarService(sl()));

  // --- Features ---

  // ================= Auth Feature Dependencies =================
  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  // Blocs / Cubits
  // Factory - каждый раз новый экземпляр при запросе
  sl.registerFactory(() => AuthCubit(sl()));

  // ================= News Feature Dependencies =================
  // Data sources
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    // Isar instance is already registered as a singleton
    () => NewsLocalDataSourceImpl(isar: sl()), 
  );

  // Repositories
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      // networkInfo: sl(), // Add if NetworkInfo is implemented
    ),
  );

  // Blocs / Cubits
  // Factory - создаем новый экземпляр каждый раз, когда он запрашивается
  sl.registerFactory(() => NewsBloc(newsRepository: sl()));
} 