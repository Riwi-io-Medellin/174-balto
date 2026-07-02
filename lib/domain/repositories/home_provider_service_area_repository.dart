import '../entities/home_provider_service_area.dart';

abstract class HomeProviderServiceAreaRepository {
  Future<List<HomeProviderServiceArea>> getMyServiceAreas();
  Future<List<HomeProviderServiceArea>> replaceMyServiceAreas(
    List<HomeProviderServiceArea> areas,
  );
}

class HomeProviderServiceAreaFailure implements Exception {
  HomeProviderServiceAreaFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeProviderServiceAreaFailure($code): $message';
}
