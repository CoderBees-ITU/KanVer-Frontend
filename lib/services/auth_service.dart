import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL for the backend
  final String _baseUrl = "http://13.60.166.45:8080";

  // Login function
  Future<Map<String, dynamic>> login(String tc, String password) async {
    final url = Uri.parse("$_baseUrl/get_user/$tc");

    try {
      // Send POST request
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).then((value) {
        final data = jsonDecode(value.body);
        Auth()
            .signInWithEmailAndPassword(
                email: data["Email"], password: password)
            .then((value) {
          print("User signed in: ${data["Name"]}");
        });
      });

      return {'success': true, 'message': 'Login successful'};
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String tc,
    required String password,
    required String name,
    required String surname,
    required String bithDate,
    required String blood_type,
    required String email,
  }) async {
    final url = Uri.parse("$_baseUrl/create_user");

    try {
      // Send POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tc_id': tc,
          'password': password,
          'name': name,
          'surname': surname,
          'birth_date': bithDate,
          'blood_type': blood_type,
          'email': email
        }),
      );

      if (response.statusCode == 200) {
        Auth().createUserWithEmailAndPassword(email: email, password: password);
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


  // Check session function
  Future<Map<String, dynamic>> checkSession(String token) async {
    final url = Uri.parse("$_baseUrl/check_token");

    try {
      // Replace this with a valid Firebase App Check token
      final appCheckToken = await _getAppCheckToken();

      // Send POST request to backend
      print(token);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'session_key': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? "Session validation failed"
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Utility to retrieve Firebase App Check token
  Future<String> _getAppCheckToken() async {
    // Logic to retrieve Firebase App Check token (e.g., using Firebase App Check SDK)
    // Replace with your actual implementation
    return "your-app-check-token"; // Placeholder
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

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((res) {
      print("User created: ${res}");
    });
  }
}
