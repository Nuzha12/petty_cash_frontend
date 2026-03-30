import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static String? token;

  static Map<String, String> _headers({bool isJson = true}) {
    return {
      if (isJson) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}$endpoint"),
        headers: _headers(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception("GET failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}$endpoint"),
        headers: _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception("POST failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse("${ApiConstants.baseUrl}$endpoint"),
        headers: _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception("PATCH failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}$endpoint"),
        headers: _headers(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception("DELETE failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  static Future<dynamic> uploadFile(
      String endpoint,
      String filePath,
      Map<String, String> fields,
      ) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      );

      if (token != null) {
        request.headers["Authorization"] = "Bearer $token";
      }

      request.fields.addAll(fields);

      request.files.add(
        await http.MultipartFile.fromPath("file", filePath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Upload failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Upload error: $e");
    }
  }

  static Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/login"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "username": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data["access_token"];
        return data;
      } else {
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}