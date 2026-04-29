import 'package:flutter/material.dart';

import '../../widgets/app_background.dart';
import '../../widgets/bmi_summary_card.dart';
import '../dashboard/dashboard_screen.dart';
import 'meal_plan.dart';

class BmiResultScreen extends StatelessWidget {
  final MealPlan mealPlan;
  final double heightCm;
  final double weightKg;

  const BmiResultScreen({
    super.key,
    required this.mealPlan,
    required this.heightCm,
    required this.weightKg,
  });

  @override
  Widget build(BuildContext context) {
    final hM = heightCm / 100.0;
    final bmi = weightKg / (hM * hM);
    final status = BmiSummaryCard.labelFor(bmi);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Profile ready",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${heightCm.toStringAsFixed(0)} cm · ${weightKg.toStringAsFixed(1)} kg",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                BmiSummaryCard(
                  bmi: bmi,
                  status: status,
                  compact: false,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Neeche se apna meal plan dashboard par dekho. Plan lock ho chuka hai.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DashboardScreen(
                            isPlanLocked: true,
                            heightCm: heightCm,
                            weightKg: weightKg,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF29D72),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      "Continue to Dashboard",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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