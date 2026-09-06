class MenuAnalysis {
  const MenuAnalysis({
    required this.summary,
    required this.recommendedItemName,
    required this.confidencePercent,
    required this.items,
    this.restaurantName,
  });

  factory MenuAnalysis.fromJson(Map<String, Object?> json) {
    return MenuAnalysis(
      restaurantName: json['restaurantName'] as String?,
      summary: json['summary'] as String,
      recommendedItemName: json['recommendedItemName'] as String,
      confidencePercent: (((json['confidence'] as num).toDouble()) * 100)
          .round(),
      items: (json['items'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(MenuItemAnalysis.fromJson)
          .toList(growable: false),
    );
  }

  final String? restaurantName;
  final String summary;
  final String recommendedItemName;
  final int confidencePercent;
  final List<MenuItemAnalysis> items;
}

class MenuItemAnalysis {
  const MenuItemAnalysis({
    required this.name,
    required this.description,
    required this.minimumCalories,
    required this.maximumCalories,
    required this.healthScore,
    required this.reasons,
    required this.concerns,
  });

  factory MenuItemAnalysis.fromJson(Map<String, Object?> json) {
    return MenuItemAnalysis(
      name: json['name'] as String,
      description: json['description'] as String,
      minimumCalories: (json['estimatedCaloriesMin'] as num).round(),
      maximumCalories: (json['estimatedCaloriesMax'] as num).round(),
      healthScore: (json['healthScore'] as num).round(),
      reasons: (json['reasons'] as List<Object?>).cast<String>(),
      concerns: (json['concerns'] as List<Object?>).cast<String>(),
    );
  }

  final String name;
  final String description;
  final int minimumCalories;
  final int maximumCalories;
  final int healthScore;
  final List<String> reasons;
  final List<String> concerns;
}
