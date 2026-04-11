import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/token_service.dart';

class ReceiptService {
  static Future<String?> uploadReceipt(File imageFile) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/receipts/upload");
    final token = await TokenService().getToken();

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Returns the URL or ID of the uploaded receipt
      return response.body;
    }
    return null;
  }
}