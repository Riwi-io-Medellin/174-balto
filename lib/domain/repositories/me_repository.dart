import '../entities/me.dart';

abstract class MeRepository {
  Future<Me> get();
}

class MeFailure implements Exception {
  MeFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'MeFailure($code): $message';
}
