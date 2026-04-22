import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android physical device, use your PC's local IP, not 127.0.0.1
  // Example: http://192.168.29.102:8000/api
  static const String baseUrl = "http://192.168.x.x:8000/api";

  static Future<Map<String, dynamic>> saveProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to save profile: ${response.body}");
  }

  static Future<Map<String, dynamic>> generateMealPlan(String firebaseUid) async {
    final response = await http.post(
      Uri.parse("$baseUrl/generate-meal-plan/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firebase_uid": firebaseUid,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to generate meal plan: ${response.body}");
  }

  static Future<Map<String, dynamic>> getLatestMealPlan(String firebaseUid) async {
    final response = await http.get(
      Uri.parse("$baseUrl/meal-plan/$firebaseUid/"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to fetch meal plan: ${response.body}");
  }

  static Future<bool> isProfileComplete(String firebaseUid) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/$firebaseUid/status/"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["profile_complete"] ?? false;
    }

    return false;
  }
}