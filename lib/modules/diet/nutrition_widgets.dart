import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NutritionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
      child: child,
    );
  }
}

class MacronutrientBar extends StatelessWidget {
  final String label;
  final Color color;
  final double value;
  final double target;
  final String unit;

  const MacronutrientBar({
    super.key,
    required this.label,
    required this.color,
    required this.value,
    required this.target,
    this.unit = "g",
  });

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A2A2A),
              ),
            ),
            const Spacer(),
            Text(
              "${value.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFEDE4DC),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MacroChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.95),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2A2A2A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
