import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/ranking_list_model.dart';
import '../models/item_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.199:8000/api';

  Future<List<CategoryModel>> getCategories() async {
    print("Calling API...");
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return CategoryModel(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          imageUrl: item['image_url'],
          createdBy: 'system',
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
        );
      }).toList();
    }

    throw Exception('Failed to load categories (${response.statusCode})');
  }

  Future<List<RankingListModel>> getTopics(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final filteredData = data.where(
        (item) => item['category_id'].toString() == categoryId,
      );

      return filteredData.map((item) {
        return RankingListModel(
          id: item['id'].toString(),
          categoryId: item['category_id'].toString(),
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          createdBy: item['created_by'].toString(),
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
          itemsCount: 0,
        );
      }).toList();
    }

    throw Exception('Failed to load topics (${response.statusCode})');
  }

  Future<List<ItemModel>> getCandidates(String topicId) async {
    final response = await http.get(Uri.parse('$baseUrl/topics/$topicId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> candidates = data['candidates'] ?? [];

      return candidates.map((item) {
        return ItemModel(
          id: item['id'].toString(),
          listId: item['topic_id'].toString(),
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          imageUrl: item['image_url'],
          score: 0,
          votesCount: 0,
        );
      }).toList();
    }

    throw Exception('Failed to load candidates (${response.statusCode})');
  }

  Future<void> submitVote({
    required String userId,
    required String topicId,
    required List<ItemModel> items,
  }) async {
    final rankings = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      rankings.add({"candidate_id": int.parse(items[i].id), "position": i + 1});
    }

    final requestBody = {
      "user_id": int.parse(userId),
      "topic_id": int.parse(topicId),
      "rankings": rankings,
    };

    print("REQUEST:");
    print(jsonEncode(requestBody));

    final response = await http.post(
      Uri.parse('$baseUrl/submissions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print("STATUS:");
    print(response.statusCode);

    print("RESPONSE:");
    print(response.body);

    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String topicId) async {
    final response = await http.get(Uri.parse('$baseUrl/leaderboard/$topicId'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    throw Exception('Failed to load leaderboard');
  }

  // ─── Category CRUD ───────────────────────────────────────────────────────

  /// POST /api/categories — creates a new category, returns HTTP 201.
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['image_url'] = imageUrl;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final item = jsonDecode(response.body);
        return CategoryModel(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          imageUrl: item['image_url'],
          createdBy: 'system',
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
        );
      }

      // Extract backend validation / error message
      String errorMessage =
          'Failed to create category (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'].toString();
        } else if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          errorMessage =
              errors.values.expand((v) => v is List ? v : [v]).join(', ');
        }
      } catch (_) {}
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error creating category: $e');
    }
  }

  /// PUT /api/categories/{id} — updates a category, returns updated data.
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null) body['description'] = description;
      if (imageUrl != null) body['image_url'] = imageUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return CategoryModel(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          imageUrl: item['image_url'],
          createdBy: 'system',
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
        );
      }

      String errorMessage =
          'Failed to update category (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'].toString();
        } else if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          errorMessage =
              errors.values.expand((v) => v is List ? v : [v]).join(', ');
        }
      } catch (_) {}
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error updating category: $e');
    }
  }

  /// DELETE /api/categories/{id} — deletes a category.
  Future<void> deleteCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) return;

      String errorMessage =
          'Failed to delete category (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error deleting category: $e');
    }
  }
}
