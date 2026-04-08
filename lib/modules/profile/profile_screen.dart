import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/app_background.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String name; // ✅ ADD
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

  const ProfileScreen({
    super.key,
    required this.name, // ✅ ADD
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activity,
    required this.diet,
    required this.meals,
    required this.timeline,
    required this.budget,
    required this.cuisine,
    required this.allergies,
    required this.conditions,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  late String name, // ✅ ADD
      age,
      gender,
      height,
      weight,
      goal,
      activity,
      diet,
      meals,
      timeline,
      budget,
      cuisine;

  late List<String> allergies, conditions;

  @override
  void initState() {
    super.initState();

    name = widget.name; // ✅ ADD
    age = widget.age;
    gender = widget.gender;
    height = widget.height;
    weight = widget.weight;
    goal = widget.goal;
    activity = widget.activity;
    diet = widget.diet;
    meals = widget.meals;
    timeline = widget.timeline;
    budget = widget.budget;
    cuisine = widget.cuisine;

    allergies = List.from(widget.allergies);
    conditions = List.from(widget.conditions);
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ListTile(leading: Icon(Icons.person), title: Text("Account")),
          ListTile(leading: Icon(Icons.lock), title: Text("Privacy")),
          ListTile(leading: Icon(Icons.notifications), title: Text("Notifications")),
          ListTile(leading: Icon(Icons.dark_mode), title: Text("Dark Mode")),
          ListTile(leading: Icon(Icons.calculate), title: Text("Calculate BMI")),
        ],
      ),
    );
  }

  void openEditDialog() {
    TextEditingController ageCtrl = TextEditingController(text: age);
    TextEditingController heightCtrl = TextEditingController(text: height);
    TextEditingController weightCtrl = TextEditingController(text: weight);

    String tempGender = gender;
    String tempGoal = goal;
    String tempActivity = activity;
    String tempDiet = diet;
    String tempMeals = meals;
    String tempTimeline = timeline;
    String tempBudget = budget;
    String tempCuisine = cuisine;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Full Profile"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: "Age")),
                  TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: "Height (cm)")),
                  TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: "Weight (kg)")),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    initialValue: tempGender,
                    items: ["Male", "Female", "Other"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempGender = val!),
                    decoration: const InputDecoration(labelText: "Gender"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempGoal,
                    items: ["Lose Weight", "Gain Weight", "Maintain Weight"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempGoal = val!),
                    decoration: const InputDecoration(labelText: "Goal"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempActivity,
                    items: ["Sedentary", "Lightly Active", "Moderately Active", "Very Active"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempActivity = val!),
                    decoration: const InputDecoration(labelText: "Activity"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempDiet,
                    items: ["Vegetarian", "Non-Vegetarian", "Vegan", "Eggetarian"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempDiet = val!),
                    decoration: const InputDecoration(labelText: "Diet"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempMeals,
                    items: ["3 Meals", "5 Small Meals", "Intermittent Fasting"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempMeals = val!),
                    decoration: const InputDecoration(labelText: "Meals"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempTimeline,
                    items: ["1 Month", "3 Months", "6 Months"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempTimeline = val!),
                    decoration: const InputDecoration(labelText: "Timeline"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempBudget,
                    items: ["Low", "Medium", "High"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempBudget = val!),
                    decoration: const InputDecoration(labelText: "Budget"),
                  ),

                  DropdownButtonFormField(
                    initialValue: tempCuisine,
                    items: ["Indian", "South Indian", "North Indian", "Western"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => tempCuisine = val!),
                    decoration: const InputDecoration(labelText: "Cuisine"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    age = ageCtrl.text;
                    height = heightCtrl.text;
                    weight = weightCtrl.text;
                    gender = tempGender;
                    goal = tempGoal;
                    activity = tempActivity;
                    diet = tempDiet;
                    meals = tempMeals;
                    timeline = tempTimeline;
                    budget = tempBudget;
                    cuisine = tempCuisine;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.settings), onPressed: openSettings),
                    IconButton(icon: const Icon(Icons.edit), onPressed: openEditDialog),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => pickImage(ImageSource.gallery),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: _image != null
                              ? (kIsWeb ? NetworkImage(_image!.path) : FileImage(_image!) as ImageProvider)
                              : null,
                          child: _image == null ? const Icon(Icons.person, size: 40) : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 🔥 NAME SHOW
                      Text(
                        "Hello, $name",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      buildCard("Age", age),
                      buildCard("Gender", gender),
                      buildCard("Height", "$height cm"),
                      buildCard("Weight", "$weight kg"),
                      buildCard("Goal", goal),
                      buildCard("Activity", activity),
                      buildCard("Diet", diet),
                      buildCard("Meals", meals),
                      buildCard("Timeline", timeline),
                      buildCard("Budget", budget),
                      buildCard("Cuisine", cuisine),

                      const SizedBox(height: 10),

                      buildCard("Allergies", allergies.join(", ")),
                      buildCard("Conditions", conditions.join(", ")),

                      const SizedBox(height: 30),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}