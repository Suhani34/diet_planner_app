import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final String height;
  final String weight;
  final String goal;
  final String activity;
  final String diet;
  final String meals;
  final String timeline;
  final String budget;
  final String cuisine;
  final List<String> allergies;
  final List<String> conditions;

  const DashboardScreen({
    super.key,
    this.name = 'User',
    this.age = '18',
    this.gender = 'Male',
    this.height = '170',
    this.weight = '65',
    this.goal = 'Maintain Weight',
    this.activity = 'Moderately Active',
    this.diet = 'Vegetarian',
    this.meals = '3 Meals',
    this.timeline = '1 Month',
    this.budget = 'Medium',
    this.cuisine = 'Indian',
    this.allergies = const [],
    this.conditions = const [],
  });

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          goal: goal,
          activity: activity,
          diet: diet,
          meals: meals,
          timeline: timeline,
          budget: budget,
          cuisine: cuisine,
          allergies: allergies,
          conditions: conditions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = [
      {
        "title": "Breakfast",
        "icon": Icons.free_breakfast_rounded,
        "color": const Color(0xFFF6B7C3),
      },
      {
        "title": "Lunch",
        "icon": Icons.lunch_dining_rounded,
        "color": const Color(0xFFFFD59E),
      },
      {
        "title": "Snack",
        "icon": Icons.cookie_rounded,
        "color": const Color(0xFFC9C4F7),
      },
      {
        "title": "Dinner",
        "icon": Icons.dinner_dining_rounded,
        "color": const Color(0xFFAEDDC8),
      },
    ];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topGreetingCard(context),
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
                const _MacroChartCard(),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${meal["title"]} clicked"),
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

  Widget _topGreetingCard(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _openProfile(context),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFF2D8C9),
                child: Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Hello, $name",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
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
}

class _MacroChartCard extends StatelessWidget {
  const _MacroChartCard();

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: SizedBox(
              height: 180,
              child: CustomPaint(
                painter: MacroRingPainter(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Consumed",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "1600",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626),
                        ),
                      ),
                      Text(
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
              children: const [
                _LegendItem(
                  color: Color(0xFFF6B7C3),
                  title: "Fat",
                  value: "45/65g",
                ),
                SizedBox(height: 14),
                _LegendItem(
                  color: Color(0xFFFFC98B),
                  title: "Protein",
                  value: "45/65g",
                ),
                SizedBox(height: 14),
                _LegendItem(
                  color: Color(0xFFC8C4F8),
                  title: "Carbs",
                  value: "45/65g",
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
