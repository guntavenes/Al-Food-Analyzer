class ProductNutrition {
  const ProductNutrition({
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodiumMilligrams,
  });

  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final double? sodiumMilligrams;
}

class BarcodeProduct {
  const BarcodeProduct({
    required this.barcode,
    required this.name,
    required this.nutritionPer100g,
    required this.sourceName,
    required this.sourceUrl,
    this.brand,
    this.imageUrl,
    this.quantity,
    this.servingSize,
  });

  factory BarcodeProduct.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutritionPer100g'] as Map<String, dynamic>;
    double? number(String key) => (nutrition[key] as num?)?.toDouble();
    return BarcodeProduct(
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      quantity: json['quantity'] as String?,
      servingSize: json['servingSize'] as String?,
      nutritionPer100g: ProductNutrition(
        calories: number('calories'),
        protein: number('protein'),
        carbohydrates: number('carbohydrates'),
        fat: number('fat'),
        fiber: number('fiber'),
        sugar: number('sugar'),
        sodiumMilligrams: number('sodiumMilligrams'),
      ),
      sourceName: json['sourceName'] as String,
      sourceUrl: json['sourceUrl'] as String,
    );
  }

  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? quantity;
  final String? servingSize;
  final ProductNutrition nutritionPer100g;
  final String sourceName;
  final String sourceUrl;
}
