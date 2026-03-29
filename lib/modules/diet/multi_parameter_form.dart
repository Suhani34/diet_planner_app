import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';

class MultiParameterForm extends StatefulWidget {
  const MultiParameterForm({super.key});

  @override
  State<MultiParameterForm> createState() => _MultiParameterFormState();
}

class _MultiParameterFormState extends State<MultiParameterForm> {
  final PageController _controller = PageController();
  int currentPage = 0;

  String age = "18";
  String gender = "Male";
  String height = "160";
  String weight = "60";
  String goal = "Lose Weight";
  String activityLevel = "Sedentary";
  String dietPreference = "Vegetarian";
  String mealFrequency = "3 Meals";
  String timeline = "1 Month";
  String budget = "Medium";
  String cuisine = "Indian";
  List<String> allergies = [];
  List<String> medicalConditions = [];

  Future<void> nextPage() async {
    if (currentPage < 12) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              age: age,
              gender: gender,
              height: height,
              weight: weight,
              goal: goal,
              activityLevel: activityLevel,
              dietPreference: dietPreference,
              mealFrequency: mealFrequency,
              timeline: timeline,
              budget: budget,
              cuisine: cuisine,
              allergies: allergies,
              medicalConditions: medicalConditions,
            ),
          ),
        );
      }
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget buildCard(Widget child) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: child,
      ),
    );
  }

  Widget buildGradientBackground(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: buildCard(child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Step ${currentPage + 1} of 13"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                buildGradientBackground(buildAgeSelector()),
                buildGradientBackground(buildGenderSelection()),
                buildGradientBackground(buildHeightSelector()),
                buildGradientBackground(buildWeightSelector()),
                buildGradientBackground(buildSingleChoice("Select Goal", [
                  "Lose Weight", "Gain Weight", "Maintain Weight"
                ], (v) => goal = v)),
                buildGradientBackground(buildSingleChoice("Activity Level", [
                  "Sedentary", "Lightly Active", "Moderately Active", "Very Active"
                ], (v) => activityLevel = v)),
                buildGradientBackground(buildSingleChoice("Diet Preference", [
                  "Vegetarian", "Non-Vegetarian", "Vegan", "Eggetarian"
                ], (v) => dietPreference = v)),
                buildGradientBackground(buildSingleChoice("Daily Meal Frequency",
                    ["3 Meals", "5 Small Meals", "Intermittent Fasting"],
                    (v) => mealFrequency = v)),
                buildGradientBackground(buildSingleChoice("Target Timeline",
                    ["1 Month", "3 Months", "6 Months"],
                    (v) => timeline = v)),
                buildGradientBackground(buildSingleChoice("Food Budget Level",
                    ["Low", "Medium", "High"],
                    (v) => budget = v)),
                buildGradientBackground(buildSingleChoice("Cuisine Preference",
                    ["Indian", "South Indian", "North Indian", "Western"],
                    (v) => cuisine = v)),
                buildGradientBackground(buildMultiChoice(
                    "Allergies",
                    ["Lactose", "Gluten", "Nuts", "Seafood"],
                    allergies)),
                buildGradientBackground(buildMultiChoice(
                    "Medical Conditions",
                    ["Diabetes", "Thyroid", "BP", "PCOS"],
                    medicalConditions)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentPage > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: previousPage,
                      child: const Text("Back"),
                    ),
                  ),
                if (currentPage > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await nextPage();
                    },
                    child: Text(currentPage == 12 ? "Finish" : "Continue"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildAgeSelector() {
    double selectedAge = double.parse(age);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select Your Age",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text("${selectedAge.toInt()} Years",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
        Slider(
          value: selectedAge, min: 10, max: 80, divisions: 70,
          activeColor: Colors.orange,
          onChanged: (value) => setState(() => age = value.toInt().toString()),
        ),
      ],
    );
  }

  Widget buildHeightSelector() {
    double selectedHeight = double.parse(height);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select Your Height",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text("${selectedHeight.toInt()} cm",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
        Slider(
          value: selectedHeight, min: 120, max: 220, divisions: 100,
          activeColor: Colors.green,
          onChanged: (value) => setState(() => height = value.toInt().toString()),
        ),
      ],
    );
  }

  Widget buildWeightSelector() {
    double selectedWeight = double.parse(weight);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select Your Weight",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text("${selectedWeight.toInt()} kg",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
        Slider(
          value: selectedWeight, min: 30, max: 150, divisions: 120,
          activeColor: Colors.blue,
          onChanged: (value) => setState(() => weight = value.toInt().toString()),
        ),
      ],
    );
  }

  Widget buildGenderSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select Gender",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            genderCard("Male", Icons.male, Colors.blue),
            genderCard("Female", Icons.female, Colors.pink),
            genderCard("Other", Icons.transgender, Colors.purple),
          ],
        )
      ],
    );
  }

  Widget genderCard(String value, IconData icon, Color color) {
    bool isSelected = gender == value;
    return GestureDetector(
      onTap: () => setState(() => gender = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget buildSingleChoice(String title, List<String> options, Function(String) onSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...options.map((option) => RadioListTile(
          title: Text(option),
          value: option,
          groupValue: getGroupValue(title),
          activeColor: Colors.orange,
          onChanged: (value) => setState(() => onSelected(value.toString())),
        ))
      ],
    );
  }

  String getGroupValue(String title) {
    switch (title) {
      case "Select Goal": return goal;
      case "Activity Level": return activityLevel;
      case "Diet Preference": return dietPreference;
      case "Daily Meal Frequency": return mealFrequency;
      case "Target Timeline": return timeline;
      case "Food Budget Level": return budget;
      case "Cuisine Preference": return cuisine;
      default: return "";
    }
  }

  Widget buildMultiChoice(String title, List<String> options, List<String> selectedList) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...options.map((option) => CheckboxListTile(
          title: Text(option),
          value: selectedList.contains(option),
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selectedList.add(option);
              } else {
                selectedList.remove(option);
              }
            });
          },
        ))
      ],
    );
  }
}
