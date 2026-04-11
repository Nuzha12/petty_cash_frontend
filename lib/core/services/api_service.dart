import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'token_service.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenService().getToken();
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/auth/login");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? "Login failed");
      } catch (e) {
        throw Exception("Server error: ${response.statusCode}");
      }
    }
  }

  static Future<dynamic> request(String method, String endpoint, {Map<String, dynamic>? data}) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");
    final headers = await _headers();
    http.Response res;

    try {
      switch (method) {
        case "GET": res = await http.get(uri, headers: headers); break;
        case "POST": res = await http.post(uri, headers: headers, body: jsonEncode(data)); break;
        case "PATCH": res = await http.patch(uri, headers: headers, body: jsonEncode(data)); break;
        case "DELETE": res = await http.delete(uri, headers: headers); break;
        default: throw Exception("Invalid method");
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body.isEmpty ? "{}" : res.body);
      }
      if (res.statusCode == 401) {
        await TokenService().clear();
        throw Exception("Session expired");
      }
      throw Exception(res.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> uploadReceipt(int expenseId, File imageFile) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/receipts/upload?expense_id=$expenseId");
    final token = await TokenService().getToken();

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Receipt upload failed");
    }
  }
}