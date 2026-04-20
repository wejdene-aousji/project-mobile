import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Token Persistence Service
/// Handles storing and retrieving JWT tokens from local storage
abstract class ITokenPersistence {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

/// Token Persistence using SharedPreferences
class TokenPersistence implements ITokenPersistence {
  late SharedPreferences _prefs;

  /// Initialize the persistence service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConfig.tokenStorageKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(AppConfig.tokenStorageKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConfig.refreshTokenStorageKey, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(AppConfig.refreshTokenStorageKey);
  }

  @override
  Future<void> clearTokens() async {
    await _prefs.remove(AppConfig.tokenStorageKey);
    await _prefs.remove(AppConfig.refreshTokenStorageKey);
  }

  /// Get string (used for user data)
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  /// Set string
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Remove key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all data
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
