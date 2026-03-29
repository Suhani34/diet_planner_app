import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'meal_data.dart';

class DashboardScreen extends StatelessWidget {
  final String age;
  final String gender;
  final String height;
  final String weight;
  final String goal;
  final String activityLevel;
  final String dietPreference;
  final String mealFrequency;
  final String timeline;
  final String budget;
  final String cuisine;
  final List<String> allergies;
  final List<String> medicalConditions;

  const DashboardScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activityLevel,
    required this.dietPreference,
    required this.mealFrequency,
    required this.timeline,
    required this.budget,
    required this.cuisine,
    required this.allergies,
    required this.medicalConditions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWeightLoss = goal == "Lose Weight";
    final List<DayPlan> plan = isWeightLoss ? weightLossPlan : weightGainPlan;
    final int todayIndex = DateTime.now().weekday;
    final DayPlan today = plan[todayIndex - 1];

    final int totalConsumed = today.breakfast.kcal + today.lunch.kcal + today.dinner.kcal;
    final int totalFat = today.breakfast.fat + today.lunch.fat + today.dinner.fat;
    final int totalProtein = today.breakfast.protein + today.lunch.protein + today.dinner.protein;
    final int totalCarbs = today.breakfast.carbs + today.lunch.carbs + today.dinner.carbs;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text("DietApp", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Daily Balance",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text("Day $todayIndex of 7 — ",
                    style: const TextStyle(fontSize: 14, color: Colors.black54)),
                Text(
                  isWeightLoss ? "🔥 Weight Loss" : "💪 Weight Gain",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: _CalorieRing(
                consumed: totalConsumed,
                total: today.calories,
                fat: totalFat,
                protein: totalProtein,
                carbs: totalCarbs,
              ),
            ),
            const SizedBox(height: 28),
            const Text("Today's Meals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _MealCard(type: "Breakfast", meal: today.breakfast),
            _MealCard(type: "Lunch", meal: today.lunch),
            _MealCard(type: "Dinner", meal: today.dinner),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  final int consumed;
  final int total;
  final int fat;
  final int protein;
  final int carbs;

  const _CalorieRing({
    required this.consumed,
    required this.total,
    required this.fat,
    required this.protein,
    required this.carbs,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (consumed / total).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(160, 160),
                painter: _RingPainter(progress: progress),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$consumed",
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const Text("kcal", style: TextStyle(fontSize: 13, color: Colors.black45)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MacroChip(label: "Fat", value: "${fat}g", color: const Color(0xFFFF9800)),
            const SizedBox(width: 12),
            _MacroChip(label: "Protein", value: "${protein}g", color: const Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            _MacroChip(label: "Carbs", value: "${carbs}g", color: const Color(0xFF2196F3)),
          ],
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 16.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String type;
  final Meal meal;

  const _MealCard({required this.type, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Text(meal.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(type,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Text("${meal.kcal} kcal",
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }
}