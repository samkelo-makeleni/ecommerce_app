import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight cart service (ChangeNotifier) used as a provider-backed service.
class CartService extends ChangeNotifier {
  final Map<String, int> _items = {};

  CartService() {
    // load saved cart asynchronously
    _loadFromPrefs();
  }

  Map<String, int> get items => Map.unmodifiable(_items);

  int get totalItems => _items.values.fold(0, (a, b) => a + b);

  void addItem(String id, {int qty = 1}) {
    _items[id] = (_items[id] ?? 0) + qty;
    notifyListeners();
    _saveToPrefs();
  }

  void removeItem(String id, {int qty = 1}) {
    if (!_items.containsKey(id)) return;
    final newQty = (_items[id] ?? 0) - qty;
    if (newQty <= 0) {
      _items.remove(id);
    } else {
      _items[id] = newQty;
    }
    notifyListeners();
    _saveToPrefs();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart_items', json.encode(_items));
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cart_items');
      if (raw == null) return;
      final Map<String, dynamic> data = json.decode(raw) as Map<String, dynamic>;
      _items.clear();
      data.forEach((k, v) => _items[k] = (v as num).toInt());
      notifyListeners();
    } catch (_) {}
  }
}
