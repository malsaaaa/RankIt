import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class UnsplashService {
  /// Searches photos on Unsplash.
  /// If the API key is not configured, returns a set of curated mock image URLs matching the query.
  Future<List<String>> searchPhotos(String query, {int page = 1}) async {
    final configService = ConfigService();
    var apiKey = await configService.getUnsplashKey();

    if (apiKey == null || apiKey == 'YOUR_UNSPLASH_ACCESS_KEY' || apiKey.trim().isEmpty) {
      apiKey = 'pUz_a8UeXxN00wBiIsgp1unFy_ja3Z7BKVeBYd_Likg';
    }

    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = 'https://api.unsplash.com/search/photos?query=$encodedQuery&per_page=12&page=$page&client_id=$apiKey';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        
        return results.map<String>((item) {
          // Return the 'regular' size URL for a good balance of quality and load speed
          return item['urls']?['regular']?.toString() ?? '';
        }).where((url) => url.isNotEmpty).toList();
      } else {
        debugPrint("Unsplash search failed (status ${response.statusCode}): ${response.body}");
        return _generateMockPhotos(query, page: page);
      }
    } catch (e) {
      debugPrint("Error searching Unsplash: $e. Falling back to mock images.");
      return _generateMockPhotos(query, page: page);
    }
  }

  List<String> _generateMockPhotos(String query, {int page = 1}) {
    // Generates a list of high-quality source URLs based on the query keyword and page index
    final normalized = query.toLowerCase().trim();
    final List<String> photos = [];
    
    // Add 8 deterministic mock URLs using loremflickr keyword service
    int start = (page - 1) * 8 + 1;
    for (int i = start; i < start + 8; i++) {
      photos.add(
        'https://loremflickr.com/600/450/$normalized?random=$i',
      );
    }

    // Some specific keyword overrides for better presentation
    if (normalized.contains('burger') || normalized.contains('food')) {
      return [
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1571091718767-18b5b1457add?auto=format&fit=crop&w=600&q=80',
      ];
    } else if (normalized.contains('sushi') || normalized.contains('shushi')) {
      return [
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1611143669185-af224c5e3252?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?auto=format&fit=crop&w=600&q=80',
      ];
    } else if (normalized.contains('car')) {
      return [
        'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=600&q=80',
      ];
    } else if (normalized.contains('movie') || normalized.contains('film')) {
      return [
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=600&q=80',
      ];
    }
    
    return photos;
  }
}
