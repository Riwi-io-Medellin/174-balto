abstract class HomeFavoriteProviderRepository {
  Future<List<String>> getMyFavoriteProviderIds();
  Future<void> addFavorite(String providerId);
  Future<void> removeFavorite(String providerId);
}

class HomeFavoriteProviderFailure implements Exception {
  HomeFavoriteProviderFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeFavoriteProviderFailure($code): $message';
}
