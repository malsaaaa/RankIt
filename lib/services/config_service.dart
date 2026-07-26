import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyBaseUrl = 'api_base_url';
  static const String _keyCloudName = 'cloudinary_cloud_name';
  static const String _keyUploadPreset = 'cloudinary_upload_preset';
  static const String _keyCloudinaryApiKey = 'cloudinary_api_key';
  static const String _keyGeminiKey = 'gemini_api_key';
  static const String _keyUnsplashKey = 'unsplash_api_key';

  // Default fallback values
  static const String defaultBaseUrl = 'http://localhost:8000/api';
  static const String defaultCloudName = 'vjrjqeg1';
  static const String defaultUploadPreset = 'svnoavxj';
  static const String defaultCloudinaryApiKey = '';
  static const String defaultGeminiKey = '';
  static const String defaultUnsplashKey = '';

  Future<String> getBaseUrl() async {
    final val = await _storage.read(key: _keyBaseUrl);
    if (val == null || val.trim().isEmpty) {
      return defaultBaseUrl;
    }
    if (val.contains('127.0.0.1')) {
      return val.replaceAll('127.0.0.1', 'localhost');
    }
    return val;
  }

  Future<void> setBaseUrl(String url) async {
    await _storage.write(key: _keyBaseUrl, value: url.trim());
  }

  Future<String> getCloudName() async {
    final val = await _storage.read(key: _keyCloudName);
    if (val == null || val.trim().isEmpty) {
      return defaultCloudName;
    }
    return val;
  }

  Future<void> setCloudName(String val) async {
    await _storage.write(key: _keyCloudName, value: val.trim());
  }

  Future<String> getUploadPreset() async {
    final val = await _storage.read(key: _keyUploadPreset);
    if (val == null || val.trim().isEmpty) {
      return defaultUploadPreset;
    }
    return val;
  }

  Future<void> setUploadPreset(String val) async {
    await _storage.write(key: _keyUploadPreset, value: val.trim());
  }

  Future<String> getCloudinaryApiKey() async {
    final val = await _storage.read(key: _keyCloudinaryApiKey);
    if (val == null || val.trim().isEmpty) {
      return defaultCloudinaryApiKey;
    }
    return val;
  }

  Future<void> setCloudinaryApiKey(String val) async {
    await _storage.write(key: _keyCloudinaryApiKey, value: val.trim());
  }

  Future<String> getGeminiKey() async {
    final val = await _storage.read(key: _keyGeminiKey);
    if (val == null || val.trim().isEmpty) {
      return defaultGeminiKey;
    }
    return val;
  }

  Future<void> setGeminiKey(String val) async {
    await _storage.write(key: _keyGeminiKey, value: val.trim());
  }

  Future<String> getUnsplashKey() async {
    final val = await _storage.read(key: _keyUnsplashKey);
    if (val == null || val.trim().isEmpty) {
      return defaultUnsplashKey;
    }
    return val;
  }

  Future<void> setUnsplashKey(String val) async {
    await _storage.write(key: _keyUnsplashKey, value: val.trim());
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyBaseUrl);
    await _storage.delete(key: _keyCloudName);
    await _storage.delete(key: _keyUploadPreset);
    await _storage.delete(key: _keyCloudinaryApiKey);
    await _storage.delete(key: _keyGeminiKey);
    await _storage.delete(key: _keyUnsplashKey);
  }
}
