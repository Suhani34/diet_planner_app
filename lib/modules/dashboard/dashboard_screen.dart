import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/meal_plan_model.dart';
import '../../widgets/app_background.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final MealPlanModel mealPlan;

  const DashboardScreen({
    super.key,
    required this.mealPlan,
  });

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout failed: $e"),
        ),
      );
    }
  }

  IconData _getMealIcon(String mealKey) {
    switch (mealKey) {
      case "breakfast":
        return Icons.free_breakfast_rounded;
      case "lunch":
        return Icons.lunch_dining_rounded;
      case "dinner":
        return Icons.dinner_dining_rounded;
      case "snack":
      case "snack_1":
      case "snack_2":
      case "snacks":
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _getMealColor(String mealKey) {
    switch (mealKey) {
      case "breakfast":
        return const Color(0xFFFFD9B8);
      case "lunch":
        return const Color(0xFFCDE9C8);
      case "dinner":
        return const Color(0xFFCFE7D8);
      case "snack":
      case "snack_1":
      case "snack_2":
      case "snacks":
        return const Color(0xFFFFD2C8);
      default:
        return const Color(0xFFE6DDF7);
    }
  }

  String _formatMealTitle(String key) {
    return key
        .replaceAll("_", " ")
        .split(" ")
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1),
        )
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName =
        user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : "User";
    final String emailText =
        user?.email?.trim().isNotEmpty == true ? user!.email! : "Signed in";

    final mealEntries = mealPlan.meals.entries.toList();

    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF8F4),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFFFE9DA),
                            child: Icon(
                              Icons.person_rounded,
                              color: Color(0xFFF29D72),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, $displayName",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF262626),
                                  ),
                                ),
                                Text(
                                  emailText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: "Logout",
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                "Daily Diet Plan",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Day ${mealPlan.dayNumber}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              _MacroGoalCard(mealPlan: mealPlan),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: mealEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final entry = mealEntries[index];
                    final mealKey = entry.key;
                    final title = _formatMealTitle(mealKey);

                    return _MealCard(
                      title: title,
                      icon: _getMealIcon(mealKey),
                      bgColor: _getMealColor(mealKey),
                      onTap: () {
                        final foods = entry.value;
                        final foodNames = foods.map((e) => e.name).join(", ");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              foodNames.isEmpty ? "$title clicked" : foodNames,
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
    );
  }
}

class _MacroGoalCard extends StatelessWidget {
  final MealPlanModel mealPlan;

  const _MacroGoalCard({
    required this.mealPlan,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 150,
                    child: CustomPaint(
                      painter: const MacroRingPainter(),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${mealPlan.totalCalories}",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendItem(
                        color: const Color(0xFFF6B7C3),
                        title: "Fat",
                        value: "${mealPlan.fatsG}g",
                      ),
                      const SizedBox(height: 14),
                      _LegendItem(
                        color: const Color(0xFFFFC98B),
                        title: "Protein",
                        value: "${mealPlan.proteinG}g",
                      ),
                      const SizedBox(height: 14),
                      _LegendItem(
                        color: const Color(0xFFC8C4F8),
                        title: "Carbs",
                        value: "${mealPlan.carbsG}g",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: Color(0xFFF29D72),
              ),
              const SizedBox(width: 10),
              const Text(
                "Today's Goal",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Text(
                "${mealPlan.totalCalories} kcal",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF29D72),
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
                    fontSize: 26,
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

class MacroRingPainter extends CustomPainter {
  const MacroRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 14.0;
    final radius = (size.width / 2) - 16;

    final basePaint = Paint()
      ..color = const Color(0xFFF0EAE4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    void drawArc(Color color, double start, double sweep) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }

    drawArc(const Color(0xFFFFC98B), 2.75, 1.05);
    drawArc(const Color(0xFFF6B7C3), 3.95, 1.2);
    drawArc(const Color(0xFFC8C4F8), 5.35, 1.15);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}