import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kanver/services/auth_service.dart';

class BloodRequestService {
  final String _baseUrl =
      "https://kanver-backend-93774604105.us-central1.run.app";

  Future<Map<String, dynamic>> createBloodRequest({
    required int patientTcId,
    required String bloodType,
    required int donorCount,
    required int patientAge,
    required Map hospital,
    required String note,
    required String gender,
    required String city,
    required String district,
    required String patientName,
    required String patientSurname,
  }) async {
    final url = Uri.parse("$_baseUrl/request");

    final body = {
      'patient_tc_id': patientTcId == "" ? null : patientTcId,
      'blood_type': bloodType == "" ? null : bloodType,
      'age': patientAge == 0 ? null : patientAge,
      'gender': gender,
      'note': note == "" ? null : note,
      'location': {
        'lat': hospital['coordinates']['latitude'],
        'lng': hospital['coordinates']['longitude'],
        'city': city,
        'district': district,
      },
      'status': 'pending',
      'hospital': hospital['name'],
      'donor_count': donorCount,
      'patient_name': patientName,
      'patient_surname': patientSurname,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${Auth().user!.uid}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': 'Request created', 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to create request'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getBloodRequests({
    required String bloodType,
    required String city,
    required String district,
  }) async {
    String query = "?";

    if (city != "Tümü") {
      query += "city=$city&";
    }
    if (district != "Tümü") {
      query += "district=$district&";
    }
    if (bloodType != "Tümü") {
      String tempBloodType;
      tempBloodType = bloodType.replaceAll("+", "p");
      tempBloodType = tempBloodType.replaceAll("-", "n");
      query += "blood_type=$tempBloodType&";
    }

    final url = Uri.parse("$_baseUrl/request/personalized$query");
    print(url);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Auth().user!.uid
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get requests'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> setOnTheWay({
    required String requestId,
  }) async {
    final url = Uri.parse("$_baseUrl/on_the_way");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${Auth().user!.uid}'
        },
        body: jsonEncode({
          'request_id': requestId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to update request status'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteOnTheWay({
    required int requestId,
  }) async {
    // Construct the URL
    final url = Uri.parse("$_baseUrl/on_the_way/$requestId");

    try {
      // Log the request details for debugging
      print("DELETE Request URL: $url");

      // Make the DELETE HTTP request
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              '${Auth().user?.uid}', // Assuming Auth().user?.uid provides the user ID
        },
      );

      // Log the response details for debugging
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Handle the response
      if (response.statusCode == 200) {
        // Parse and return the response data
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        // Handle non-200 responses
        final errorMessage = _parseErrorMessage(response.body);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      // Handle exceptions
      print("Error occurred during DELETE request: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

// Helper function to parse error messages
  String _parseErrorMessage(String responseBody) {
    try {
      final decodedBody = jsonDecode(responseBody);
      return decodedBody['message'] ?? 'An unknown error occurred.';
    } catch (e) {
      // If the response body isn't JSON, return it as-is
      return responseBody;
    }
  }

  Future<Map<String, dynamic>> fetchUserCreatedRequests() async {
    final String url = "$_baseUrl/request/my_requests";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': Auth().user!.uid,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get requests'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchUserDonatedRequests() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/on_the_way/my"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Auth().user!.uid
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get requests'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteBloodRequest({
    required int requestId,
  }) async {
    final url = Uri.parse("$_baseUrl/request?request_id=$requestId");
    try {
      print("Request URL: $url");
      print("Authorization Header: ${Auth().user!.uid}");

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${Auth().user!.uid}',
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Request deleted'};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print("Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

Future<Map<String, dynamic>> setCompletedOnTheWay({
    required int onTheWayId,
    required int requestId,
  }) async {
    final url = Uri.parse("$_baseUrl/on_the_way/$onTheWayId");
    try {
      print(onTheWayId);
      print(requestId);


      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${Auth().user!.uid}',
        },
        body: jsonEncode({
          'status': 'completed',
          'request_id': requestId,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Request deleted'};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print("Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }





}
