import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionCache {
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  /// Instancia segura única
  final _storage = const FlutterSecureStorage();

  /// Guarda token y datos de usuario
  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  /// Recupera los datos del usuario
  Future<Map<String, dynamic>?> getUser() async {
    final jsonString = await _storage.read(key: _userKey);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// Recupera el token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina todos los datos de sesión
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
