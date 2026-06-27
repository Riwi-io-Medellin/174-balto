import '../entities/walker.dart';

abstract class WalkerRepository {
  Future<List<Walker>> getAll();
  Future<Walker?> findByUserId(String userId);
}

class WalkerFailure implements Exception {
  WalkerFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkerFailure($code): $message';
}
