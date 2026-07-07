import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/walker.dart';
import '../../../domain/repositories/walker_repository.dart';
import 'walker_state.dart';

class WalkerCubit extends Cubit<WalkerState> {
  WalkerCubit(this._repository) : super(const WalkerInitial());

  final WalkerRepository _repository;

  double _latitude = 4.7110;
  double _longitude = -74.0721;
  final double _radiusKm = 10.0;

  int _page = 1;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  int _activeFilter = 0;
  List<Walker> _loadedWalkers = [];

  void setLocation({required double latitude, required double longitude}) {
    _latitude = latitude;
    _longitude = longitude;
  }

  Future<void> loadWalkers() async {
    _page = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _activeFilter = 0;
    _loadedWalkers = [];
    emit(const WalkerLoading());
    try {
      final walkers = await _repository.getWalkers();
      _loadedWalkers = walkers;
      emit(
        WalkerListLoaded(
          walkers: _sortedWalkers(),
          selectedFilter: _activeFilter,
          hasMore: false,
        ),
      );
    } on WalkerFailure catch (e) {
      emit(WalkerError(e.code, e.message));
    } catch (e) {
      emit(WalkerError('UNKNOWN', e.toString()));
    }
  }

  Future<void> loadMoreWalkers() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    emit(
      WalkerLoadingMore(
        walkers: _sortedWalkers(),
        selectedFilter: _activeFilter,
      ),
    );
    try {
      _page++;
      final result = await _repository.searchWalkers(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _radiusKm,
        date: _todayFormatted(),
        durationMinutes: 60,
        page: _page,
      );
      _loadedWalkers = [..._loadedWalkers, ...result.items];
      _hasMore = _loadedWalkers.length < result.totalCount;
      emit(
        WalkerListLoaded(
          walkers: _sortedWalkers(),
          selectedFilter: _activeFilter,
          hasMore: _hasMore,
        ),
      );
    } on WalkerFailure catch (_) {
      _page--;
      emit(
        WalkerListLoaded(
          walkers: _sortedWalkers(),
          selectedFilter: _activeFilter,
          hasMore: _hasMore,
        ),
      );
    } catch (_) {
      _page--;
      emit(
        WalkerListLoaded(
          walkers: _sortedWalkers(),
          selectedFilter: _activeFilter,
          hasMore: _hasMore,
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> searchWalkers({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? date,
    int? durationMinutes,
  }) async {
    _page = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _loadedWalkers = [];
    emit(const WalkerLoading());
    try {
      final result = await _repository.searchWalkers(
        latitude: latitude ?? _latitude,
        longitude: longitude ?? _longitude,
        radiusKm: radiusKm ?? _radiusKm,
        date: date ?? _todayFormatted(),
        durationMinutes: durationMinutes ?? 60,
        page: _page,
      );
      _loadedWalkers = result.items;
      _hasMore = _loadedWalkers.length < result.totalCount;
      emit(
        WalkerListLoaded(
          walkers: _sortedWalkers(),
          selectedFilter: _activeFilter,
          hasMore: _hasMore,
        ),
      );
    } on WalkerFailure catch (e) {
      emit(WalkerError(e.code, e.message));
    } catch (e) {
      emit(WalkerError('UNKNOWN', e.toString()));
    }
  }

  Future<void> loadWalkerDetail(String walkerId) async {
    emit(const WalkerLoading());
    try {
      final walker = await _repository.getWalkerDetail(walkerId);
      emit(WalkerDetailLoaded(walker));
    } on WalkerFailure catch (e) {
      emit(WalkerError(e.code, e.message));
    } catch (e) {
      emit(WalkerError('UNKNOWN', e.toString()));
    }
  }

  void applyFilter(int filterIndex) {
    _activeFilter = filterIndex;
    if (_loadedWalkers.isNotEmpty || state is WalkerListLoaded) {
      emit(
        WalkerListLoaded(
          walkers: _sortedWalkers(),
          selectedFilter: _activeFilter,
          hasMore: _hasMore,
        ),
      );
    }
  }

  List<Walker> _sortedWalkers() {
    switch (_activeFilter) {
      case 1:
        return List.from(_loadedWalkers)
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case 2:
        return _loadedWalkers.where((w) => w.isAcceptingBookings).toList();
      default:
        return List.from(_loadedWalkers)
          ..sort((a, b) => a.distance.compareTo(b.distance));
    }
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
