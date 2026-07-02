import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/coach_remote_datasource.dart';
import '../../data/datasources/feedback_remote_datasource.dart';
import '../../data/datasources/home_favorite_provider_remote_datasource.dart';
import '../../data/datasources/home_provider_assets_remote_datasource.dart';
import '../../data/datasources/home_provider_service_area_remote_datasource.dart';
import '../../data/datasources/home_provider_services_remote_datasource.dart';
import '../../data/datasources/home_service_availability_remote_datasource.dart';
import '../../data/datasources/home_service_booking_remote_datasource.dart';
import '../../data/datasources/home_service_profile_remote_datasource.dart';
import '../../data/datasources/home_service_remote_datasource.dart';
import '../../data/datasources/home_service_type_remote_datasource.dart';
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
import '../../data/repositories/coach_repository_impl.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../data/repositories/home_favorite_provider_repository_impl.dart';
import '../../data/repositories/home_provider_assets_repository_impl.dart';
import '../../data/repositories/home_provider_service_area_repository_impl.dart';
import '../../data/repositories/home_provider_services_repository_impl.dart';
import '../../data/repositories/home_service_availability_repository_impl.dart';
import '../../data/repositories/home_service_booking_repository_impl.dart';
import '../../data/repositories/home_service_profile_repository_impl.dart';
import '../../data/repositories/home_service_provider_repository_impl.dart';
import '../../data/repositories/home_service_type_repository_impl.dart';
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
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../../domain/repositories/home_favorite_provider_repository.dart';
import '../../domain/repositories/home_provider_assets_repository.dart';
import '../../domain/repositories/home_provider_service_area_repository.dart';
import '../../domain/repositories/home_provider_services_repository.dart';
import '../../domain/repositories/home_service_availability_repository.dart';
import '../../domain/repositories/home_service_booking_repository.dart';
import '../../domain/repositories/home_service_profile_repository.dart';
import '../../domain/repositories/home_service_provider_repository.dart';
import '../../domain/repositories/home_service_type_repository.dart';
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
import '../../presentation/bloc/coach/coach_cubit.dart';
import '../../presentation/bloc/feedback/feedback_cubit.dart';
import '../../presentation/bloc/home_provider_booking/home_provider_booking_cubit.dart';
import '../../presentation/bloc/home_provider_services/home_provider_services_cubit.dart';
import '../../presentation/bloc/home_service/home_service_cubit.dart';
import '../../presentation/bloc/home_service_availability/home_service_availability_cubit.dart';
import '../../presentation/bloc/home_service_booking/home_service_booking_cubit.dart';
import '../../presentation/bloc/my_home_service_bookings/my_home_service_bookings_cubit.dart';
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

  // Home service listing (search, detail)
  sl.registerLazySingleton<HomeServiceRemoteDataSource>(
    () => HomeServiceRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeServiceProviderRepository>(
    () => HomeServiceProviderRepositoryImpl(sl<HomeServiceRemoteDataSource>()),
  );

  // Home service profile (become/apply/update)
  sl.registerLazySingleton<HomeServiceProfileRemoteDataSource>(
    () => HomeServiceProfileRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeServiceProfileRepository>(
    () => HomeServiceProfileRepositoryImpl(
      sl<HomeServiceProfileRemoteDataSource>(),
    ),
  );

  // Home service type catalog
  sl.registerLazySingleton<HomeServiceTypeRemoteDataSource>(
    () => HomeServiceTypeRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeServiceTypeRepository>(
    () => HomeServiceTypeRepositoryImpl(sl<HomeServiceTypeRemoteDataSource>()),
  );

  // Home provider offered services
  sl.registerLazySingleton<HomeProviderServicesRemoteDataSource>(
    () => HomeProviderServicesRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeProviderServicesRepository>(
    () => HomeProviderServicesRepositoryImpl(
      sl<HomeProviderServicesRemoteDataSource>(),
    ),
  );

  // Home provider assets (gallery, documents, certifications, specialties)
  sl.registerLazySingleton<HomeProviderAssetsRemoteDataSource>(
    () => HomeProviderAssetsRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeProviderAssetsRepository>(
    () => HomeProviderAssetsRepositoryImpl(
      sl<HomeProviderAssetsRemoteDataSource>(),
    ),
  );

  // Home provider service areas
  sl.registerLazySingleton<HomeProviderServiceAreaRemoteDataSource>(
    () => HomeProviderServiceAreaRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeProviderServiceAreaRepository>(
    () => HomeProviderServiceAreaRepositoryImpl(
      sl<HomeProviderServiceAreaRemoteDataSource>(),
    ),
  );

  // Home service availability
  sl.registerLazySingleton<HomeServiceAvailabilityRemoteDataSource>(
    () => HomeServiceAvailabilityRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeServiceAvailabilityRepository>(
    () => HomeServiceAvailabilityRepositoryImpl(
      sl<HomeServiceAvailabilityRemoteDataSource>(),
    ),
  );

  // Home service booking
  sl.registerLazySingleton<HomeServiceBookingRemoteDataSource>(
    () => HomeServiceBookingRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeServiceBookingRepository>(
    () => HomeServiceBookingRepositoryImpl(
      sl<HomeServiceBookingRemoteDataSource>(),
    ),
  );

  // Home service favorites
  sl.registerLazySingleton<HomeFavoriteProviderRemoteDataSource>(
    () => HomeFavoriteProviderRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HomeFavoriteProviderRepository>(
    () => HomeFavoriteProviderRepositoryImpl(
      sl<HomeFavoriteProviderRemoteDataSource>(),
    ),
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
      notificationRepository: sl<NotificationRepository>(),
      homeServiceProfileRepository: sl<HomeServiceProfileRepository>(),
    ),
  );
  sl.registerFactory<WalkerCubit>(() => WalkerCubit(sl<WalkerRepository>()));
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
  sl.registerFactory<HomeServiceAvailabilityCubit>(
    () => HomeServiceAvailabilityCubit(sl<HomeServiceAvailabilityRepository>()),
  );
  sl.registerFactory<HomeProviderServicesCubit>(
    () => HomeProviderServicesCubit(
      sl<HomeProviderServicesRepository>(),
      sl<HomeServiceTypeRepository>(),
    ),
  );
  sl.registerFactory<HomeProviderBookingCubit>(
    () => HomeProviderBookingCubit(sl<HomeServiceBookingRepository>()),
  );
  sl.registerFactory<HomeServiceCubit>(
    () => HomeServiceCubit(sl<HomeServiceProviderRepository>()),
  );
  sl.registerFactory<HomeServiceBookingCubit>(
    () => HomeServiceBookingCubit(
      sl<HomeServiceBookingRepository>(),
      sl<HomeServiceProviderRepository>(),
      sl<PetRepository>(),
    ),
  );
  sl.registerFactory<MyHomeServiceBookingsCubit>(
    () => MyHomeServiceBookingsCubit(sl<HomeServiceBookingRepository>()),
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
