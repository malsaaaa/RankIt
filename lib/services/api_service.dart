import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/mock_data.dart';
import '../models/category_model.dart';
import '../models/ranking_list_model.dart';
import '../models/item_model.dart';

class ApiService {
  static String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<CategoryModel>> getCategories() async {
    debugPrint("Calling API...");
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    debugPrint(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final categories = data.map((item) {
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

      if (categories.isEmpty && useMockData) {
        return MockData.getCategories();
      }

      return categories;
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

      final topics = filteredData.map((item) {
        return RankingListModel(
          id: item['id'].toString(),
          categoryId: item['category_id'].toString(),
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          createdBy: item['created_by'].toString(),
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
          itemsCount: item['candidates_count'] ?? 0,
        );
      }).toList();

      if (topics.isEmpty && useMockData) {
        return MockData.getTopicsByCategory(categoryId);
      }

      return topics;
    }

    throw Exception('Failed to load topics (${response.statusCode})');
  }

  Future<List<ItemModel>> getCandidates(String topicId) async {
    final response = await http.get(Uri.parse('$baseUrl/topics/$topicId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> candidates = data['candidates'] ?? [];

      final mappedCandidates = candidates.map((item) {
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

      if (mappedCandidates.isEmpty && useMockData) {
        return MockData.getCandidatesByTopic(topicId);
      }

      return mappedCandidates;
    }

    throw Exception('Failed to load candidates (${response.statusCode})');
  }

  Future<Map<String, dynamic>> getTopicWithUserRanking({
    required String topicId,
    required String userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/topics/$topicId?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> candidates = data['candidates'] ?? [];
      final List<dynamic> userRanking = data['user_ranking'] ?? [];

      final mappedCandidates = candidates.map((item) {
        return ItemModel(
          id: item['id'].toString(),
          listId: item['topic_id'].toString(),
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          imageUrl: item['image_url'],
          score: double.tryParse(item['total_points']?.toString() ?? '') ?? 0.0,
          votesCount: int.tryParse(item['votes_count']?.toString() ?? '') ?? 0,
        );
      }).toList();

      final mappedUserRanking = userRanking.map((item) => {
        'candidate_id': item['candidate_id'].toString(),
        'position': item['position'],
      }).toList();

      if (mappedCandidates.isEmpty && useMockData) {
        return {
          'candidates': MockData.getCandidatesByTopic(topicId),
          'user_ranking': <Map<String, dynamic>>[],
        };
      }

      return {
        'candidates': mappedCandidates,
        'user_ranking': mappedUserRanking,
      };
    }

    throw Exception('Failed to load topic (${response.statusCode})');
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
      "user_id": userId,
      "topic_id": int.parse(topicId),
      "rankings": rankings,
    };

    debugPrint("REQUEST:");
    debugPrint(jsonEncode(requestBody));

    final response = await http.post(
      Uri.parse('$baseUrl/submissions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    debugPrint("STATUS:");
    debugPrint(response.statusCode.toString());

    debugPrint("RESPONSE:");
    debugPrint(response.body);

    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String topicId) async {
    final response = await http.get(Uri.parse('$baseUrl/leaderboard/$topicId'));

    if (response.statusCode == 200) {
      final leaderboard = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      if (leaderboard.isEmpty && useMockData) {
        return MockData.getLeaderboardByTopic(topicId);
      }

      return leaderboard;
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

  Future<RankingListModel> createTopic({
    required String categoryId,
    required String title,
    required String description,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/topics'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'category_id': int.parse(categoryId),
        'created_by': userId,
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      final item = jsonDecode(response.body);
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
    }

    String errorMessage = 'Failed to create topic (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'].toString();
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }

  Future<ItemModel> createCandidate({
    required String topicId,
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/topics/$topicId/candidates'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'image_url': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      final item = jsonDecode(response.body);
      return ItemModel(
        id: item['id'].toString(),
        listId: item['topic_id'].toString(),
        name: item['name'] ?? '',
        description: item['description'] ?? '',
        imageUrl: item['image_url'],
        score: 0,
        votesCount: 0,
      );
    }

    String errorMessage = 'Failed to create candidate (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'].toString();
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }

  Future<void> suggestCandidate({
    required String topicId,
    required String userId,
    required String name,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'name': name,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/topics/$topicId/suggestions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      String errorMessage = 'Failed to submit suggestion';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
