import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/models/food.dart';

/// ApiService that fetches meal data from TheMealDB (open API)
/// Docs: https://www.themealdb.com/api.php
class ApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  /// Fetch a list of meals. If [query] is empty, fetches a generic list using search.php?s=
  Future<List<Food>> fetchFoods({String query = ''}) async {
    final url = Uri.parse('$_base/search.php').replace(
      queryParameters: {'s': query},
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch meals: ${res.statusCode}');
    }
    final Map<String, dynamic> body =
        json.decode(res.body) as Map<String, dynamic>;
    final meals = body['meals'] as List<dynamic>?;
    if (meals == null) return <Food>[];

    return meals.map((m) {
      final Map<String, dynamic> meal = Map<String, dynamic>.from(m as Map);
      // Assign a dynamic price between 5.99 and 19.99 for demo purposes
      final idNumber = int.tryParse(meal['idMeal']?.toString() ?? '') ?? 0;
      final price = 5.99 + (idNumber % 1400) / 100;
      return Food.fromMap({
        'idMeal': meal['idMeal'],
        'strMeal': meal['strMeal'],
        'strInstructions': meal['strInstructions'],
        'strMealThumb': meal['strMealThumb'],
        'strCategory': meal['strCategory'],
        'strArea': meal['strArea'],
        'strTags': meal['strTags'],
        'price': price,
      });
    }).toList();
  }
}
