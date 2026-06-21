import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/ranking_list_model.dart';
import '../models/item_model.dart';
import '../models/vote_model.dart';

abstract class BaseDatabaseService {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory(String name, String description, String? imageUrl, String userId);
  
  Future<List<RankingListModel>> getRankingLists(String categoryId);
  Future<RankingListModel> createRankingList(String categoryId, String title, String description, String userId);
  
  Future<List<ItemModel>> getItems(String listId);
  Future<ItemModel> createItem(String listId, String name, String description, String? imageUrl);
  
  Future<void> submitVote(String listId, String userId, String userName, List<String> rankedItemIds);
  Future<List<ItemModel>> getLeaderboard(String listId);
  
  Future<List<VoteModel>> getUserVotes(String userId);
  Future<List<RankingListModel>> getUserCreatedLists(String userId);
  
  Stream<List<ItemModel>> streamLeaderboard(String listId);
}

class DatabaseService implements BaseDatabaseService {
  final FirebaseFirestore? _firestore = _initFirestore();
  
  static bool useMock = false;

  // Static Mock Data Store
  static final List<CategoryModel> _mockCategories = [];
  static final List<RankingListModel> _mockRankingLists = [];
  static final List<ItemModel> _mockItems = [];
  static final List<VoteModel> _mockVotes = [];

  static FirebaseFirestore? _initFirestore() {
    try {
      // Just check if we can access the instance. Will throw if Firebase isn't initialized.
      return FirebaseFirestore.instance;
    } catch (e) {
      print("Firestore not initialized. Switching to Mock DB: $e");
      useMock = true;
      return null;
    }
  }

  DatabaseService() {
    if (_mockCategories.isEmpty) {
      _seedMockData();
    }
  }

  void _seedMockData() {
    print("Seeding rich mock data for RankeRating local database...");
    
    // Seed Categories
    _mockCategories.addAll([
      CategoryModel(
        id: 'cat_games',
        name: 'Video Games',
        description: 'Consoles, RPGs, shooters, indie gems, and platformers.',
        imageUrl: 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?auto=format&fit=crop&q=80&w=600',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CategoryModel(
        id: 'cat_movies',
        name: 'Movies & Series',
        description: 'Cinematic masterpieces, binge-worthy TV series, and anime.',
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&q=80&w=600',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      CategoryModel(
        id: 'cat_food',
        name: 'Food & Culinary',
        description: 'Street foods, desserts, fine dining, and world cuisines.',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=600',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ]);

    // Seed Ranking Lists
    _mockRankingLists.addAll([
      RankingListModel(
        id: 'list_rpg',
        categoryId: 'cat_games',
        title: 'Best RPGs of All Time',
        description: 'The ultimate role-playing games that defined the genre with storytelling, mechanics, and worlds.',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        itemsCount: 5,
      ),
      RankingListModel(
        id: 'list_scifi',
        categoryId: 'cat_movies',
        title: 'Top Sci-Fi Masterpieces',
        description: 'Mind-bending science fiction movies that explored space, time, and human consciousness.',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        itemsCount: 5,
      ),
    ]);

    // Seed Items
    _mockItems.addAll([
      // RPG Games
      ItemModel(id: 'item_witcher3', listId: 'list_rpg', name: 'The Witcher 3: Wild Hunt', description: 'Geralt of Rivia searches for his adopted daughter Ciri in a massive dark fantasy world.', imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&q=80&w=200', score: 95.0, votesCount: 10),
      ItemModel(id: 'item_skyrim', listId: 'list_rpg', name: 'The Elder Scrolls V: Skyrim', description: 'The Dragonborn rises to defeat Alduin the World-Eater in the snowy province of Skyrim.', imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=200', score: 87.0, votesCount: 10),
      ItemModel(id: 'item_eldenring', listId: 'list_rpg', name: 'Elden Ring', description: 'Rise, Tarnished, and be guided by grace to brandish the power of the Elden Ring.', imageUrl: 'https://images.unsplash.com/photo-1655821888788-6107699e173b?auto=format&fit=crop&q=80&w=200', score: 92.0, votesCount: 10),
      ItemModel(id: 'item_persona5', listId: 'list_rpg', name: 'Persona 5 Royal', description: 'High school students moonlighting as vigilante Phantom Thieves in modern Tokyo.', imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&q=80&w=200', score: 76.0, votesCount: 10),
      ItemModel(id: 'item_chrono', listId: 'list_rpg', name: 'Chrono Trigger', description: 'Classic time-traveling JRPG masterpiece with multiple endings and incredible music.', imageUrl: 'https://images.unsplash.com/photo-1552820728-8b83bb6b773f?auto=format&fit=crop&q=80&w=200', score: 81.0, votesCount: 10),

      // Sci-Fi Movies
      ItemModel(id: 'item_inception', listId: 'list_scifi', name: 'Inception', description: 'A thief who steals corporate secrets through the use of dream-sharing technology.', imageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=200', score: 94.0, votesCount: 10),
      ItemModel(id: 'item_interstellar', listId: 'list_scifi', name: 'Interstellar', description: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.', imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&q=80&w=200', score: 91.0, votesCount: 10),
      ItemModel(id: 'item_matrix', listId: 'list_scifi', name: 'The Matrix', description: 'A computer hacker learns from mysterious rebels about the true nature of his reality.', imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&q=80&w=200', score: 88.0, votesCount: 10),
      ItemModel(id: 'item_blade_runner', listId: 'list_scifi', name: 'Blade Runner 2049', description: 'A new blade runner unearths a long-buried secret that has the potential to plunge what\'s left of society into chaos.', imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&q=80&w=200', score: 82.0, votesCount: 10),
      ItemModel(id: 'item_2001', listId: 'list_scifi', name: '2001: A Space Odyssey', description: 'Stanley Kubrick\'s grand epic about humanity\'s evolution and the mysteries of the cosmos.', imageUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&q=80&w=200', score: 79.0, votesCount: 10),
    ]);
  }

  // --- BaseDatabaseService Implementation ---

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(_mockCategories);
    } else {
      try {
        final query = await _firestore!.collection('categories').orderBy('createdAt', descending: true).get();
        return query.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        print("Firestore failed, returning mocks: $e");
        return getCategories(); // Switch will happen in catch block internally or we can recurse with useMock = true
      }
    }
  }

  @override
  Future<CategoryModel> createCategory(String name, String description, String? imageUrl, String userId) async {
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final newCategory = CategoryModel(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _mockCategories.insert(0, newCategory);
      return newCategory;
    } else {
      await _firestore!.collection('categories').doc(id).set(newCategory.toMap());
      return newCategory;
    }
  }

  @override
  Future<List<RankingListModel>> getRankingLists(String categoryId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockRankingLists.where((list) => list.categoryId == categoryId).toList();
    } else {
      final query = await _firestore!
          .collection('ranking_lists')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs.map((doc) => RankingListModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  @override
  Future<RankingListModel> createRankingList(String categoryId, String title, String description, String userId) async {
    final id = 'list_${DateTime.now().millisecondsSinceEpoch}';
    final newList = RankingListModel(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      createdBy: userId,
      createdAt: DateTime.now(),
      itemsCount: 0,
    );

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _mockRankingLists.insert(0, newList);
      return newList;
    } else {
      await _firestore!.collection('ranking_lists').doc(id).set(newList.toMap());
      return newList;
    }
  }

  @override
  Future<List<ItemModel>> getItems(String listId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockItems.where((item) => item.listId == listId).toList();
    } else {
      final query = await _firestore!.collection('items').where('listId', isEqualTo: listId).get();
      return query.docs.map((doc) => ItemModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  @override
  Future<ItemModel> createItem(String listId, String name, String description, String? imageUrl) async {
    final id = 'item_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = ItemModel(
      id: id,
      listId: listId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      score: 0.0,
      votesCount: 0,
    );

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _mockItems.add(newItem);
      
      // Update item count on list
      final idx = _mockRankingLists.indexWhere((l) => l.id == listId);
      if (idx != -1) {
        final list = _mockRankingLists[idx];
        _mockRankingLists[idx] = RankingListModel(
          id: list.id,
          categoryId: list.categoryId,
          title: list.title,
          description: list.description,
          createdBy: list.createdBy,
          createdAt: list.createdAt,
          itemsCount: list.itemsCount + 1,
        );
      }
      return newItem;
    } else {
      await _firestore!.collection('items').doc(id).set(newItem.toMap());
      
      // Increment itemsCount on ranking_list doc
      await _firestore!.collection('ranking_lists').doc(listId).update({
        'itemsCount': FieldValue.increment(1),
      });
      return newItem;
    }
  }

  @override
  Future<void> submitVote(String listId, String userId, String userName, List<String> rankedItemIds) async {
    final id = 'vote_${DateTime.now().millisecondsSinceEpoch}';
    final newVote = VoteModel(
      id: id,
      listId: listId,
      userId: userId,
      userName: userName,
      rankedItemIds: rankedItemIds,
      createdAt: DateTime.now(),
    );

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove any existing vote by this user on this list
      _mockVotes.removeWhere((v) => v.listId == listId && v.userId == userId);
      _mockVotes.add(newVote);

      // Recalculate scores for all items in this list
      _recalculateMockLeaderboard(listId);
    } else {
      // Use Firestore Write Batch
      final batch = _firestore!.batch();
      
      final voteRef = _firestore!.collection('votes').doc('${userId}_$listId');
      batch.set(voteRef, newVote.toMap());

      await batch.commit();

      // In production, we'd trigger a Cloud Function or perform client-side transaction
      // For immediate client demonstration in Firestore mode:
      await _recalculateFirestoreLeaderboard(listId);
    }
  }

  // Borda Count Recalculation (Memory)
  void _recalculateMockLeaderboard(String listId) {
    // Get all votes for this list
    final votes = _mockVotes.where((v) => v.listId == listId).toList();
    
    // Get all items for this list
    final items = _mockItems.where((item) => item.listId == listId).toList();
    
    // Reset points
    final Map<String, double> itemScores = { for (var item in items) item.id : 0.0 };
    final Map<String, int> itemVotes = { for (var item in items) item.id : 0 };

    for (var vote in votes) {
      for (int i = 0; i < vote.rankedItemIds.length; i++) {
        final itemId = vote.rankedItemIds[i];
        if (itemScores.containsKey(itemId)) {
          // Borda Count: 1st place (index 0) gets 10 pts, 2nd gets 9 pts, ..., 10th gets 1 pt
          final points = (10 - i).clamp(1, 10).toDouble();
          itemScores[itemId] = itemScores[itemId]! + points;
          itemVotes[itemId] = itemVotes[itemId]! + 1;
        }
      }
    }

    // Update the static items list
    for (int i = 0; i < _mockItems.length; i++) {
      final item = _mockItems[i];
      if (item.listId == listId) {
        _mockItems[i] = item.copyWith(
          score: itemScores[item.id] ?? 0.0,
          votesCount: itemVotes[item.id] ?? 0,
        );
      }
    }
  }

  // Borda Count Recalculation (Firestore)
  Future<void> _recalculateFirestoreLeaderboard(String listId) async {
    final votesSnap = await _firestore!.collection('votes').where('listId', isEqualTo: listId).get();
    final itemsSnap = await _firestore!.collection('items').where('listId', isEqualTo: listId).get();

    final votes = votesSnap.docs.map((doc) => VoteModel.fromMap(doc.data(), doc.id)).toList();
    final items = itemsSnap.docs.map((doc) => ItemModel.fromMap(doc.data(), doc.id)).toList();

    final Map<String, double> itemScores = { for (var item in items) item.id : 0.0 };
    final Map<String, int> itemVotes = { for (var item in items) item.id : 0 };

    for (var vote in votes) {
      for (int i = 0; i < vote.rankedItemIds.length; i++) {
        final itemId = vote.rankedItemIds[i];
        if (itemScores.containsKey(itemId)) {
          final points = (10 - i).clamp(1, 10).toDouble();
          itemScores[itemId] = itemScores[itemId]! + points;
          itemVotes[itemId] = itemVotes[itemId]! + 1;
        }
      }
    }

    // Update each item in Firestore
    final batch = _firestore!.batch();
    for (var item in items) {
      final itemRef = _firestore!.collection('items').doc(item.id);
      batch.update(itemRef, {
        'score': itemScores[item.id] ?? 0.0,
        'votesCount': itemVotes[item.id] ?? 0,
      });
    }
    await batch.commit();
  }

  @override
  Future<List<ItemModel>> getLeaderboard(String listId) async {
    final items = await getItems(listId);
    // Sort by score descending, then by name
    items.sort((a, b) {
      int scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.name.compareTo(b.name);
    });
    return items;
  }

  @override
  Stream<List<ItemModel>> streamLeaderboard(String listId) {
    if (useMock) {
      // Return a stream that emits when items change or just emits once immediately
      return Stream.periodic(const Duration(seconds: 1), (_) {
        final items = _mockItems.where((item) => item.listId == listId).toList();
        items.sort((a, b) => b.score.compareTo(a.score));
        return items;
      }).distinct((prev, next) {
        if (prev.length != next.length) return false;
        for (int i = 0; i < prev.length; i++) {
          if (prev[i].id != next[i].id || prev[i].score != next[i].score) return false;
        }
        return true;
      });
    } else {
      return _firestore!
          .collection('items')
          .where('listId', isEqualTo: listId)
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) => ItemModel.fromMap(doc.data(), doc.id)).toList();
        items.sort((a, b) => b.score.compareTo(a.score));
        return items;
      });
    }
  }

  @override
  Future<List<VoteModel>> getUserVotes(String userId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockVotes.where((v) => v.userId == userId).toList();
    } else {
      final query = await _firestore!.collection('votes').where('userId', isEqualTo: userId).get();
      return query.docs.map((doc) => VoteModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  @override
  Future<List<RankingListModel>> getUserCreatedLists(String userId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockRankingLists.where((l) => l.createdBy == userId).toList();
    } else {
      final query = await _firestore!.collection('ranking_lists').where('createdBy', isEqualTo: userId).get();
      return query.docs.map((doc) => RankingListModel.fromMap(doc.data(), doc.id)).toList();
    }
  }
}
