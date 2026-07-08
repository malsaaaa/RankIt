import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'config_service.dart';

class CloudinaryService {
  /// Uploads a local file to Cloudinary and returns its secure URL.
  /// If credentials are not configured, falls back to returning a high-quality placeholder image URL.
  Future<String> uploadImage(XFile file) async {
    final configService = ConfigService();
    final cloudName = await configService.getCloudName();
    final uploadPreset = await configService.getUploadPreset();
    final apiKey = await configService.getCloudinaryApiKey();

    // Check if placeholders are still present or empty
    if (cloudName == 'YOUR_CLOUDINARY_CLOUD_NAME' || 
        uploadPreset == 'YOUR_CLOUDINARY_UPLOAD_PRESET' ||
        cloudName.isEmpty || 
        uploadPreset.isEmpty) {
      debugPrint("Cloudinary credentials not configured. Using high-quality placeholder image.");
      return _generatePlaceholderUrl();
    }

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      if (apiKey.isNotEmpty) {
        request.fields['api_key'] = apiKey;
      }
      
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonDecoded = json.decode(responseData);
        return jsonDecoded['secure_url'] as String;
      } else {
        final responseData = await response.stream.bytesToString();
        debugPrint("Cloudinary upload failed (status ${response.statusCode}): $responseData");
        throw Exception("Failed to upload image to Cloudinary: Status ${response.statusCode} - $responseData");
      }
    } catch (e) {
      debugPrint("Error uploading to Cloudinary: $e");
      rethrow;
    }
  }

  String _generatePlaceholderUrl() {
    // Return a random high-quality placeholder image from Unsplash for ranking categories
    return 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=600&sig=${DateTime.now().millisecondsSinceEpoch}';
  }
}
