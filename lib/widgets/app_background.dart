import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7E8DD),
            Color(0xFFF9EEE7),
            Color(0xFFF4E1D6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            left: -10,
            child: _softCircle(
              130,
              const Color(0xFFF6C6AF),
              0.35,
            ),
          ),
          Positioned(
            top: 40,
            right: -25,
            child: _softCircle(
              95,
              const Color(0xFFEFD2C1),
              0.22,
            ),
          ),
          Positioned(
            bottom: -35,
            left: -30,
            child: _softCircle(
              170,
              const Color(0xFFE7C89B),
              0.28,
            ),
          ),
          Positioned(
            bottom: 70,
            right: -18,
            child: _softCircle(
              110,
              const Color(0xFFF2D3C0),
              0.18,
            ),
          ),
          ..._decorDots(),
          SafeArea(child: child),
        ],
      ),
    );
  }

  static Widget _softCircle(double size, Color color, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
    );
  }

  static List<Widget> _decorDots() {
    final points = [
      const Offset(35, 110),
      const Offset(90, 150),
      const Offset(290, 120),
      const Offset(315, 210),
      const Offset(55, 420),
      const Offset(305, 530),
      const Offset(250, 700),
    ];

    return points.map((p) {
      return Positioned(
        left: p.dx,
        top: p.dy,
        child: Opacity(
          opacity: 0.18,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFE2A98F),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }
}