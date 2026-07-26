import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import '../models/ranking_list_model.dart';
import '../models/item_model.dart';
import '../services/cloudinary_service.dart';
import '../services/gemini_service.dart';
import '../services/api_service.dart';

class RankingProvider extends ChangeNotifier {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final GeminiService _geminiService = GeminiService();
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<RankingListModel> _rankingLists = [];
  List<ItemModel> _currentItems = [];
  List<Map<String, dynamic>> _userRanking = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Cache for Gemini summaries: Map<listId, summary>
  final Map<String, String> _aiSummaries = {};

  List<CategoryModel> get categories => _categories;
  List<RankingListModel> get rankingLists => _rankingLists;
  List<ItemModel> get currentItems => _currentItems;
  List<Map<String, dynamic>> get userRanking => _userRanking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  String? getCachedAiSummary(String listId) => _aiSummaries[listId];

  Future<void> loadCategories() async {
    _setLoading(true);
    _setError(null);
    try {
      _categories = await _apiService.getCategories();
      _setLoading(false);
    } catch (e) {
      _setError("Failed to load categories: $e");
      _setLoading(false);
    }
  }

  Future<void> createCategory({
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.createCategory(
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      // Reload from API so the list stays in sync with the database
      await loadCategories();
    } catch (e) {
      _setError("Failed to create category: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.updateCategory(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      await loadCategories();
    } catch (e) {
      _setError("Failed to update category: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _setError("Failed to delete category: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> loadRankingLists(String categoryId) async {
    _setLoading(true);
    _setError(null);
    try {
      _rankingLists = await _apiService.getTopics(categoryId);
      _setLoading(false);
    } catch (e) {
      _setError("Failed to load ranking lists: $e");
      _setLoading(false);
    }
  }

  Future<void> createRankingList({
    required String categoryId,
    required String title,
    required String description,
    required String userId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newList = await _apiService.createTopic(
        categoryId: categoryId,
        title: title,
        description: description,
        userId: userId,
      );
      _rankingLists.insert(0, newList);
      _setLoading(false);
    } catch (e) {
      _setError("Failed to create ranking list: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> loadItems(String listId) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentItems = await _apiService.getCandidates(listId);
      _userRanking = [];
      _setLoading(false);
    } catch (e) {
      _setError("Failed to load items: $e");
      _setLoading(false);
    }
  }

  Future<void> loadTopicWithUserRanking({
    required String topicId,
    required String userId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _apiService.getTopicWithUserRanking(
        topicId: topicId,
        userId: userId,
      );
      _currentItems = result['candidates'] as List<ItemModel>;
      _userRanking = result['user_ranking'] as List<Map<String, dynamic>>;
      _setLoading(false);
    } catch (e) {
      _setError("Failed to load topic: $e");
      _setLoading(false);
    }
  }

  Future<void> createItem({
    required String listId,
    required String name,
    required String description,
    required XFile? imageFile,
    String? externalImageUrl,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      String? imageUrl = externalImageUrl;
      if (imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);
      }
      final newItem = await _apiService.createCandidate(
        topicId: listId,
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      _currentItems.add(newItem);

      // Update item count locally on the current list
      final idx = _rankingLists.indexWhere((l) => l.id == listId);
      if (idx != -1) {
        final list = _rankingLists[idx];
        _rankingLists[idx] = list.copyWith(
          itemsCount: list.itemsCount + 1,
        );
      }
      _setLoading(false);
    } catch (e) {
      _setError("Failed to add item: $e");
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> submitVote({
    required String listId,
    required String userId,
    required String userName,
    required List<String> rankedItemIds,
  }) async {
    _setError(null);
    try {
      final Map<String, ItemModel> itemMap = {
        for (var item in _currentItems) item.id: item
      };
      final rankedItems = rankedItemIds
          .map((id) => itemMap[id])
          .whereType<ItemModel>()
          .toList();

      await _apiService.submitVote(
        userId: userId,
        topicId: listId,
        items: rankedItems,
      );
      await loadItems(listId);
      // Invalidate the AI summary since votes changed
      _aiSummaries.remove(listId);
    } catch (e) {
      _setError("Failed to submit vote: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String listId) async {
    return await _apiService.getLeaderboard(listId);
  }

  Future<String> generateAiAnalysis({
    required String listId,
    required String title,
    required String description,
    required List<Map<String, dynamic>> rawItems,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _aiSummaries.containsKey(listId)) {
      return _aiSummaries[listId]!;
    }

    // Convert rawItems map to ItemModel instances
    final items = rawItems.map((map) {
      final name = map['name']?.toString() ?? '';
      final points = double.tryParse(map['total_points']?.toString() ?? '0.0') ?? 0.0;
      final votes = int.tryParse(map['votes_count']?.toString() ?? '0') ?? 0;
      final desc = map['description']?.toString() ?? '';
      return ItemModel(
        id: map['candidate_id']?.toString() ?? '',
        listId: listId,
        name: name,
        description: desc,
        score: points,
        votesCount: votes,
      );
    }).toList();

    try {
      final analysis = await _geminiService.analyzeRankings(
        listTitle: title,
        listDescription: description,
        items: items,
      );
      _aiSummaries[listId] = analysis;
      notifyListeners();
      return analysis;
    } catch (e) {
      return "Unable to perform AI analysis at this time. Please check your internet connection or API keys. Error: $e";
    }
  }

  Future<void> suggestCandidate({
    required String topicId,
    required String userId,
    required String name,
    String? description,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.suggestCandidate(
        topicId: topicId,
        userId: userId,
        name: name,
        description: description,
      );
      _setLoading(false);
    } catch (e) {
      _setError("Failed to submit suggestion: $e");
      _setLoading(false);
      rethrow;
    }
  }
}
