import 'dart:convert';
import 'package:flutter/material.dart';
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
Future<Map<String, dynamic>> validateUserDetails({
  required String tcNumber,
  required String name,
  required String surname,
  required String birthDay,
}) async {
  try {
    // Make the HTTP POST request
    final response = await http.post(
      Uri.parse("https://tc-kimlik.vercel.app/api/dogrula"),
      headers: {
        'Content-Type': 'application/json', // Set content type to JSON
      },
      body: jsonEncode({
        "tc": tcNumber,
        "ad": name,
        "soyad": surname,
        "dogumTarihi": birthDay,
      }),
    );

    // Decode the response body into a Map and return it
    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    // Log the error and return a failure response
    print("Error occurred while validating user details: $e");
    return {
      "status": "error",
      "result": false,
      "message": "Error occurred while validating user details."
    };
  }
}
