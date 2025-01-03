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
      query += "blood_type=$bloodType&";
    }

    final url = Uri.parse("$_baseUrl/request/personalized$query");
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

}
