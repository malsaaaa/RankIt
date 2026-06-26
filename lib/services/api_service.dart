import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/ranking_list_model.dart';
import '../models/item_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

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
}
