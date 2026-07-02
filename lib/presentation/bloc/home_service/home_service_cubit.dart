import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/home_service_provider.dart';
import '../../../domain/repositories/home_service_provider_repository.dart';
import 'home_service_state.dart';

class HomeServiceCubit extends Cubit<HomeServiceState> {
  HomeServiceCubit(this._repository) : super(const HomeServiceInitial());

  final HomeServiceProviderRepository _repository;

  double _latitude = 4.7110;
  double _longitude = -74.0721;
  final double _radiusKm = 15.0;
  String? _serviceTypeId;

  int _page = 1;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  int _activeFilter = 0;
  List<HomeServiceProvider> _loadedProviders = [];

  void setLocation({required double latitude, required double longitude}) {
    _latitude = latitude;
    _longitude = longitude;
  }

  void setServiceTypeFilter(String? serviceTypeId) {
    _serviceTypeId = serviceTypeId;
  }

  Future<void> loadProviders() async {
    _page = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _activeFilter = 0;
    _loadedProviders = [];
    emit(const HomeServiceLoading());
    try {
      final providers = await _repository.getProviders();
      _loadedProviders = providers;
      emit(HomeServiceListLoaded(
        providers: _sortedProviders(),
        selectedFilter: _activeFilter,
        hasMore: false,
      ));
    } on HomeServiceFailure catch (e) {
      emit(HomeServiceError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceError('UNKNOWN', e.toString()));
    }
  }

  Future<void> loadMoreProviders() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    emit(HomeServiceLoadingMore(
      providers: _sortedProviders(),
      selectedFilter: _activeFilter,
    ));
    try {
      _page++;
      final result = await _repository.searchProviders(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _radiusKm,
        serviceTypeId: _serviceTypeId,
        date: _todayFormatted(),
        durationMinutes: 60,
        page: _page,
      );
      _loadedProviders = [..._loadedProviders, ...result.items];
      _hasMore = _loadedProviders.length < result.totalCount;
      emit(HomeServiceListLoaded(
        providers: _sortedProviders(),
        selectedFilter: _activeFilter,
        hasMore: _hasMore,
      ));
    } on HomeServiceFailure catch (_) {
      _page--;
      emit(HomeServiceListLoaded(
        providers: _sortedProviders(),
        selectedFilter: _activeFilter,
        hasMore: _hasMore,
      ));
    } catch (_) {
      _page--;
      emit(HomeServiceListLoaded(
        providers: _sortedProviders(),
        selectedFilter: _activeFilter,
        hasMore: _hasMore,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> searchProviders({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? serviceTypeId,
    String? date,
    int? durationMinutes,
  }) async {
    _page = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _loadedProviders = [];
    if (serviceTypeId != null) _serviceTypeId = serviceTypeId;
    emit(const HomeServiceLoading());
    try {
      final result = await _repository.searchProviders(
        latitude: latitude ?? _latitude,
        longitude: longitude ?? _longitude,
        radiusKm: radiusKm ?? _radiusKm,
        serviceTypeId: _serviceTypeId,
        date: date ?? _todayFormatted(),
        durationMinutes: durationMinutes ?? 60,
        page: _page,
      );
      _loadedProviders = result.items;
      _hasMore = _loadedProviders.length < result.totalCount;
      emit(HomeServiceListLoaded(
        providers: _sortedProviders(),
        selectedFilter: _activeFilter,
        hasMore: _hasMore,
      ));
    } on HomeServiceFailure catch (e) {
      emit(HomeServiceError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceError('UNKNOWN', e.toString()));
    }
  }

  Future<void> loadProviderDetail(String providerId) async {
    emit(const HomeServiceLoading());
    try {
      final provider = await _repository.getProviderDetail(providerId);
      emit(HomeServiceDetailLoaded(provider));
    } on HomeServiceFailure catch (e) {
      emit(HomeServiceError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceError('UNKNOWN', e.toString()));
    }
  }

  void applyFilter(int filterIndex) {
    _activeFilter = filterIndex;
    if (_loadedProviders.isNotEmpty || state is HomeServiceListLoaded) {
      emit(HomeServiceListLoaded(
        providers: _sortedProviders(),
        selectedFilter: _activeFilter,
        hasMore: _hasMore,
      ));
    }
  }

  List<HomeServiceProvider> _sortedProviders() {
    switch (_activeFilter) {
      case 1:
        return List.from(_loadedProviders)
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case 2:
        return _loadedProviders.where((p) => p.isAcceptingBookings).toList();
      default:
        return List.from(_loadedProviders)
          ..sort((a, b) => a.distance.compareTo(b.distance));
    }
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
