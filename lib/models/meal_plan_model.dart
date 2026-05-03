//meal_plan_model.dart
class MealItem {
  final String name;
  final num calories;
  final num proteinG;
  final num carbsG;
  final num fatsG;

  MealItem({
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    // Try different keys for the name
    String name = json["name"] ?? json["dish"] ?? json["food"] ?? json["item"] ?? "Healthy Dish";
    
    return MealItem(
      name: name,
      calories: json["calories"] ?? 0,
      proteinG: json["protein_g"] ?? json["protein"] ?? 0,
      carbsG: json["carbs_g"] ?? json["carbs"] ?? 0,
      fatsG: json["fats_g"] ?? json["fat"] ?? 0,
    );
  }
}

class MealPlanModel {
  final int dayNumber;
  final num totalCalories;
  final num proteinG;
  final num carbsG;
  final num fatsG;
  final Map<String, List<MealItem>> meals;

  MealPlanModel({
    required this.dayNumber,
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.meals,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    final rawMeals = (json["meals"] as Map<String, dynamic>? ?? {});
    final parsedMeals = <String, List<MealItem>>{};

    rawMeals.forEach((key, value) {
      if (value is List) {
        final list = (value)
            .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
            .toList();
        parsedMeals[key] = list;
      } else if (value is Map<String, dynamic>) {
        // AI sent a single object instead of a list, wrap it in a list
        parsedMeals[key] = [MealItem.fromJson(value)];
      }
    });

    return MealPlanModel(
      dayNumber: json["day_number"] ?? 1,
      totalCalories: json["total_calories"] ?? 0,
      proteinG: json["protein_g"] ?? 0,
      carbsG: json["carbs_g"] ?? 0,
      fatsG: json["fats_g"] ?? 0,
      meals: parsedMeals,
    );
  }
}