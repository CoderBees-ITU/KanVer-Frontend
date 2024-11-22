import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL for the backend
  final String _baseUrl = "https://example.com";

  // Login function
  Future<Map<String, dynamic>> login(String tc, String password) async {
    final url = Uri.parse("$_baseUrl/login");

    try {
      // Send POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tc': tc, 'password': password}),
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? "An error occurred"
        };
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      return {'success': false, 'message': e.toString()};
    }
  }
}
