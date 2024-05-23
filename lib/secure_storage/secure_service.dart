import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> writeToken(String key, String token) async {
    await _storage.write(key: key, value: token);
  }

  Future<String?> readToken(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }
}
