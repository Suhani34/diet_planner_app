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
    return MealItem(
      name: json["name"] ?? "",
      calories: json["calories"] ?? 0,
      proteinG: json["protein_g"] ?? 0,
      carbsG: json["carbs_g"] ?? 0,
      fatsG: json["fats_g"] ?? 0,
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
      final list = (value as List<dynamic>)
          .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList();
      parsedMeals[key] = list;
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