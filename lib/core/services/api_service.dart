import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'token_service.dart';

class ApiService {

  static Future<Map<String, String>> _headers() async {
    final token = await TokenService().getToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  static Future<dynamic> request(
      String method,
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {

    final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");
    final headers = await _headers();

    http.Response res;

    try {

      switch (method) {
        case "GET":
          res = await http.get(uri, headers: headers);
          break;

        case "POST":
          res = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(data),
          );
          break;

        case "PATCH":
          res = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(data),
          );
          break;

        case "DELETE":
          res = await http.delete(uri, headers: headers);
          break;

        default:
          throw Exception("Invalid method");
      }

      print("API ${res.statusCode}: ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body.isEmpty ? "{}" : res.body);
      }

      if (res.statusCode == 401) {
        await TokenService().clear();
        throw Exception("Session expired. Please login again.");
      }

      throw Exception(res.body);

    } catch (e) {
      print("API ERROR: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {

    final uri = Uri.parse("${ApiConstants.baseUrl}/auth/login");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("LOGIN ${res.statusCode}: ${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception("Login failed");
  }
}