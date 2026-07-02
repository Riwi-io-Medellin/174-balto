import '../entities/available_slot.dart';
import '../entities/home_service_provider.dart';

abstract class HomeServiceProviderRepository {
  /// List all providers with optional filters.
  Future<List<HomeServiceProvider>> getProviders({
    bool? isAcceptingBookings,
    String? baseLocation,
  });

  /// Search approved providers by location, service type, date and duration.
  Future<HomeServiceSearchResult> searchProviders({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? serviceTypeId,
    required String date,
    required int durationMinutes,
    int page = 1,
    int pageSize = 20,
  });

  /// Get full provider detail by ID.
  Future<HomeServiceProvider> getProviderDetail(
    String providerId, {
    String? date,
    int? durationMinutes,
  });

  /// Get computed available booking slots for a provider on a specific date.
  Future<List<AvailableSlot>> getAvailableSlots({
    required String providerId,
    required String date,
    required int durationMinutes,
  });
}

class HomeServiceSearchResult {
  const HomeServiceSearchResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<HomeServiceProvider> items;
  final int page;
  final int pageSize;
  final int totalCount;
}

class HomeServiceFailure implements Exception {
  HomeServiceFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeServiceFailure($code): $message';
}
