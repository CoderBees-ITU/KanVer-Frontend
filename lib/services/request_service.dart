import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kanver/services/auth_service.dart';

class BloodRequestService {
  final String _baseUrl = "http://192.168.1.174:8080";

  Future<Map<String, dynamic>> createBloodRequest({
    required int requestedTcId,
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

    print(hospital);
    final body = {
      'requested_tc_id': requestedTcId,
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
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': 'Request created'};
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

    if (city == "Tümü") {
      city = "";
    } else {
      query += "city=$city&";
    }
    if (district == "Tümü") {
      district = "";
    } else {
      query += "district=$district&";
    }
    if (bloodType == "Tümü") {
      bloodType = "";
    } else {
      query += "blood_type=$bloodType&";
    }

    final url = Uri.parse("$_baseUrl/request/personalized");
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Auth().user!.uid
        },
      );
      // print(response.body);
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
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get request'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
