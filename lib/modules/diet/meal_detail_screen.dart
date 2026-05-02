//meal_detail_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import 'food_detail_screen.dart';
import 'food_item.dart';
import 'nutrition_widgets.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealName;
  final List<FoodItem> foods;

  const MealDetailScreen({
    super.key,
    required this.mealName,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories =
        foods.fold<int>(0, (sum, item) => sum + item.calories);
    final totalProtein =
        foods.fold<double>(0, (sum, item) => sum + item.protein);
    final totalCarbs = foods.fold<double>(0, (sum, item) => sum + item.carbs);
    final totalFat = foods.fold<double>(0, (sum, item) => sum + item.fat);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$mealName details",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NutritionCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: Color(0xFFF29D72)),
                          const SizedBox(width: 8),
                          Text(
                            "$totalCalories kcal",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            "${foods.length} foods",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MacroChip(
                            label: "Protein",
                            value: "${totalProtein.toStringAsFixed(1)}g",
                            color: const Color(0xFFFF9F6E),
                          ),
                          MacroChip(
                            label: "Carbs",
                            value: "${totalCarbs.toStringAsFixed(1)}g",
                            color: const Color(0xFF7D7BF8),
                          ),
                          MacroChip(
                            label: "Fat",
                            value: "${totalFat.toStringAsFixed(1)}g",
                            color: const Color(0xFFF27DA8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Food list",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: foods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return NutritionCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(food: food),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4E6DB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    const Icon(Icons.restaurant_menu_rounded),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${food.calories} kcal | ${food.serving}",
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
