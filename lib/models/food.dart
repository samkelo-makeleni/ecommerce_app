class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? category;
  final String? area;
  final List<String>? tags;

  const Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.category,
    this.area,
    this.tags,
  });

  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id: (m['id'] ?? m['idMeal'] ?? '') as String,
        name: (m['name'] ?? m['strMeal'] ?? 'Unknown') as String,
        description: (m['description'] ?? m['strInstructions'] ?? '') as String,
        price: ((m['price'] is num)
            ? (m['price'] as num).toDouble()
            : (m['price'] != null
                ? double.tryParse(m['price'].toString()) ?? 9.99
                : 9.99)),
        image: (m['image'] ?? m['strMealThumb'] ?? 'assets/images/food11.jpeg')
            as String,
        category: (m['strCategory'] ?? m['category']) as String?,
        area: (m['strArea'] ?? m['area']) as String?,
        tags: _parseTags(m['strTags'] ?? m['tags']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'category': category,
        'area': area,
        'tags': tags,
      };

  static List<String>? _parseTags(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      return raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return null;
  }
}
