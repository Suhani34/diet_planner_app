import 'food_item.dart';

class MealPlan {
  final String planId;
  final String profileKey;
  final DateTime createdAt;
  final Map<String, List<FoodItem>> meals;

  const MealPlan({
    required this.planId,
    required this.profileKey,
    required this.createdAt,
    required this.meals,
  });
}
