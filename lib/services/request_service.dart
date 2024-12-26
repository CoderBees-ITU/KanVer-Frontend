import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodRequestService {
  final String _baseUrl = "http://161.9.76.106:8080";

  Future<Map<String, dynamic>> createBloodRequest({
    required String requestedTcId,
    required String patientTcId,
    required String bloodType,
    required int donorCount,
    required int patientAge,
    required String hospital,
    required double latitude,
    required double longitude,
    required String note,
    required String gender,
  }) async {
    final url = Uri.parse("$_baseUrl/create_request");

    final body = {
      'requested_tc_id': requestedTcId,
      'patient_tc_id': patientTcId,
      'blood_type': bloodType,
      'age': patientAge,
      'gender': gender,
      'note': note,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'status': 'pending',
      'location': hospital,
      'donor_count': donorCount,
    };
    print(body);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

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
}
