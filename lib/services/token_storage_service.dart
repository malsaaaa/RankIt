import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String authTokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: authTokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: authTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
