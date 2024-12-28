import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL for the backend
  final String _baseUrl = "http://161.9.124.1:8080";

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
    required String birthDate,
    required String blood_type,
    required String email,
  }) async {
    final url = Uri.parse("$_baseUrl/register");

    try {
      print("Registering user: $name");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tc': tc,
          'password': password,
          'name': name,
          'surname': surname,
          'birth_date': birthDate,
          'blood_type': blood_type,
          'email': email,
        }),
      );
      print(response.body);

      // Check the status code
      if (response.statusCode == 200) {
        // Parse JSON response
        final data = jsonDecode(response.body);

        // Sign in with the custom token from Firebase
        await FirebaseAuth.instance.signInWithCustomToken(data["session_key"]);

        print("User created: $name");
        return {'success': true, 'message': 'User created successfully'};
      } else {
        // If server returned an error, throw an Exception
        throw Exception(
          "User could not be created: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      // Handle any exceptions (e.g., network issues, JSON parse errors)
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check session function
  Future<Map<String, dynamic>> checkSession(String token) async {
    final url = Uri.parse("$_baseUrl/check_token");

    try {
      // Replace this with a valid Firebase App Check token
      final appCheckToken = "REPLACE_WITH_APP_CHECK_TOKEN";

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

  Future<Map<String, dynamic>> updateLocation({
    required String city,
    required String district,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final url = Uri.parse("$_baseUrl/user/$uid");

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'city': city,
          'district': district,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': 'Location updated successfully'};
      } else {
        throw Exception(
          "Location could not be updated: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
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

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw e;
    }
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

class APIKey {
  final MapsApiKey = "AIzaSyCd0gng2M6iGEyod8rLJZJKFO_BgLcoy6k";
}
