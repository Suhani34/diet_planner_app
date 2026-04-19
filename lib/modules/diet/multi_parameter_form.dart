import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import '../../widgets/ruler_scale_picker.dart';
import 'bmi_result_screen.dart';
import 'meal_plan_service.dart';

class MultiParameterForm extends StatefulWidget {
  const MultiParameterForm({super.key});

  @override
  State<MultiParameterForm> createState() => _MultiParameterFormState();
}

class _MultiParameterFormState extends State<MultiParameterForm> {
  final PageController _controller = PageController();
  final MealPlanService _mealPlanService = MealPlanService();
  int currentPage = 0;
  bool _isGeneratingPlan = false;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> nextPage() async {
    if (currentPage < 12) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage--;
      });
    }
  }

  Future<void> _handleContinue() async {
    if (currentPage >= 12) {
      setState(() {
        _isGeneratingPlan = true;
      });
      final result = await _mealPlanService.generateOrGetLockedPlan(
        profileParams: _buildProfilePayload(),
      );
      if (!mounted) return;
      setState(() {
        _isGeneratingPlan = false;
      });
      if (!mounted) return;
      final heightCm = double.tryParse(height) ?? 160.0;
      final weightKg = double.tryParse(weight) ?? 60.0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BmiResultScreen(
            mealPlan: result.plan,
            heightCm: heightCm,
            weightKg: weightKg,
          ),
        ),
      );
    } else {
      await nextPage();
    }
  }

  Map<String, dynamic> _buildProfilePayload() {
    return {
      "age": age,
      "gender": gender,
      "height": height,
      "weight": weight,
      "goal": goal,
      "activityLevel": activityLevel,
      "dietPreference": dietPreference,
      "mealFrequency": mealFrequency,
      "timeline": timeline,
      "budget": budget,
      "cuisine": cuisine,
      "allergies": allergies,
      "medicalConditions": medicalConditions,
    };
  }

  Widget buildCard(Widget child) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F4),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF272525),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }

  Widget buildValueChip({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF2A2929),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAgeSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSectionTitle(
          "About You",
          subtitle: "Select your age using the scale below",
        ),
        const SizedBox(height: 26),
        buildValueChip(
          icon: Icons.cake_outlined,
          color: const Color(0xFF7B61FF),
          label: "Age",
          value: age,
        ),
        const SizedBox(height: 28),
        RulerScalePicker(
          min: 10,
          max: 80,
          initialValue: int.parse(age),
          majorTickEvery: 5,
          accentColor: const Color(0xFF7B61FF),
          onChanged: (value) {
            setState(() {
              age = value.toString();
            });
          },
        ),
      ],
    );
  }

  Widget buildHeightSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSectionTitle(
          "Height",
          subtitle: "Set your height using the ruler scale",
        ),
        const SizedBox(height: 26),
        buildValueChip(
          icon: Icons.height_rounded,
          color: const Color(0xFFFF4FA3),
          label: "Height",
          value: "$height cm",
        ),
        const SizedBox(height: 28),
        RulerScalePicker(
          min: 120,
          max: 220,
          initialValue: int.parse(height),
          majorTickEvery: 10,
          accentColor: const Color(0xFFFF4FA3),
          onChanged: (value) {
            setState(() {
              height = value.toString();
            });
          },
        ),
      ],
    );
  }

  Widget buildWeightSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSectionTitle(
          "Weight",
          subtitle: "Choose your current weight",
        ),
        const SizedBox(height: 26),
        buildValueChip(
          icon: Icons.monitor_weight_outlined,
          color: const Color(0xFF6A5AE0),
          label: "Weight",
          value: "$weight kg",
        ),
        const SizedBox(height: 28),
        RulerScalePicker(
          min: 30,
          max: 150,
          initialValue: int.parse(weight),
          majorTickEvery: 10,
          accentColor: const Color(0xFF6A5AE0),
          onChanged: (value) {
            setState(() {
              weight = value.toString();
            });
          },
        ),
      ],
    );
  }

  Widget buildGenderSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSectionTitle(
          "Gender",
          subtitle: "Choose the option that fits you best",
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            genderCard("Male", Icons.male, Colors.blue),
            genderCard("Female", Icons.female, Colors.pink),
            genderCard("Other", Icons.transgender, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget genderCard(String value, IconData icon, Color color) {
    final isSelected = gender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.16) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSingleChoice(
    String title,
    List<String> options,
    Function(String) onSelected,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSectionTitle(
          title,
          subtitle: "Select one option",
        ),
        const SizedBox(height: 20),
        ...options.map(
          (option) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: RadioListTile<String>(
              title: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
              value: option,
              groupValue: getGroupValue(title),
              activeColor: const Color(0xFFF29D72),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  onSelected(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  String getGroupValue(String title) {
    switch (title) {
      case "Select Goal":
        return goal;
      case "Activity Level":
        return activityLevel;
      case "Diet Preference":
        return dietPreference;
      case "Daily Meal Frequency":
        return mealFrequency;
      case "Target Timeline":
        return timeline;
      case "Food Budget Level":
        return budget;
      case "Cuisine Preference":
        return cuisine;
      default:
        return "";
    }
  }

  Widget buildMultiChoice(
    String title,
    List<String> options,
    List<String> selectedList,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSectionTitle(
          title,
          subtitle: "Select all that apply",
        ),
        const SizedBox(height: 20),
        ...options.map(
          (option) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: CheckboxListTile(
              title: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
              value: selectedList.contains(option),
              activeColor: const Color(0xFFF29D72),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    if (!selectedList.contains(option)) {
                      selectedList.add(option);
                    }
                  } else {
                    selectedList.remove(option);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (currentPage > 0)
                    IconButton(
                      onPressed: previousPage,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  const Expanded(
                    child: Text(
                      "Complete Your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF272525),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Tell us about yourself",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Step ${currentPage + 1} of 13",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildCard(buildAgeSelector()),
                  buildCard(buildGenderSelection()),
                  buildCard(buildHeightSelector()),
                  buildCard(buildWeightSelector()),
                  buildCard(buildSingleChoice(
                    "Select Goal",
                    ["Lose Weight", "Gain Weight", "Maintain Weight"],
                    (v) => goal = v,
                  )),
                  buildCard(buildSingleChoice(
                    "Activity Level",
                    [
                      "Sedentary",
                      "Lightly Active",
                      "Moderately Active",
                      "Very Active"
                    ],
                    (v) => activityLevel = v,
                  )),
                  buildCard(buildSingleChoice(
                    "Diet Preference",
                    ["Vegetarian", "Non-Vegetarian", "Vegan", "Eggetarian"],
                    (v) => dietPreference = v,
                  )),
                  buildCard(buildSingleChoice(
                    "Daily Meal Frequency",
                    ["3 Meals", "5 Small Meals", "Intermittent Fasting"],
                    (v) => mealFrequency = v,
                  )),
                  buildCard(buildSingleChoice(
                    "Target Timeline",
                    ["1 Month", "3 Months", "6 Months"],
                    (v) => timeline = v,
                  )),
                  buildCard(buildSingleChoice(
                    "Food Budget Level",
                    ["Low", "Medium", "High"],
                    (v) => budget = v,
                  )),
                  buildCard(buildSingleChoice(
                    "Cuisine Preference",
                    ["Indian", "South Indian", "North Indian", "Western"],
                    (v) => cuisine = v,
                  )),
                  buildCard(buildMultiChoice(
                    "Allergies",
                    ["Lactose", "Gluten", "Nuts", "Seafood"],
                    allergies,
                  )),
                  buildCard(buildMultiChoice(
                    "Medical Conditions",
                    ["Diabetes", "Thyroid", "BP", "PCOS"],
                    medicalConditions,
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: previousPage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          side: const BorderSide(color: Color(0xFFF29D72)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Color(0xFFF29D72),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isGeneratingPlan ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF29D72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: _isGeneratingPlan
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                currentPage >= 12
                                    ? "Generate Locked AI Plan"
                                    : "Continue",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
