//food_detail_screen.dart
import 'package:flutter/material.dart';

import '../../widgets/app_background.dart';
import 'food_item.dart';
import 'nutrition_widgets.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem food;

  const FoodDetailScreen({
    super.key,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    const proteinGoal = 30.0;
    const carbsGoal = 60.0;
    const fatGoal = 20.0;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(height: 8),
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  food.serving,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                NutritionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Food macronutrient display",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _InfoTile(
                            title: "Calories",
                            value: "${food.calories}",
                            suffix: "kcal",
                          ),
                          const SizedBox(width: 12),
                          _InfoTile(
                            title: "Serving",
                            value: food.serving,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MacronutrientBar(
                        label: "Protein",
                        color: const Color(0xFFFF9F6E),
                        value: food.protein,
                        target: proteinGoal,
                      ),
                      const SizedBox(height: 12),
                      MacronutrientBar(
                        label: "Carbs",
                        color: const Color(0xFF7D7BF8),
                        value: food.carbs,
                        target: carbsGoal,
                      ),
                      const SizedBox(height: 12),
                      MacronutrientBar(
                        label: "Fat",
                        color: const Color(0xFFF27DA8),
                        value: food.fat,
                        target: fatGoal,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                NutritionCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MacroChip(
                        label: "P",
                        value: "${food.protein.toStringAsFixed(1)}g",
                        color: const Color(0xFFFF9F6E),
                      ),
                      MacroChip(
                        label: "C",
                        value: "${food.carbs.toStringAsFixed(1)}g",
                        color: const Color(0xFF7D7BF8),
                      ),
                      MacroChip(
                        label: "F",
                        value: "${food.fat.toStringAsFixed(1)}g",
                        color: const Color(0xFFF27DA8),
                      ),
                    ],
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

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;

  const _InfoTile({
    required this.title,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              suffix == null ? value : "$value $suffix",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2A2A2A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
