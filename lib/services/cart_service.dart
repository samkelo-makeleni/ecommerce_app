import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/models/food.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final Food food;
  final int quantity;

  const CartItem({
    required this.food,
    required this.quantity,
  });

  CartItem copyWith({Food? food, int? quantity}) => CartItem(
        food: food ?? this.food,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toMap() => {
        'food': food.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        food: Food.fromMap(Map<String, dynamic>.from(map['food'] as Map)),
        quantity: (map['quantity'] as num).toInt(),
      );
}

/// Lightweight cart service (ChangeNotifier) used as a provider-backed service.
class CartService extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  CartService() {
    // load saved cart asynchronously
    _loadFromPrefs();
  }

  List<CartItem> get items => List.unmodifiable(_items.values);

  int get totalItems => _items.values.fold(0, (a, b) => a + b.quantity);

  double get totalPrice => _items.values.fold(
        0,
        (total, item) => total + item.food.price * item.quantity,
      );

  bool get isEmpty => _items.isEmpty;

  void addFood(Food food, {int qty = 1}) {
    final current = _items[food.id];
    _items[food.id] = CartItem(
      food: food,
      quantity: (current?.quantity ?? 0) + qty,
    );
    notifyListeners();
    _saveToPrefs();
  }

  void removeItem(String id, {int qty = 1}) {
    if (!_items.containsKey(id)) return;
    final current = _items[id]!;
    final newQty = current.quantity - qty;
    if (newQty <= 0) {
      _items.remove(id);
    } else {
      _items[id] = current.copyWith(quantity: newQty);
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
      await prefs.setString(
        'cart_items',
        json.encode(_items.map((id, item) => MapEntry(id, item.toMap()))),
      );
    } catch (e) {
      debugPrint('Failed to save cart: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cart_items');
      if (raw == null) return;
      final Map<String, dynamic> data =
          json.decode(raw) as Map<String, dynamic>;
      _items.clear();
      data.forEach((k, v) {
        if (v is Map && v.containsKey('food')) {
          _items[k] = CartItem.fromMap(Map<String, dynamic>.from(v));
        } else if (v is num) {
          _items[k] = CartItem(
            food: Food(
              id: k,
              name: k,
              description: '',
              price: 0,
              image: 'assets/images/food11.jpeg',
            ),
            quantity: v.toInt(),
          );
        }
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load cart: $e');
    }
  }
}
