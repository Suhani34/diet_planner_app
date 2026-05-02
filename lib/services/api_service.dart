import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 IMPORTANT: अपना laptop IP डालो (same WiFi)
  static const String baseUrl = "http://192.168.31.156:8000/api";

  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration aiTimeout = Duration(seconds: 90);

  // ---------------- HELPERS ----------------

  static Map<String, dynamic> _asMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Unexpected API response");
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> data) {
    if (data["data"] is Map<String, dynamic>) {
      return data["data"] as Map<String, dynamic>;
    }
    return data;
  }

  // ---------------- PROFILE ----------------

  static Future<Map<String, dynamic>> saveProfile(
      Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/profile/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        )
        .timeout(shortTimeout);

    print("SAVE PROFILE STATUS: ${response.statusCode}");
    print("SAVE PROFILE BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrap(_asMap(response.body));
    }

    throw Exception("Failed to save profile: ${response.body}");
  }

  // ---------------- GENERATE MEAL ----------------

  static Future<Map<String, dynamic>> generateMealPlan(
      String firebaseUid) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/diet/generate-meal-plan/"), // ✅ FIXED
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"firebase_uid": firebaseUid}),
        )
        .timeout(aiTimeout);

    print("GENERATE STATUS: ${response.statusCode}");
    print("GENERATE BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrap(_asMap(response.body));
    }

    throw Exception("Failed to generate meal plan: ${response.body}");
  }

  // ---------------- GET LATEST MEAL ----------------

  static Future<Map<String, dynamic>> getLatestMealPlan(
      String firebaseUid) async {
    final response = await http.get(
      Uri.parse("$baseUrl/diet/meal-plan/$firebaseUid/"), // ✅ FIXED
      headers: {"Content-Type": "application/json"},
    ).timeout(shortTimeout);

    print("GET MEAL STATUS: ${response.statusCode}");
    print("GET MEAL BODY: ${response.body}");

    if (response.statusCode == 200) {
      return _unwrap(_asMap(response.body));
    }

    throw Exception("Failed to fetch meal plan: ${response.body}");
  }

  // ---------------- PROFILE CHECK ----------------

  static Future<bool> isProfileComplete(String firebaseUid) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/$firebaseUid/status/"),
      headers: {"Content-Type": "application/json"},
    ).timeout(shortTimeout);
    print("PROFILE STATUS: ${response.statusCode}");
    print("PROFILE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = _asMap(response.body);
      return data["profile_complete"] ?? false;
    }

    return false;
  }
}
