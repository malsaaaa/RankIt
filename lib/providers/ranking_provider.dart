import 'dart:io';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/ranking_list_model.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../services/cloudinary_service.dart';
import '../services/gemini_service.dart';
import '../services/api_service.dart';

class RankingProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final GeminiService _geminiService = GeminiService();
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<RankingListModel> _rankingLists = [];
  List<ItemModel> _currentItems = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Cache for Gemini summaries: Map<listId, summary>
  final Map<String, String> _aiSummaries = {};

  List<CategoryModel> get categories => _categories;
  List<RankingListModel> get rankingLists => _rankingLists;
  List<ItemModel> get currentItems => _currentItems;
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
    required String description,
    required File? imageFile,
    required String userId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);
      }
      final newCat = await _dbService.createCategory(
        name,
        description,
        imageUrl,
        userId,
      );
      _categories.insert(0, newCat);
      _setLoading(false);
    } catch (e) {
      _setError("Failed to create category: $e");
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
      final newList = await _dbService.createRankingList(
        categoryId,
        title,
        description,
        userId,
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
      _setLoading(false);
    } catch (e) {
      _setError("Failed to load items: $e");
      _setLoading(false);
    }
  }

  Future<void> createItem({
    required String listId,
    required String name,
    required String description,
    required File? imageFile,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);
      }
      final newItem = await _dbService.createItem(
        listId,
        name,
        description,
        imageUrl,
      );
      _currentItems.add(newItem);

      // Update item count locally on the current list
      final idx = _rankingLists.indexWhere((l) => l.id == listId);
      if (idx != -1) {
        final list = _rankingLists[idx];
        _rankingLists[idx] = RankingListModel(
          id: list.id,
          categoryId: list.categoryId,
          title: list.title,
          description: list.description,
          createdBy: list.createdBy,
          createdAt: list.createdAt,
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
      final rankedItems = _currentItems
          .where((item) => rankedItemIds.contains(item.id))
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
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _aiSummaries.containsKey(listId)) {
      return _aiSummaries[listId]!;
    }

    // Sort items by score descending to represent current leaderboard status
    final items = List<ItemModel>.from(_currentItems);
    items.sort((a, b) => b.score.compareTo(a.score));

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
}
