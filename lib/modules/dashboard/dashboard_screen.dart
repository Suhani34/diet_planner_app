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
  double? currentHeight;
  double? currentWeight;

  @override
  void initState() {
    super.initState();
    mealPlan = widget.mealPlan;
    currentHeight = widget.heightCm;
    currentWeight = widget.weightKg;

    _fetchProfileAndData();
  }

  Future<void> _fetchProfileAndData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load profile to get height/weight for BMI
      final profile = await ApiService.getProfile(user.uid);
      if (mounted) {
        setState(() {
          currentHeight = double.tryParse(profile["height_cm"]?.toString() ?? "") ?? currentHeight;
          currentWeight = double.tryParse(profile["weight_kg"]?.toString() ?? "") ?? currentWeight;
        });
      }

      if (widget.shouldGenerateMeal) {
        _saveAndGenerateMeal();
      } else if (mealPlan == null) {
        _loadLatestMeal();
      }
    } catch (e) {
      debugPrint("Profile fetch failed: $e");
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
        mealError = "AI generation error. Please try again.";
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
        mealError = null;
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

  List<FoodItem> _convertMealItems(List<MealItem> items) {
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

  List<Map<String, dynamic>> _mealsForUi() {
    if (mealPlan == null) return [];

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
      Navigator.pop(context);

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
      Navigator.pop(context);
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
        (allFoods.isEmpty ? 0 : allFoods.fold<int>(0, (sum, food) => sum + food.calories));

    final protein = mealPlan?.proteinG.toDouble() ??
        (allFoods.isEmpty ? 0 : allFoods.fold<double>(0, (sum, food) => sum + food.protein));

    final carbs = mealPlan?.carbsG.toDouble() ??
        (allFoods.isEmpty ? 0 : allFoods.fold<double>(0, (sum, food) => sum + food.carbs));

    final fats = mealPlan?.fatsG.toDouble() ??
        (allFoods.isEmpty ? 0 : allFoods.fold<double>(0, (sum, food) => sum + food.fat));

    double? bmi;
    String? bmiStatus;
    if (currentHeight != null && currentWeight != null) {
      final hM = currentHeight! / 100.0;
      bmi = currentWeight! / (hM * hM);
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
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
                  mealPlan == null ? "Default plan" : "Day ${mealPlan!.dayNumber}",
                  style: const TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                if (isLoadingMeal)
                  const LinearProgressIndicator(minHeight: 5, color: Color(0xFFF29D72)),
                const SizedBox(height: 16),
                if (bmi != null && bmiStatus != null) ...[
                  BmiSummaryCard(bmi: bmi, status: bmiStatus, compact: true),
                  const SizedBox(height: 16),
                ],
                _MacroCard(calories: calories, protein: protein, carbs: carbs, fats: fats),
                const SizedBox(height: 18),
                Expanded(
                  child: meals.isEmpty && !isLoadingMeal
                      ? const Center(child: Text("Click 'Generate AI Meal' to start!"))
                      : ListView.separated(
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
                                    builder: (_) => MealDetailScreen(mealName: title, foods: foods),
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

  const _TopBar({required this.name, required this.email, required this.onLogout, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            backgroundColor: Color(0xFFFFE9DA),
            child: Icon(Icons.person_rounded, color: Color(0xFFF29D72)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(email, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        IconButton(onPressed: onLogout, icon: const Icon(Icons.logout_rounded)),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  const _MacroCard({required this.calories, required this.protein, required this.carbs, required this.fats});

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fats;
    final pP = total == 0 ? 0.0 : protein / total;
    final cP = total == 0 ? 0.0 : carbs / total;
    final fP = total == 0 ? 0.0 : fats / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F4),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 7))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                painter: MacroRingPainter(pP, cP, fP),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$calories", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF262626))),
                      const Text("kcal", style: TextStyle(fontSize: 13, color: Colors.black54)),
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
                _LegendItem(color: const Color(0xFFFFC98B), title: "Protein", value: "${protein.toStringAsFixed(0)}g"),
                const SizedBox(height: 14),
                _LegendItem(color: const Color(0xFFC8C4F8), title: "Carbs", value: "${carbs.toStringAsFixed(0)}g"),
                const SizedBox(height: 14),
                _LegendItem(color: const Color(0xFFF6B7C3), title: "Fats", value: "${fats.toStringAsFixed(0)}g"),
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
  const _LegendItem({required this.color, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 11, height: 11, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, color: Colors.black54))),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final VoidCallback onTap;
  const _MealCard({required this.title, required this.icon, required this.bgColor, required this.onTap});

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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 7))],
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, color: const Color(0xFF5B4B45), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600))),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class MacroRingPainter extends CustomPainter {
  final double p; final double c; final double f;
  MacroRingPainter(this.p, this.c, this.f);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 12;
    final basePaint = Paint()..color = const Color(0xFFEFEAE5)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, basePaint);
    double start = -1.5708;
    void draw(double percent, Color col) {
      if (percent <= 0) return;
      final paint = Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round;
      final sweep = 6.28318 * percent;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
      start += sweep;
    }
    draw(p, const Color(0xFFFFC98B)); draw(c, const Color(0xFFC8C4F8)); draw(f, const Color(0xFFF6B7C3));
  }
  @override
  bool shouldRepaint(covariant MacroRingPainter old) => true;
}
