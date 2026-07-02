import '../entities/home_service_type.dart';

abstract class HomeServiceTypeRepository {
  Future<List<HomeServiceType>> getTypes();
}

class HomeServiceTypeFailure implements Exception {
  HomeServiceTypeFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeServiceTypeFailure($code): $message';
}
