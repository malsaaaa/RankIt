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

  // Default fallback values
  static const String defaultBaseUrl = 'http://192.168.0.199:8000/api';
  static const String defaultCloudName = 'qibi1obr';
  static const String defaultUploadPreset = 'y04zgv0z';
  static const String defaultCloudinaryApiKey = '786632886799257';
  static const String defaultGeminiKey = '';

  Future<String> getBaseUrl() async {
    final val = await _storage.read(key: _keyBaseUrl);
    if (val == null || val.trim().isEmpty) {
      return defaultBaseUrl;
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

  Future<void> clearAll() async {
    await _storage.delete(key: _keyBaseUrl);
    await _storage.delete(key: _keyCloudName);
    await _storage.delete(key: _keyUploadPreset);
    await _storage.delete(key: _keyCloudinaryApiKey);
    await _storage.delete(key: _keyGeminiKey);
  }
}
