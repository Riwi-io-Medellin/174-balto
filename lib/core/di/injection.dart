import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/business_remote_datasource.dart';
import '../../data/datasources/coach_remote_datasource.dart';
import '../../data/datasources/feedback_remote_datasource.dart';
import '../../data/datasources/me_remote_datasource.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/datasources/pet_remote_datasource.dart';
import '../../data/datasources/upload_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/datasources/walk_booking_remote_datasource.dart';
import '../../data/datasources/walk_session_remote_datasource.dart';
import '../../data/datasources/walker_availability_remote_datasource.dart';
import '../../data/datasources/walker_profile_remote_datasource.dart';
import '../../data/datasources/walker_remote_datasource.dart';
import '../../data/datasources/walking_history_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/business_repository_impl.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../data/repositories/me_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../data/repositories/upload_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/walk_booking_repository_impl.dart';
import '../../data/repositories/walk_session_repository_impl.dart';
import '../../data/repositories/walker_availability_repository_impl.dart';
import '../../data/repositories/walker_profile_repository_impl.dart';
import '../../data/repositories/walker_repository_impl.dart';
import '../../data/repositories/walking_history_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/business_repository.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../../domain/repositories/me_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/pet_repository.dart';
import '../../domain/repositories/upload_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/walk_booking_repository.dart';
import '../../domain/repositories/walk_session_repository.dart';
import '../../domain/repositories/walker_availability_repository.dart';
import '../../domain/repositories/walker_profile_repository.dart';
import '../../domain/repositories/walker_repository.dart';
import '../../domain/repositories/walking_history_repository.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/bloc/business/business_cubit.dart';
import '../../presentation/bloc/coach/coach_cubit.dart';
import '../../presentation/bloc/feedback/feedback_cubit.dart';
import '../../presentation/bloc/my_walks/my_walks_cubit.dart';
import '../../presentation/bloc/profile/profile_cubit.dart';
import '../../presentation/bloc/walk_booking/walk_booking_cubit.dart';
import '../../presentation/bloc/walker/walker_cubit.dart';
import '../../presentation/bloc/walker_availability/walker_availability_cubit.dart';
import '../../presentation/bloc/walker_booking/walker_booking_cubit.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<TokenStorage>()));

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // User
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserRemoteDataSource>()),
  );

  // Pet
  sl.registerLazySingleton<PetRemoteDataSource>(
    () => PetRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(sl<PetRemoteDataSource>()),
  );

  // Walking history
  sl.registerLazySingleton<WalkingHistoryRemoteDataSource>(
    () => WalkingHistoryRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkingHistoryRepository>(
    () => WalkingHistoryRepositoryImpl(sl<WalkingHistoryRemoteDataSource>()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>()),
  );

  // Upload
  sl.registerLazySingleton<UploadRemoteDataSource>(
    () => UploadRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(sl<UploadRemoteDataSource>()),
  );

  // Me
  sl.registerLazySingleton<MeRemoteDataSource>(
    () => MeRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<MeRepository>(
    () => MeRepositoryImpl(sl<MeRemoteDataSource>()),
  );

  // Feedback
  sl.registerLazySingleton<FeedbackRemoteDataSource>(
    () => FeedbackRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<FeedbackRepository>(
    () => FeedbackRepositoryImpl(sl<FeedbackRemoteDataSource>()),
  );

  // Walker profile (apply, update profile)
  sl.registerLazySingleton<WalkerProfileRemoteDataSource>(
    () => WalkerProfileRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkerProfileRepository>(
    () => WalkerProfileRepositoryImpl(sl<WalkerProfileRemoteDataSource>()),
  );

  // Walker listing (search, detail)
  sl.registerLazySingleton<WalkerRemoteDataSource>(
    () => WalkerRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkerRepository>(
    () => WalkerRepositoryImpl(sl<WalkerRemoteDataSource>()),
  );

  // Business listing (search, detail, hours, apply)
  sl.registerLazySingleton<BusinessRemoteDataSource>(
    () => BusinessRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(
      sl<BusinessRemoteDataSource>(),
      sl<UploadRepository>(),
    ),
  );

  // Walker availability
  sl.registerLazySingleton<WalkerAvailabilityRemoteDataSource>(
    () => WalkerAvailabilityRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkerAvailabilityRepository>(
    () =>
        WalkerAvailabilityRepositoryImpl(sl<WalkerAvailabilityRemoteDataSource>()),
  );

  // Walk booking
  sl.registerLazySingleton<WalkBookingRemoteDataSource>(
    () => WalkBookingRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkBookingRepository>(
    () => WalkBookingRepositoryImpl(sl<WalkBookingRemoteDataSource>()),
  );

  // Walk session
  sl.registerLazySingleton<WalkSessionRemoteDataSource>(
    () => WalkSessionRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<WalkSessionRepository>(
    () => WalkSessionRepositoryImpl(sl<WalkSessionRemoteDataSource>()),
  );

  // Cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      userRepository: sl<UserRepository>(),
      tokenStorage: sl<TokenStorage>(),
      petRepository: sl<PetRepository>(),
      walkBookingRepository: sl<WalkBookingRepository>(),
      walkerProfileRepository: sl<WalkerProfileRepository>(),
      businessRepository: sl<BusinessRepository>(),
      notificationRepository: sl<NotificationRepository>(),
    ),
  );
  sl.registerFactory<WalkerCubit>(() => WalkerCubit(sl<WalkerRepository>()));
  sl.registerFactory<BusinessCubit>(
    () => BusinessCubit(sl<BusinessRepository>()),
  );
  sl.registerFactory<WalkBookingCubit>(
    () => WalkBookingCubit(
      sl<WalkBookingRepository>(),
      sl<WalkerRepository>(),
      sl<PetRepository>(),
      sl<UserRepository>(),
      sl<TokenStorage>(),
    ),
  );
  sl.registerFactory<WalkerAvailabilityCubit>(
    () => WalkerAvailabilityCubit(sl<WalkerAvailabilityRepository>()),
  );
  sl.registerFactory<WalkerBookingCubit>(
    () => WalkerBookingCubit(sl<WalkBookingRepository>()),
  );
  sl.registerFactory<MyWalksCubit>(
    () => MyWalksCubit(sl<WalkBookingRepository>()),
  );

  // Coach
  sl.registerLazySingleton<CoachRemoteDataSource>(
    () => CoachRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<CoachRepository>(
    () => CoachRepositoryImpl(sl<CoachRemoteDataSource>()),
  );
  sl.registerFactory<CoachCubit>(
    () => CoachCubit(sl<CoachRepository>(), sl<FlutterSecureStorage>()),
  );

  // Feedback
  sl.registerFactory<FeedbackCubit>(
    () => FeedbackCubit(sl<FeedbackRepository>()),
  );
}
