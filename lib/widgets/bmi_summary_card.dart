import 'package:flutter/material.dart';

/// Shared BMI card UI — dashboard और onboarding result दोनों में use हो सकता है।
class BmiSummaryCard extends StatelessWidget {
  final double bmi;
  final String status;

  /// `true` = छोटा row (dashboard), `false` = बड़ा centered card (post-signup)
  final bool compact;

  const BmiSummaryCard({
    super.key,
    required this.bmi,
    required this.status,
    this.compact = true,
  });

  static String labelFor(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F2),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE3DEFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.monitor_weight_rounded,
                color: Color(0xFF6E61F4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BMI",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "BMI ${bmi.toStringAsFixed(1)} ($status)",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF262626),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F2),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE3DEFF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.monitor_weight_rounded,
              color: Color(0xFF6E61F4),
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Your BMI",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bmi.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E61F4),
            ),
          ),
        ],
      ),
    );
  }
}
