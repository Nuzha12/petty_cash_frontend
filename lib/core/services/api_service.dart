import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petty_cash_fontend/core/constants/api_constants.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  static Future<Map<String, String>> _headers({bool isJson = true}) async {
    final token = await _getToken();

    return {
      if (isJson) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> uploadFile(
      String endpoint,
      String filePath,
      Map<String, String> fields,
      ) async {
    final token = await _getToken();

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

    return _handleResponse(response);
  }

  static Future<dynamic> login(String email, String password) async {
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

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Error ${response.statusCode}: ${response.body}");
    }
  }
}