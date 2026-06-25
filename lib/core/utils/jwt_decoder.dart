import 'dart:convert';

class JwtDecoder {
  const JwtDecoder._();

  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT: expected 3 segments.');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final jsonStr = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JWT: payload is not a JSON object.');
    }
    return decoded;
  }

  static String? extractUserId(String token) {
    final payload = decodePayload(token);
    final sub = payload['sub'];
    return sub is String ? sub : null;
  }
}
