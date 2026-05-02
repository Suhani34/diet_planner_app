import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/meal_plan_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/bmi_summary_card.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../diet/food_item.dart';
import '../diet/meal_detail_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final MealPlanModel? mealPlan;
  final bool isPlanLocked;
  final double? heightCm;
  final double? weightKg;
  final bool shouldGenerateMeal;
  final Map<String, dynamic>? profilePayload;

  const DashboardScreen({
    super.key,
    this.mealPlan,
    this.isPlanLocked = false,
    this.heightCm,
    this.weightKg,
    this.shouldGenerateMeal = false,
    this.profilePayload,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  MealPlanModel? mealPlan;
  bool isLoadingMeal = false;
  String? mealError;

  @override
  void initState() {
    super.initState();
    mealPlan = widget.mealPlan;

    if (widget.shouldGenerateMeal) {
      _saveAndGenerateMeal();
    } else if (mealPlan == null) {
      _loadLatestMeal();
    }
  }

  Future<void> _saveAndGenerateMeal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isLoadingMeal = true;
      mealError = null;
    });

    try {
      if (widget.profilePayload != null) {
        await ApiService.saveProfile(widget.profilePayload!);
      }

      final json = await ApiService.generateMealPlan(user.uid);

      if (!mounted) return;

      setState(() {
        mealPlan = MealPlanModel.fromJson(json);
        isLoadingMeal = false;
      });
    } catch (e) {
      debugPrint("Generate meal failed: $e");

      if (!mounted) return;

      setState(() {
        mealError = "AI meal generation failed. Showing default dashboard.";
        isLoadingMeal = false;
      });
    }
  }

  Future<void> _loadLatestMeal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isLoadingMeal = true;
      mealError = null;
    });

    try {
      final json = await ApiService.getLatestMealPlan(user.uid);

      if (!mounted) return;

      setState(() {
        mealPlan = MealPlanModel.fromJson(json);
        isLoadingMeal = false;
      });
    } catch (e) {
      debugPrint("Latest meal load failed: $e");

      if (!mounted) return;

      setState(() {
        mealError = "No AI meal loaded yet.";
        isLoadingMeal = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  IconData _mealIcon(String mealName) {
    final key = mealName.toLowerCase();

    if (key.contains("breakfast")) return Icons.free_breakfast_rounded;
    if (key.contains("lunch")) return Icons.lunch_dining_rounded;
    if (key.contains("dinner")) return Icons.dinner_dining_rounded;
    if (key.contains("snack")) return Icons.cookie_rounded;

    return Icons.restaurant_rounded;
  }

  Color _mealColor(String mealName) {
    final key = mealName.toLowerCase();

    if (key.contains("breakfast")) return const Color(0xFFF6B7C3);
    if (key.contains("lunch")) return const Color(0xFFFFD59E);
    if (key.contains("dinner")) return const Color(0xFFAEDDC8);
    if (key.contains("snack")) return const Color(0xFFC9C4F7);

    return const Color(0xFFE7D9CC);
  }

  String _formatMealTitle(String key) {
    return key.replaceAll("_", " ").split(" ").map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(" ");
  }

  List<FoodItem> _convertMealItems(List<dynamic> items) {
    return items.map((item) {
      return FoodItem(
        name: item.name,
        calories: item.calories.toInt(),
        protein: item.proteinG.toDouble(),
        carbs: item.carbsG.toDouble(),
        fat: item.fatsG.toDouble(),
        serving: "",
      );
    }).toList();
  }

  List<Map<String, dynamic>> _defaultMeals() {
    return [
      {
        "title": "Breakfast",
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
            name: "Dal",
            calories: 190,
            protein: 11,
            carbs: 21,
            fat: 7,
            serving: "1 bowl",
          ),
        ],
      },
      {
        "title": "Dinner",
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
            name: "Vegetable Curry",
            calories: 180,
            protein: 5,
            carbs: 25,
            fat: 6,
            serving: "1 bowl",
          ),
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _mealsForUi() {
    if (mealPlan == null) {
      return _defaultMeals();
    }

    return mealPlan!.meals.entries.map((entry) {
      return {
        "title": _formatMealTitle(entry.key),
        "foods": _convertMealItems(entry.value),
      };
    }).toList();
  }

  void _openProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final profileData = await ApiService.getProfile(user.uid);
      if (!mounted) return;
      Navigator.pop(context); // close dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            name: user.displayName ?? "User",
            age: profileData["age"]?.toString() ?? "25",
            gender: profileData["gender"] ?? "Male",
            height: profileData["height_cm"]?.toString() ?? "170",
            weight: profileData["weight_kg"]?.toString() ?? "70",
            goal: profileData["goal"] ?? "Maintain Weight",
            activity: profileData["activity_level"] ?? "Sedentary",
            diet: profileData["dietary_preference"] ?? "Vegetarian",
            meals: profileData["meals_per_day"]?.toString() ?? "3",
            timeline: profileData["timeline"] ?? "1 Month",
            budget: profileData["budget"] ?? "Medium",
            cuisine: profileData["cuisine_preference"] ?? "Indian",
            allergies: List<String>.from(profileData["allergies"] ?? []),
            conditions: List<String>.from(profileData["medical_conditions"] ?? []),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not load profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final meals = _mealsForUi();

    final allFoods = meals
        .map((meal) => meal["foods"] as List<FoodItem>)
        .expand((foods) => foods)
        .toList();

    final calories = mealPlan?.totalCalories.toInt() ??
        allFoods.fold<int>(0, (sum, food) => sum + food.calories);

    final protein = mealPlan?.proteinG.toDouble() ??
        allFoods.fold<double>(0, (sum, food) => sum + food.protein);

    final carbs = mealPlan?.carbsG.toDouble() ??
        allFoods.fold<double>(0, (sum, food) => sum + food.carbs);

    final fats = mealPlan?.fatsG.toDouble() ??
        allFoods.fold<double>(0, (sum, food) => sum + food.fat);

    // Calculate BMI if height and weight are available
    double? bmi;
    String? bmiStatus;
    if (widget.heightCm != null && widget.weightKg != null) {
      final hM = widget.heightCm! / 100.0;
      bmi = widget.weightKg! / (hM * hM);
      bmiStatus = BmiSummaryCard.labelFor(bmi);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoadingMeal ? null : _saveAndGenerateMeal,
        backgroundColor: const Color(0xFFF29D72),
        icon: isLoadingMeal
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: const Text(
          "Generate AI Meal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  name: user?.displayName ?? "User",
                  email: user?.email ?? "Signed in",
                  onLogout: _handleLogout,
                  onProfileTap: _openProfile,
                ),
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
                Text(
                  mealPlan == null
                      ? "Default plan"
                      : "Day ${mealPlan!.dayNumber}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                if (isLoadingMeal)
                  const LinearProgressIndicator(
                    minHeight: 5,
                    color: Color(0xFFF29D72),
                  ),
                if (mealError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    mealError!,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (bmi != null && bmiStatus != null) ...[
                  BmiSummaryCard(
                    bmi: bmi,
                    status: bmiStatus,
                    compact: true,
                  ),
                  const SizedBox(height: 16),
                ],
                _MacroCard(
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fats: fats,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: meals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      final title = meal["title"] as String;
                      final foods = meal["foods"] as List<FoodItem>;

                      return _MealCard(
                        title: title,
                        icon: _mealIcon(title),
                        bgColor: _mealColor(title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealDetailScreen(
                                mealName: title,
                                foods: foods,
                              ),
                            ),
                          );
                        },
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

class _TopBar extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onLogout;
  final VoidCallback onProfileTap;

  const _TopBar({
    required this.name,
    required this.email,
    required this.onLogout,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            backgroundColor: Color(0xFFFFE9DA),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFFF29D72),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $name",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  const _MacroCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fats;

    final proteinPercent = total == 0 ? 0.0 : protein / total;
    final carbsPercent = total == 0 ? 0.0 : carbs / total;
    final fatsPercent = total == 0 ? 0.0 : fats / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F4),
        borderRadius: BorderRadius.circular(28),
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
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                painter: MacroRingPainter(
                  proteinPercent,
                  carbsPercent,
                  fatsPercent,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$calories",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626),
                        ),
                      ),
                      const Text(
                        "kcal",
                        style: TextStyle(
                          fontSize: 13,
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
              children: [
                _LegendItem(
                  color: const Color(0xFFFFC98B),
                  title: "Protein",
                  value: "${protein.toStringAsFixed(0)}g",
                ),
                const SizedBox(height: 14),
                _LegendItem(
                  color: const Color(0xFFC8C4F8),
                  title: "Carbs",
                  value: "${carbs.toStringAsFixed(0)}g",
                ),
                const SizedBox(height: 14),
                _LegendItem(
                  color: const Color(0xFFF6B7C3),
                  title: "Fats",
                  value: "${fats.toStringAsFixed(0)}g",
                ),
              ],
            ),
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
        const SizedBox(width: 8),
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
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final VoidCallback onTap;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8F4),
            borderRadius: BorderRadius.circular(26),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5B4B45),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
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

class MacroRingPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fats;

  MacroRingPainter(
    this.protein,
    this.carbs,
    this.fats,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 14.0;
    final radius = (size.shortestSide / 2) - 12;

    final basePaint = Paint()
      ..color = const Color(0xFFEFEAE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    double start = -1.5708;

    void drawArc(double percent, Color color) {
      if (percent <= 0) return;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweep = 6.28318 * percent;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );

      start += sweep;
    }

    drawArc(protein, const Color(0xFFFFC98B));
    drawArc(carbs, const Color(0xFFC8C4F8));
    drawArc(fats, const Color(0xFFF6B7C3));
  }

  @override
  bool shouldRepaint(covariant MacroRingPainter oldDelegate) {
    return oldDelegate.protein != protein ||
        oldDelegate.carbs != carbs ||
        oldDelegate.fats != fats;
  }
}
