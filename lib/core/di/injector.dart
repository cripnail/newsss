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
import 'package:newsss/features/news/data/datasources/news_local_data_source.dart';
import 'package:newsss/features/news/data/datasources/news_remote_data_source.dart';
import 'package:newsss/features/news/domain/repositories/news_repository.dart';
import 'package:newsss/features/news/data/repositories/news_repository_impl.dart';
import 'package:newsss/features/news/presentation/bloc/news_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());

  final dir = await getApplicationDocumentsDirectory();
  final isar = await IsarService.openDB(dir.path);
  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton(() => IsarService(sl()));

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  sl.registerFactory(() => AuthCubit(sl()));

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(isar: sl()),
  );

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerFactory(() => NewsBloc(newsRepository: sl()));
}
