import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/business.dart';
import '../../../domain/repositories/business_repository.dart';
import 'business_state.dart';

class BusinessCubit extends Cubit<BusinessState> {
  BusinessCubit(this._repository) : super(const BusinessInitial());

  final BusinessRepository _repository;

  double? _userLatitude;
  double? _userLongitude;

  void setUserLocation({required double latitude, required double longitude}) {
    _userLatitude = latitude;
    _userLongitude = longitude;
  }

  /// Requests the device's current GPS position, same pattern as
  /// WalkersPage. Silently no-ops if permission/service is unavailable —
  /// businesses just render without a distance badge in that case.
  Future<void> loadUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      setUserLocation(latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      // Location unavailable — proceed without distances.
    }
  }

  Future<void> loadBusinesses({String? type, String? location}) async {
    emit(const BusinessLoading());
    try {
      final businesses =
          await _repository.getBusinesses(type: type, location: location);
      emit(BusinessListLoaded(_withDistances(businesses)));
    } on BusinessFailure catch (e) {
      emit(BusinessError(e.code, e.message));
    } catch (e) {
      emit(BusinessError('UNKNOWN', e.toString()));
    }
  }

  Future<void> loadBusinessDetail(String businessId) async {
    emit(const BusinessLoading());
    try {
      final business = await _repository.getBusinessDetail(businessId);
      final withDistance = _withDistances([business]).first;
      emit(BusinessDetailLoaded(withDistance));
    } on BusinessFailure catch (e) {
      emit(BusinessError(e.code, e.message));
    } catch (e) {
      emit(BusinessError('UNKNOWN', e.toString()));
    }
  }

  List<Business> _withDistances(List<Business> businesses) {
    if (_userLatitude == null || _userLongitude == null) return businesses;
    return businesses.map((b) {
      if (b.latitude == null || b.longitude == null) return b;
      final km = _haversineKm(
        _userLatitude!,
        _userLongitude!,
        b.latitude!,
        b.longitude!,
      );
      return b.copyWith(distanceKm: km);
    }).toList();
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);
}
