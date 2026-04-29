import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.29.102:8000/api";

  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration aiTimeout = Duration(seconds: 35);

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

  static Future<Map<String, dynamic>> saveProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/profile/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        )
        .timeout(shortTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrap(_asMap(response.body));
    }

    throw Exception("Failed to save profile: ${response.body}");
  }

  static Future<Map<String, dynamic>> generateMealPlan(String firebaseUid) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/generate-meal-plan/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"firebase_uid": firebaseUid}),
        )
        .timeout(aiTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrap(_asMap(response.body));
    }

    throw Exception("Failed to generate meal plan: ${response.body}");
  }

  static Future<Map<String, dynamic>> getLatestMealPlan(String firebaseUid) async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/meal-plan/$firebaseUid/"),
          headers: {"Content-Type": "application/json"},
        )
        .timeout(shortTimeout);

    if (response.statusCode == 200) {
      return _unwrap(_asMap(response.body));
    }

    throw Exception("Failed to fetch meal plan: ${response.body}");
  }

  static Future<bool> isProfileComplete(String firebaseUid) async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/profile/$firebaseUid/status/"),
          headers: {"Content-Type": "application/json"},
        )
        .timeout(shortTimeout);

    if (response.statusCode == 200) {
      final data = _asMap(response.body);
      return data["profile_complete"] ?? false;
    }

    return false;
  }
}