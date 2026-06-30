import '../entities/available_slot.dart';
import '../entities/walker.dart';

abstract class WalkerRepository {
  /// List all walkers with optional filters.
  Future<List<Walker>> getWalkers({bool? available, String? workLocation});

  /// Search approved walkers by location, date and duration.
  Future<WalkerSearchResult> searchWalkers({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required String date,
    required int durationMinutes,
    int page = 1,
    int pageSize = 20,
  });

  /// Get full walker detail by ID.
  Future<Walker> getWalkerDetail(
    String walkerId, {
    String? date,
    int? durationMinutes,
  });

  /// Get computed available booking slots for a walker on a specific date.
  Future<List<AvailableSlot>> getAvailableSlots({
    required String walkerId,
    required String date,
    required int durationMinutes,
  });
}

class WalkerSearchResult {
  const WalkerSearchResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<Walker> items;
  final int page;
  final int pageSize;
  final int totalCount;
}

class WalkerFailure implements Exception {
  WalkerFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkerFailure($code): $message';
}
