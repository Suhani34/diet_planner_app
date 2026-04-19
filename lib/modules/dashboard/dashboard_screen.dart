import 'package:flutter/material.dart';
import '../diet/food_item.dart';
import '../diet/meal_plan.dart';
import '../diet/meal_detail_screen.dart';
import '../../widgets/app_background.dart';

class DashboardScreen extends StatelessWidget {
  final MealPlan? mealPlan;
  final bool isPlanLocked;

  /// Signup flow se aane par user ki height/weight — BMI yahi se निकलेगा।
  final double? heightCm;
  final double? weightKg;

  const DashboardScreen({
    super.key,
    this.mealPlan,
    this.isPlanLocked = false,
    this.heightCm,
    this.weightKg,
  });

  @override
  Widget build(BuildContext context) {
    final defaultMeals = [
      {
        "title": "Breakfast",
        "icon": Icons.free_breakfast_rounded,
        "color": const Color(0xFFF6B7C3),
        "foods": const [
          FoodItem(
            name: "Oats with Milk",
            calories: 320,
            protein: 12,
            carbs: 45,
            fat: 9,
            serving: "1 bowl",
          ),
          FoodItem(
            name: "Banana",
            calories: 105,
            protein: 1.3,
            carbs: 27,
            fat: 0.3,
            serving: "1 medium",
          ),
        ],
      },
      {
        "title": "Lunch",
        "icon": Icons.lunch_dining_rounded,
        "color": const Color(0xFFFFD59E),
        "foods": const [
          FoodItem(
            name: "Brown Rice",
            calories: 220,
            protein: 5,
            carbs: 46,
            fat: 1.8,
            serving: "1 cup",
          ),
          FoodItem(
            name: "Grilled Paneer",
            calories: 280,
            protein: 18,
            carbs: 6,
            fat: 20,
            serving: "120 g",
          ),
        ],
      },
      {
        "title": "Snack",
        "icon": Icons.cookie_rounded,
        "color": const Color(0xFFC9C4F7),
        "foods": const [
          FoodItem(
            name: "Greek Yogurt",
            calories: 120,
            protein: 10,
            carbs: 8,
            fat: 4,
            serving: "150 g",
          ),
          FoodItem(
            name: "Almonds",
            calories: 80,
            protein: 3,
            carbs: 3,
            fat: 7,
            serving: "12 pieces",
          ),
        ],
      },
      {
        "title": "Dinner",
        "icon": Icons.dinner_dining_rounded,
        "color": const Color(0xFFAEDDC8),
        "foods": const [
          FoodItem(
            name: "Chapati",
            calories: 140,
            protein: 4,
            carbs: 24,
            fat: 3,
            serving: "2 pieces",
          ),
          FoodItem(
            name: "Dal Tadka",
            calories: 190,
            protein: 11,
            carbs: 21,
            fat: 7,
            serving: "1 bowl",
          ),
        ],
      },
    ];

    final mealMap = mealPlan?.meals ??
        {
          for (final meal in defaultMeals)
            meal["title"] as String: meal["foods"] as List<FoodItem>,
        };
    final meals = mealMap.entries
        .map(
          (entry) => {
            "title": entry.key,
            "foods": entry.value,
            "icon": _mealIcon(entry.key),
            "color": _mealColor(entry.key),
          },
        )
        .toList();

    final allFoods = meals
        .map((meal) => meal["foods"] as List<FoodItem>)
        .expand((foods) => foods)
        .toList();
    final consumedCalories =
        allFoods.fold<int>(0, (sum, food) => sum + food.calories);
    const calorieGoal = 2200;
    final totalProtein = allFoods.fold<double>(0, (s, f) => s + f.protein);
    final totalCarbs = allFoods.fold<double>(0, (s, f) => s + f.carbs);
    final totalFat = allFoods.fold<double>(0, (s, f) => s + f.fat);
    final proteinGoal = (calorieGoal * 0.25 / 4).round();
    final carbsGoal = (calorieGoal * 0.45 / 4).round();
    final fatGoal = (calorieGoal * 0.30 / 9).round();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topGreetingCard(),
                const SizedBox(height: 18),
                const Text(
                  "Your Daily Balance",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Day 1",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                if (isPlanLocked) ...[
                  const _PlanLockBanner(),
                  const SizedBox(height: 14),
                ],
                _MacroChartCard(
                  consumedCalories: consumedCalories,
                  calorieGoal: calorieGoal,
                  protein: totalProtein,
                  carbs: totalCarbs,
                  fat: totalFat,
                  proteinGoal: proteinGoal,
                  carbsGoal: carbsGoal,
                  fatGoal: fatGoal,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: meals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return _MealCard(
                        title: meal["title"] as String,
                        icon: meal["icon"] as IconData,
                        color: meal["color"] as Color,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealDetailScreen(
                                mealName: meal["title"] as String,
                                foods: meal["foods"] as List<FoodItem>,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _bottomNavBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topGreetingCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFF2D8C9),
              child: Icon(
                Icons.person,
                size: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Hello, User",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            isSelected: true,
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            isSelected: false,
          ),
          _NavItem(
            icon: Icons.bookmark_border_rounded,
            isSelected: false,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            isSelected: false,
          ),
        ],
      ),
    );
  }

  IconData _mealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case "breakfast":
        return Icons.free_breakfast_rounded;
      case "lunch":
        return Icons.lunch_dining_rounded;
      case "snack":
        return Icons.cookie_rounded;
      case "dinner":
        return Icons.dinner_dining_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _mealColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case "breakfast":
        return const Color(0xFFF6B7C3);
      case "lunch":
        return const Color(0xFFFFD59E);
      case "snack":
        return const Color(0xFFC9C4F7);
      case "dinner":
        return const Color(0xFFAEDDC8);
      default:
        return const Color(0xFFE7D9CC);
    }
  }
}

class _PlanLockBanner extends StatelessWidget {
  const _PlanLockBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAFE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_rounded, color: Color(0xFF6E61F4)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "AI meal plan generated and locked for selected parameters.",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF423A66),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroChartCard extends StatelessWidget {
  final int consumedCalories;
  final int calorieGoal;
  final double protein;
  final double carbs;
  final double fat;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const _MacroChartCard({
    required this.consumedCalories,
    required this.calorieGoal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = calorieGoal - consumedCalories;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F2),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4CF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFF29D72),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$consumedCalories / $calorieGoal kcal",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
              ),
              Text(
                "${remaining > 0 ? remaining : 0} left",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: const MacroRingPainter(),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Consumed",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$consumedCalories",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF262626),
                            ),
                          ),
                          const Text(
                            "kcal",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: const Color(0xFFF6B7C3),
                      title: "Fat",
                      value: "${fat.toStringAsFixed(0)}/${fatGoal}g",
                    ),
                    const SizedBox(height: 14),
                    _LegendItem(
                      color: const Color(0xFFFFC98B),
                      title: "Protein",
                      value: "${protein.toStringAsFixed(0)}/${proteinGoal}g",
                    ),
                    const SizedBox(height: 14),
                    _LegendItem(
                      color: const Color(0xFFC8C4F8),
                      title: "Carbs",
                      value: "${carbs.toStringAsFixed(0)}/${carbsGoal}g",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _LegendItem({
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF262626),
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF7F2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4A4A4A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262626),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF262238) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black38,
        size: 22,
      ),
    );
  }
}

class MacroRingPainter extends CustomPainter {
  const MacroRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 14.0;
    final radius = (size.width / 2) - 18;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF2ECE6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    void drawArc(Color color, double startAngle, double sweepAngle) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    drawArc(const Color(0xFFFFC98B), 2.7, 1.1);
    drawArc(const Color(0xFFF6B7C3), 4.0, 1.25);
    drawArc(const Color(0xFFC8C4F8), 5.5, 1.2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
