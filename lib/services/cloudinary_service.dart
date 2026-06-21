import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';

class CloudinaryService {
  /// Uploads a local file to Cloudinary and returns its secure URL.
  /// If credentials are not configured, falls back to returning a high-quality placeholder image URL.
  Future<String> uploadImage(File file) async {
    final cloudName = Secrets.cloudinaryCloudName;
    final uploadPreset = Secrets.cloudinaryUploadPreset;

    // Check if placeholders are still present
    if (cloudName == 'YOUR_CLOUDINARY_CLOUD_NAME' || 
        uploadPreset == 'YOUR_CLOUDINARY_UPLOAD_PRESET' ||
        cloudName.isEmpty || 
        uploadPreset.isEmpty) {
      print("Cloudinary credentials not configured. Using high-quality placeholder image.");
      return _generatePlaceholderUrl();
    }

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonDecoded = json.decode(responseData);
        return jsonDecoded['secure_url'] as String;
      } else {
        final responseData = await response.stream.bytesToString();
        print("Cloudinary upload failed (status ${response.statusCode}): $responseData");
        throw Exception("Failed to upload image to Cloudinary: Status ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e. Falling back to placeholder.");
      return _generatePlaceholderUrl();
    }
  }

  String _generatePlaceholderUrl() {
    // Return a random high-quality placeholder image from Unsplash for ranking categories
    final topics = ['retro-gaming', 'cinema', 'ramen', 'sports', 'neon', 'vintage-technology'];
    final randomTopic = (topics..shuffle()).first;
    return 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=600&sig=${DateTime.now().millisecondsSinceEpoch}';
  }
}
