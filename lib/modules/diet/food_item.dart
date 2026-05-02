//food_item.dart
class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String serving;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.serving,
  });
}
