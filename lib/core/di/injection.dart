import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/pet_remote_datasource.dart';
import '../../data/datasources/upload_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/datasources/walking_history_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../data/repositories/upload_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/walking_history_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/pet_repository.dart';
import '../../domain/repositories/upload_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/walking_history_repository.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/bloc/profile/profile_cubit.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<TokenStorage>()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton<PetRemoteDataSource>(
    () => PetRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(sl<PetRemoteDataSource>()),
  );
  sl.registerLazySingleton<WalkingHistoryRemoteDataSource>(
    () => WalkingHistoryRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkingHistoryRepository>(
    () => WalkingHistoryRepositoryImpl(sl<WalkingHistoryRemoteDataSource>()),
  );
  sl.registerLazySingleton<UploadRemoteDataSource>(
    () => UploadRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(sl<UploadRemoteDataSource>()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      userRepository: sl<UserRepository>(),
      tokenStorage: sl<TokenStorage>(),
      petRepository: sl<PetRepository>(),
      walkingHistoryRepository: sl<WalkingHistoryRepository>(),
    ),
  );
}
