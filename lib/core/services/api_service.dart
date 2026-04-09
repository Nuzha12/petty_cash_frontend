import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'token_service.dart';

class ApiService {

  static Future<Map<String, String>> _headers() async {
    final token = await TokenService().getToken();

    print("TOKEN SENT => $token");

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer ${token.trim()}",
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

    switch (method) {
      case "GET":
        res = await http.get(uri, headers: headers);
        break;
      case "POST":
        res = await http.post(uri, headers: headers, body: jsonEncode(data));
        break;
      case "PATCH":
        res = await http.patch(uri, headers: headers, body: jsonEncode(data));
        break;
      case "DELETE":
        res = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception("Invalid method");
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body.isEmpty ? "{}" : res.body);
    } else if (res.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(res.body);
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Login failed");
    }
  }
}