import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/home_service_type.dart';
import '../../../domain/repositories/home_provider_services_repository.dart';
import '../../../domain/repositories/home_service_type_repository.dart';
import 'home_provider_services_state.dart';

class HomeProviderServicesCubit extends Cubit<HomeProviderServicesState> {
  HomeProviderServicesCubit(this._repository, this._typeRepository)
    : super(const HomeProviderServicesInitial());

  final HomeProviderServicesRepository _repository;
  final HomeServiceTypeRepository _typeRepository;

  String? _providerId;
  List<HomeServiceType> _cachedTypes = const [];

  Future<void> load(String providerId) async {
    _providerId = providerId;
    emit(const HomeProviderServicesLoading());
    try {
      final results = await Future.wait([
        _repository.getByProviderId(providerId),
        _typeRepository.getTypes(),
      ]);
      final services = results[0] as List<HomeProviderServiceItem>;
      final types = results[1] as List<HomeServiceType>;
      _cachedTypes = types;
      emit(
        HomeProviderServicesLoaded(services: services, availableTypes: types),
      );
    } on HomeProviderServicesFailure catch (e) {
      emit(HomeProviderServicesError(e.code, e.message));
    } catch (e) {
      emit(HomeProviderServicesError('UNKNOWN', e.toString()));
    }
  }

  Future<void> addService({
    required String serviceTypeId,
    double? price,
    required String priceUnit,
    String? description,
  }) async {
    try {
      await _repository.addMyService(
        serviceTypeId: serviceTypeId,
        price: price,
        priceUnit: priceUnit,
        description: description,
      );
      if (_providerId != null) await load(_providerId!);
    } on HomeProviderServicesFailure catch (e) {
      emit(HomeProviderServicesError(e.code, e.message));
    } catch (e) {
      emit(HomeProviderServicesError('UNKNOWN', e.toString()));
    }
  }

  Future<void> updateService({
    required String serviceId,
    double? price,
    required String priceUnit,
    String? description,
    required bool isActive,
  }) async {
    try {
      await _repository.updateMyService(
        serviceId: serviceId,
        price: price,
        priceUnit: priceUnit,
        description: description,
        isActive: isActive,
      );
      if (_providerId != null) await load(_providerId!);
    } on HomeProviderServicesFailure catch (e) {
      emit(HomeProviderServicesError(e.code, e.message));
    } catch (e) {
      emit(HomeProviderServicesError('UNKNOWN', e.toString()));
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _repository.deleteMyService(serviceId);
      if (_providerId != null) await load(_providerId!);
    } on HomeProviderServicesFailure catch (e) {
      emit(HomeProviderServicesError(e.code, e.message));
    } catch (e) {
      emit(HomeProviderServicesError('UNKNOWN', e.toString()));
    }
  }

  List<HomeServiceType> get cachedTypes => _cachedTypes;
}
