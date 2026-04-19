import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'food_item.dart';
import 'meal_plan.dart';

class MealPlanService {
  static const _plansStorageKey = "meal_plans_locked_v1";

  Future<MealPlanResult> generateOrGetLockedPlan({
    required Map<String, dynamic> profileParams,
  }) async {
    final normalizedProfile = _normalize(profileParams);
    final profileKey = jsonEncode(normalizedProfile);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_plansStorageKey);
    final map = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;

    if (map.containsKey(profileKey)) {
      final savedPlan = _fromJson(map[profileKey] as Map<String, dynamic>);
      return MealPlanResult(plan: savedPlan, wasNewlyGenerated: false);
    }

    final generatedPlan = _generatePlan(profileKey, normalizedProfile);
    map[profileKey] = _toJson(generatedPlan);
    await prefs.setString(_plansStorageKey, jsonEncode(map));
    return MealPlanResult(plan: generatedPlan, wasNewlyGenerated: true);
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> params) {
    final entries = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return {
      for (final entry in entries)
        entry.key: entry.value is List
            ? (() {
                final list =
                    (entry.value as List).map((e) => e.toString()).toList();
                list.sort();
                return list;
              })()
            : entry.value,
    };
  }

  MealPlan _generatePlan(String profileKey, Map<String, dynamic> profile) {
    final seed = profileKey.codeUnits.fold<int>(0, (sum, value) => sum + value);
    final isVegetarian = (profile["dietPreference"] ?? "")
        .toString()
        .toLowerCase()
        .contains("veg");
    final goal = (profile["goal"] ?? "").toString().toLowerCase();
    final targetKcal = goal.contains("gain")
        ? 2500
        : goal.contains("maintain")
            ? 2200
            : 1800;

    List<FoodItem> breakfast = isVegetarian
        ? const [
            FoodItem(
                name: "Oats Porridge",
                calories: 290,
                protein: 11,
                carbs: 47,
                fat: 6,
                serving: "1 bowl"),
            FoodItem(
                name: "Seasonal Fruit",
                calories: 90,
                protein: 1,
                carbs: 22,
                fat: 0,
                serving: "1 serving"),
          ]
        : const [
            FoodItem(
                name: "Egg Omelette",
                calories: 230,
                protein: 16,
                carbs: 3,
                fat: 16,
                serving: "2 eggs"),
            FoodItem(
                name: "Whole Wheat Toast",
                calories: 120,
                protein: 4,
                carbs: 22,
                fat: 2,
                serving: "2 slices"),
          ];

    List<FoodItem> lunch = isVegetarian
        ? const [
            FoodItem(
                name: "Brown Rice",
                calories: 220,
                protein: 5,
                carbs: 46,
                fat: 2,
                serving: "1 cup"),
            FoodItem(
                name: "Paneer Bhurji",
                calories: 280,
                protein: 18,
                carbs: 8,
                fat: 18,
                serving: "1 bowl"),
          ]
        : const [
            FoodItem(
                name: "Chicken Breast",
                calories: 280,
                protein: 40,
                carbs: 0,
                fat: 8,
                serving: "150 g"),
            FoodItem(
                name: "Steamed Rice",
                calories: 210,
                protein: 4,
                carbs: 45,
                fat: 1,
                serving: "1 cup"),
          ];

    List<FoodItem> snack = const [
      FoodItem(
          name: "Greek Yogurt",
          calories: 120,
          protein: 10,
          carbs: 8,
          fat: 4,
          serving: "150 g"),
      FoodItem(
          name: "Almonds",
          calories: 85,
          protein: 3,
          carbs: 3,
          fat: 7,
          serving: "12 pieces"),
    ];

    List<FoodItem> dinner = isVegetarian
        ? const [
            FoodItem(
                name: "Chapati",
                calories: 150,
                protein: 5,
                carbs: 26,
                fat: 3,
                serving: "2 pieces"),
            FoodItem(
                name: "Dal",
                calories: 200,
                protein: 11,
                carbs: 24,
                fat: 6,
                serving: "1 bowl"),
          ]
        : const [
            FoodItem(
                name: "Fish Curry",
                calories: 260,
                protein: 28,
                carbs: 6,
                fat: 13,
                serving: "1 bowl"),
            FoodItem(
                name: "Chapati",
                calories: 150,
                protein: 5,
                carbs: 26,
                fat: 3,
                serving: "2 pieces"),
          ];

    // Add a tiny deterministic variation so different profiles get distinct plans.
    if (seed % 2 == 0) {
      snack = [
        ...snack,
        const FoodItem(
          name: "Buttermilk",
          calories: 60,
          protein: 3,
          carbs: 7,
          fat: 2,
          serving: "1 glass",
        ),
      ];
    }

    final meals = {
      "Breakfast": breakfast,
      "Lunch": lunch,
      "Snack": snack,
      "Dinner": dinner,
    };

    return MealPlan(
      planId: "plan_${DateTime.now().millisecondsSinceEpoch}_$targetKcal",
      profileKey: profileKey,
      createdAt: DateTime.now(),
      meals: meals,
    );
  }

  Map<String, dynamic> _toJson(MealPlan plan) {
    return {
      "planId": plan.planId,
      "profileKey": plan.profileKey,
      "createdAt": plan.createdAt.toIso8601String(),
      "meals": {
        for (final entry in plan.meals.entries)
          entry.key: entry.value
              .map(
                (food) => {
                  "name": food.name,
                  "calories": food.calories,
                  "protein": food.protein,
                  "carbs": food.carbs,
                  "fat": food.fat,
                  "serving": food.serving,
                },
              )
              .toList(),
      },
    };
  }

  MealPlan _fromJson(Map<String, dynamic> json) {
    final mealsRaw = json["meals"] as Map<String, dynamic>;
    return MealPlan(
      planId: json["planId"] as String,
      profileKey: json["profileKey"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
      meals: {
        for (final entry in mealsRaw.entries)
          entry.key: (entry.value as List)
              .map(
                (item) => FoodItem(
                  name: (item as Map<String, dynamic>)["name"] as String,
                  calories: item["calories"] as int,
                  protein: (item["protein"] as num).toDouble(),
                  carbs: (item["carbs"] as num).toDouble(),
                  fat: (item["fat"] as num).toDouble(),
                  serving: item["serving"] as String,
                ),
              )
              .toList(),
      },
    );
  }
}

class MealPlanResult {
  final MealPlan plan;
  final bool wasNewlyGenerated;

  const MealPlanResult({
    required this.plan,
    required this.wasNewlyGenerated,
  });
}
