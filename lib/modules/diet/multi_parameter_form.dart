import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/meal_plan_model.dart';
import '../../services/api_service.dart';
import '../dashboard/dashboard_screen.dart';

class MultiParameterForm extends StatefulWidget {
  const MultiParameterForm({super.key});

  @override
  State<MultiParameterForm> createState() => _MultiParameterFormState();
}

class _MultiParameterFormState extends State<MultiParameterForm> {
  final PageController _controller = PageController();
  int currentPage = 0;
  bool isSubmitting = false;

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

  Future<void> _submitProfileAndGeneratePlan() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ApiService.saveProfile({
        "firebase_uid": user.uid,
        "email": user.email,
        "full_name": user.displayName,
        "age": int.tryParse(age),
        "gender": gender,
        "height": double.tryParse(height),
        "weight": double.tryParse(weight),
        "goal": goal,
        "activity_level": activityLevel,
        "diet_preference": dietPreference,
        "meal_frequency": mealFrequency,
        "timeline": timeline,
        "budget": budget,
        "cuisine": cuisine,
        "allergies": allergies,
        "medical_conditions": medicalConditions,
        "profile_complete": true,
      });

      final mealPlanJson = await ApiService.generateMealPlan(user.uid);
      final mealPlan = MealPlanModel.fromJson(mealPlanJson);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(mealPlan: mealPlan),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
                  "Lose Weight",
                  "Gain Weight",
                  "Maintain Weight"
                ], (v) => goal = v)),
                buildGradientBackground(buildSingleChoice("Activity Level", [
                  "Sedentary",
                  "Lightly Active",
                  "Moderately Active",
                  "Very Active"
                ], (v) => activityLevel = v)),
                buildGradientBackground(buildSingleChoice("Diet Preference", [
                  "Vegetarian",
                  "Non-Vegetarian",
                  "Vegan",
                  "Eggetarian"
                ], (v) => dietPreference = v)),
                buildGradientBackground(buildSingleChoice(
                    "Daily Meal Frequency",
                    ["3 Meals", "5 Small Meals", "Intermittent Fasting"],
                    (v) => mealFrequency = v)),
                buildGradientBackground(buildSingleChoice(
                    "Target Timeline",
                    ["1 Month", "3 Months", "6 Months"],
                    (v) => timeline = v)),
                buildGradientBackground(buildSingleChoice(
                    "Food Budget Level",
                    ["Low", "Medium", "High"],
                    (v) => budget = v)),
                buildGradientBackground(buildSingleChoice(
                    "Cuisine Preference",
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
                      onPressed: isSubmitting ? null : previousPage,
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
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (currentPage >= 12) {
                              await _submitProfileAndGeneratePlan();
                            } else {
                              await nextPage();
                            }
                          },
                    child: Text(
                      isSubmitting
                          ? "Please wait..."
                          : currentPage >= 12
                              ? "Save & Continue"
                              : "Continue",
                    ),
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
        const Text(
          "Select Your Age",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "${selectedAge.toInt()} Years",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Slider(
          value: selectedAge,
          min: 10,
          max: 80,
          divisions: 70,
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              age = value.toInt().toString();
            });
          },
        ),
      ],
    );
  }

  Widget buildHeightSelector() {
    double selectedHeight = double.parse(height);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Select Your Height",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "${selectedHeight.toInt()} cm",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Slider(
          value: selectedHeight,
          min: 120,
          max: 220,
          divisions: 100,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              height = value.toInt().toString();
            });
          },
        ),
      ],
    );
  }

  Widget buildWeightSelector() {
    double selectedWeight = double.parse(weight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Select Your Weight",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "${selectedWeight.toInt()} kg",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Slider(
          value: selectedWeight,
          min: 30,
          max: 150,
          divisions: 120,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              weight = value.toInt().toString();
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
        const Text(
          "Select Gender",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
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
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...options.map(
          (option) => RadioListTile(
            title: Text(option),
            value: option,
            groupValue: getGroupValue(title),
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                onSelected(value.toString());
              });
            },
          ),
        )
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
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...options.map(
          (option) => CheckboxListTile(
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
          ),
        )
      ],
    );
  }
}
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
