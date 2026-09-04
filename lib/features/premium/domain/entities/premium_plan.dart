class PremiumPlan {
  const PremiumPlan({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.isYearly,
  });

  final String productId;
  final String title;
  final String description;
  final String price;
  final bool isYearly;
}
