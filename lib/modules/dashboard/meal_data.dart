class Meal {
  final String name;
  final int kcal;
  final int fat;
  final int protein;
  final int carbs;
  final String emoji;

  const Meal({
    required this.name,
    required this.kcal,
    required this.fat,
    required this.protein,
    required this.carbs,
    required this.emoji,
  });
}

class DayPlan {
  final int day;
  final int calories;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;

  const DayPlan({
    required this.day,
    required this.calories,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}

// ✅ Weight Loss Plan
final List<DayPlan> weightLossPlan = [
  DayPlan(day: 1, calories: 1400,
    breakfast: Meal(name: "Oats", kcal: 300, fat: 5, protein: 10, carbs: 40, emoji: "🥣"),
    lunch: Meal(name: "Dal Roti", kcal: 500, fat: 8, protein: 20, carbs: 60, emoji: "🍛"),
    dinner: Meal(name: "Soup", kcal: 250, fat: 3, protein: 10, carbs: 30, emoji: "🥗")),
  DayPlan(day: 2, calories: 1400,
    breakfast: Meal(name: "Poha", kcal: 280, fat: 4, protein: 8, carbs: 50, emoji: "🍚"),
    lunch: Meal(name: "Chicken Wrap", kcal: 500, fat: 10, protein: 30, carbs: 45, emoji: "🌯"),
    dinner: Meal(name: "Salad", kcal: 220, fat: 3, protein: 10, carbs: 25, emoji: "🥗")),
  DayPlan(day: 3, calories: 1350,
    breakfast: Meal(name: "Egg Toast", kcal: 300, fat: 6, protein: 15, carbs: 35, emoji: "🍳"),
    lunch: Meal(name: "Rice + Dal", kcal: 480, fat: 7, protein: 18, carbs: 65, emoji: "🍛"),
    dinner: Meal(name: "Paneer Soup", kcal: 250, fat: 8, protein: 14, carbs: 20, emoji: "🍲")),
  DayPlan(day: 4, calories: 1380,
    breakfast: Meal(name: "Smoothie", kcal: 300, fat: 5, protein: 10, carbs: 45, emoji: "🥤"),
    lunch: Meal(name: "Rajma Rice", kcal: 520, fat: 8, protein: 20, carbs: 80, emoji: "🍱"),
    dinner: Meal(name: "Grilled Fish", kcal: 260, fat: 6, protein: 25, carbs: 10, emoji: "🐟")),
  DayPlan(day: 5, calories: 1320,
    breakfast: Meal(name: "Dalia", kcal: 260, fat: 4, protein: 10, carbs: 40, emoji: "🥣"),
    lunch: Meal(name: "Chole Roti", kcal: 500, fat: 9, protein: 18, carbs: 70, emoji: "🫘"),
    dinner: Meal(name: "Egg Bhurji", kcal: 220, fat: 4, protein: 18, carbs: 10, emoji: "🍳")),
  DayPlan(day: 6, calories: 1300,
    breakfast: Meal(name: "Yogurt + Fruit", kcal: 250, fat: 3, protein: 12, carbs: 35, emoji: "🍓"),
    lunch: Meal(name: "Veg Pulao", kcal: 450, fat: 6, protein: 10, carbs: 75, emoji: "🍚"),
    dinner: Meal(name: "Lauki Sabzi", kcal: 250, fat: 4, protein: 8, carbs: 40, emoji: "🥬")),
  DayPlan(day: 7, calories: 1360,
    breakfast: Meal(name: "Sprouts", kcal: 240, fat: 2, protein: 14, carbs: 35, emoji: "🌱"),
    lunch: Meal(name: "Palak Paneer", kcal: 520, fat: 14, protein: 22, carbs: 50, emoji: "🥬"),
    dinner: Meal(name: "Dal Soup", kcal: 220, fat: 2, protein: 12, carbs: 30, emoji: "🍵")),
];

// ✅ Weight Gain Plan
final List<DayPlan> weightGainPlan = [
  DayPlan(day: 1, calories: 2800,
    breakfast: Meal(name: "Banana Shake", kcal: 600, fat: 15, protein: 20, carbs: 90, emoji: "🥤"),
    lunch: Meal(name: "Chicken Biryani", kcal: 900, fat: 30, protein: 40, carbs: 100, emoji: "🍗"),
    dinner: Meal(name: "Paneer Naan", kcal: 700, fat: 25, protein: 30, carbs: 80, emoji: "🍛")),
  DayPlan(day: 2, calories: 2900,
    breakfast: Meal(name: "Paratha + Curd", kcal: 700, fat: 20, protein: 15, carbs: 100, emoji: "🫓"),
    lunch: Meal(name: "Mutton Rice", kcal: 1000, fat: 35, protein: 45, carbs: 90, emoji: "🍖"),
    dinner: Meal(name: "Egg Curry", kcal: 750, fat: 25, protein: 35, carbs: 70, emoji: "🍳")),
  DayPlan(day: 3, calories: 2750,
    breakfast: Meal(name: "Poha + Lassi", kcal: 600, fat: 12, protein: 12, carbs: 100, emoji: "🥛"),
    lunch: Meal(name: "Dal Makhani", kcal: 950, fat: 28, protein: 25, carbs: 120, emoji: "🍱"),
    dinner: Meal(name: "Pav Bhaji", kcal: 700, fat: 20, protein: 15, carbs: 110, emoji: "🍞")),
  DayPlan(day: 4, calories: 3000,
    breakfast: Meal(name: "Paneer Paratha", kcal: 750, fat: 25, protein: 30, carbs: 85, emoji: "🧀"),
    lunch: Meal(name: "Chole Bhature", kcal: 1100, fat: 35, protein: 25, carbs: 140, emoji: "🫘"),
    dinner: Meal(name: "Fish Rice", kcal: 850, fat: 25, protein: 40, carbs: 100, emoji: "🐟")),
  DayPlan(day: 5, calories: 2850,
    breakfast: Meal(name: "Dosa", kcal: 650, fat: 12, protein: 12, carbs: 110, emoji: "🥞"),
    lunch: Meal(name: "Rajma Rice", kcal: 950, fat: 10, protein: 30, carbs: 150, emoji: "🍚"),
    dinner: Meal(name: "Shahi Paneer", kcal: 800, fat: 30, protein: 25, carbs: 80, emoji: "🍛")),
  DayPlan(day: 6, calories: 2950,
    breakfast: Meal(name: "Sabudana", kcal: 700, fat: 15, protein: 10, carbs: 120, emoji: "🥣"),
    lunch: Meal(name: "Butter Chicken", kcal: 1100, fat: 35, protein: 50, carbs: 110, emoji: "🍗"),
    dinner: Meal(name: "Palak Paneer", kcal: 800, fat: 30, protein: 25, carbs: 90, emoji: "🥬")),
  DayPlan(day: 7, calories: 3100,
    breakfast: Meal(name: "Smoothie Bowl", kcal: 800, fat: 20, protein: 15, carbs: 140, emoji: "🥭"),
    lunch: Meal(name: "Veg Biryani", kcal: 1100, fat: 25, protein: 20, carbs: 160, emoji: "🍛"),
    dinner: Meal(name: "Kadai Chicken", kcal: 900, fat: 35, protein: 50, carbs: 80, emoji: "🍗")),
];
