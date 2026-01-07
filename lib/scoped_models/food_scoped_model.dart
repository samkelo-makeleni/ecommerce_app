import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/models/food.dart';
import 'package:ecommerce_app/services/api_service.dart';

/// Scoped-style model implemented as a ChangeNotifier (works with Provider).
class FoodScopedModel extends ChangeNotifier {
  final ApiService _api;

  List<Food> _items = [];
  Food? _selected;
  bool _loading = false;

  // in-memory cache keyed by query
  final Map<String, List<Food>> _cache = {};

  FoodScopedModel({ApiService? api}) : _api = api ?? ApiService();

  List<Food> get items => List.unmodifiable(_items);
  Food? get selected => _selected;
  bool get isLoading => _loading;
  String? get error => _error;

  String? _error;

  Future<void> loadFoods({String query = ''}) async {
    _loading = true;
    notifyListeners();

    // check in-memory cache first
    if (_cache.containsKey(query)) {
      _items = _cache[query]!;
      _loading = false;
      notifyListeners();
      return;
    }

    _error = null;
    try {
      final result = await _api.fetchFoods(query: query);
      _items = result;
      _cache[query] = result;
      // persist last result for offline fallback
      await _saveCacheToPrefs(query, result);
    } catch (e) {
      _error = e.toString();
      // try to load from prefs fallback
      final fromPrefs = await _loadCacheFromPrefs(query);
      if (fromPrefs != null) {
        _items = fromPrefs;
      } else {
        _items = [];
      }
    }

    _loading = false;
    notifyListeners();
  }

  void select(Food f) {
    _selected = f;
    notifyListeners();
  }

  void clearSelection() {
    _selected = null;
    notifyListeners();
  }

  Future<void> _saveCacheToPrefs(String query, List<Food> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'cached_foods_${query.isEmpty ? 'all' : query}';
      final jsonStr = json.encode(list.map((e) => e.toMap()).toList());
      await prefs.setString(key, jsonStr);
    } catch (_) {}
  }

  Future<List<Food>?> _loadCacheFromPrefs(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'cached_foods_${query.isEmpty ? 'all' : query}';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return null;
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      return data.map((e) => Food.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return null;
    }
  }

  /// Find a food item by id from the current items or cached lists.
  Food? getById(String id) {
    for (final f in _items) {
      if (f.id == id) return f;
    }
    for (final entry in _cache.values) {
      for (final f in entry) {
        if (f.id == id) return f;
      }
    }
    return null;
  }
}
