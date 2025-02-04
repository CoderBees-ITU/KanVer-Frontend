// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/my-request-details/my-request-details.dart';
import 'package:kanver/src/request-details/requestDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyRequests extends StatefulWidget {
  const MyRequests({Key? key}) : super(key: key);

  @override
  _MyRequestsState createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  bool _isLoading = false;
  String _userBloodType = 'B+';
  List<BloodRequest> _participatedRequests = [];
  List<BloodRequest> _createdRequests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _fetchParticipatedRequests(),
        _fetchCreatedRequests(),
      ]);
    } catch (e) {
      setState(() {
        _error = 'Veriler yüklenirken bir hata oluştu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchParticipatedRequests() async {
    print('fetching participated requests');
    try {
      final response = await BloodRequestService().fetchUserDonatedRequests();
      if (response['success'] && mounted) {
        setState(() {
          print(response['data']);
          _participatedRequests = (response['data'] as List).map((json) {
            print(json);
            return BloodRequest(
              title: "${json['patient_name']} için kan isteği",
              age: json['Age'] ?? 0,
              blood: json['Blood_Type'] ?? '',
              amount: json['Donor_Count'] ?? 0,
              time: json['Create_Time'] ?? '',
              progress: (json['On_The_Way_Count'] ?? 0) /
                  (json['Donor_Count'] == 0 ? 1 : json['Donor_Count']),
              cityy: json['City'] ?? '',
              districtt: json['District'] ?? '',
              status: json['Status'] ?? '',
              patient_name: json['patient_name'] ?? '',
              patient_surname: json['patient_surname'] ?? '',
              request_id: json['Request_ID']?.toString() ?? '',
              hospital: json['Hospital'] ?? '',
              note: json['Note'],
              lat: json['Lat']?.toString() ?? '',
              lng: json['Lng']?.toString() ?? '',
              requestType: "participatedRequest",
            );
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Katıldığınız istekler yüklenemedi: $e';
        });
      }
    }
  }

  Future<void> _fetchCreatedRequests() async {
    try {
      final response = await BloodRequestService().fetchUserCreatedRequests();
      if (response['success'] && mounted) {
        setState(() {
          print(response['data']);
          _createdRequests = (response['data'] as List).map((json) {
            return BloodRequest(
              title: "${json['patient_name']} için kan isteği",
              age: json['Age'] ?? 0,
              blood: json['Blood_Type'] ?? '',
              amount: json['Donor_Count'] ?? 0,
              time: json['Create_Time'] ?? '',
              progress: (json['On_The_Way_Count'] ?? 0) /
                  (json['Donor_Count'] == 0 ? 1 : json['Donor_Count']),
              cityy: json['City'] ?? '',
              districtt: json['District'] ?? '',
              status: json['Status'] ?? '',
              patient_name: json['patient_name'] ?? '',
              patient_surname: json['patient_surname'] ?? '',
              request_id: json['Request_ID']?.toString() ?? '',
              hospital: json['Hospital'] ?? '',
              note: json['Note'],
              lat: json['Lat']?.toString() ?? '',
              lng: json['Lng']?.toString() ?? '',
              onTheWays: json['on_the_ways'],
              requestType: "myRequests",
            );
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Oluşturduğunuz istekler yüklenemedi: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('İsteklerim'),
            bottom: TabBar(
              tabs: const [
                Tab(text: "Katıldığım İstekler"),
                Tab(text: "Oluşturduklarım"),
              ],
              indicatorColor: Color(0xff6B548D),
              labelColor: Color(0xff6B548D),
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: TabBarView(
              children: [
                _buildRequestsList(_participatedRequests,
                    'Gittiğiniz kan isteği bulunmamaktadır.'),
                _buildRequestsList(_createdRequests,
                    'Oluşturduğunuz kan isteği bulunmamaktadır.'),
              ],
            ),
          )),
    );
  }

  Widget _buildRequestsList(List<BloodRequest> requests, String emptyMessage) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (requests.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildRequestCard(requests[index]),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    return _CustomCard(
      title: request.title,
      age: request.age,
      requestId: request.request_id,
      blood: request.blood,
      amount: request.amount,
      time: _formatTime(request.time),
      icon: Icon(Icons.bloodtype),
      cityy: request.cityy,
      districtt: request.districtt,
      status: request.status,
      progress: request.progress,
      requestType: request.requestType,
      onArrowPressed: () => _navigateToDetails(request),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final DateTime time = DateTime.parse(timeStr + 'Z').toLocal();
      final Duration difference = DateTime.now().difference(time);

      if (difference.inDays > 0) {
        return '${difference.inDays} gün önce';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat önce';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return 'Az önce';
      }
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _handleReturnFromDetails() async {
    await _loadInitialData();
  }

  void _navigateToDetails(BloodRequest request) async {
    print(request.onTheWays);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        if (request.requestType == "myRequests") {
          return MyRequestDetails(
            patient_name: request.patient_name,
            patient_surname: request.patient_surname,
            bloodType: request.blood,
            request_id: request.request_id,
            donorAmount: request.amount.toString(),
            patientAge: request.age,
            hospitalName: request.hospital,
            additionalInfo: request.note ?? '',
            hospitalLocation: LatLng(
              double.tryParse(request.lat?.toString() ?? '0') ?? 0.0,
              double.tryParse(request.lng?.toString() ?? '0') ?? 0.0,
            ),
            type: request.requestType ?? 'bloodRequest',
            onTheWays: request.onTheWays,
            returnFunction: _handleReturnFromDetails,
          );
        } else {
          return RequestDetails(
            patient_name: request.patient_name,
            patient_surname: request.patient_surname,
            bloodType: request.blood,
            request_id: request.request_id,
            donorAmount: request.amount.toString(),
            patientAge: request.age,
            hospitalName: request.hospital,
            additionalInfo: request.note ?? '',
            hospitalLocation: LatLng(
              double.tryParse(request.lat?.toString() ?? '0') ?? 0.0,
              double.tryParse(request.lng?.toString() ?? '0') ?? 0.0,
            ),
            type: request.requestType ?? 'bloodRequest',
            returnFunction: _handleReturnFromDetails,
          );
        }
      }),
    );
    // If we get a result or pop back, refresh the data
    if (result == true || result == null) {
      await _handleReturnFromDetails();
    }
  }
}

class BloodRequest {
  final String title;
  final int age;
  final String blood;
  final int amount;
  final String time;
  final double progress;
  final String cityy;
  final String patient_surname;
  final String patient_name;
  final String districtt;
  final String status;
  final String request_id;
  final String hospital;
  final String? lat;
  final String? lng;
  final String? note;
  final String? requestType;
  final List<dynamic>? onTheWays;

  const BloodRequest({
    required this.title,
    required this.age,
    required this.blood,
    required this.amount,
    required this.time,
    required this.progress,
    required this.cityy,
    required this.districtt,
    required this.status,
    required this.patient_name,
    required this.patient_surname,
    required this.request_id,
    required this.hospital,
    this.requestType,
    this.note,
    this.lat,
    this.lng,
    this.onTheWays,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      title: "${json['Patient_Name'] ?? 'İsimsiz'} için kan isteği",
      age: json['Age'] ?? 0,
      blood: json['Blood_Type'] ?? 'Bilinmiyor',
      amount: json['Donor_Count'] ?? 1,
      time: json['Create_Time'] ?? DateTime.now().toIso8601String(),
      progress: (json['On_The_Way_Count'] ?? 0) /
          (json['Donor_Count'] == 0 ? 1 : json['Donor_Count']),
      cityy: json['City'] ?? 'Bilinmiyor',
      districtt: json['District'] ?? 'Bilinmiyor',
      status: json['Status'] ?? '',
      patient_name: json['Patient_Name'] ?? 'Bilinmiyor',
      patient_surname: json['Patient_Surname'] ?? 'Bilinmiyor',
      request_id: json['Request_ID']?.toString() ?? '0',
      hospital: json['Hospital'] ?? 'Bilinmiyor',
      note: json['Note'],
      onTheWays: json['On_The_Ways'] ?? [],
    );
  }
}

class _CustomCard extends StatelessWidget {
  final String title;
  final int age;
  final String blood;
  final int amount;
  final String time;
  final Icon icon;
  final String requestId;
  final VoidCallback onArrowPressed;
  final double progress;
  final String cityy;
  final String districtt;
  final String? lat;
  final String? lng;
  final String status;
  final String? requestType;

  const _CustomCard({
    Key? key,
    required this.title,
    required this.requestId,
    required this.age,
    required this.blood,
    required this.amount,
    required this.time,
    required this.icon,
    required this.onArrowPressed,
    required this.progress,
    required this.cityy,
    required this.districtt,
    required this.status,
    this.requestType,
    this.lat,
    this.lng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If status is 'completed' or 'closed', the card will be non-clickable
    final bool isCompletedOrClosed =
        (status == 'completed' || status == 'closed');

    return GestureDetector(
      // Disable clicks if completed or closed
      onTap: isCompletedOrClosed ? null : onArrowPressed,
      child: Card(
        elevation: 4,
        // Optionally use a different color if the card is disabled
        color: isCompletedOrClosed ? Colors.green[100] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show a top row if the status is 'closed' or 'completed'
              if (status == 'closed')
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Bu istek arşivlenmiştir",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff625B71),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Icon(Icons.archive, color: Color(0xff1D1B20), size: 16),
                    ],
                  ),
                )
              else if (status == 'completed')
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        requestType == "participatedRequest"
                            ? "Bağışınız tamamlanmıştır"
                            : "İstek tamamlanmıştır",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff625B71),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              // The progress bar and arrow icon are shown only if NOT closed/completed
              if (!isCompletedOrClosed)
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xffE8DEF8),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff65558F),
                        ), // Custom progress color
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xff1E1E1E),
                      ),
                      onPressed: onArrowPressed,
                    ),
                  ],
                ),
              Row(
                children: [
                  icon,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                        color: Color(0xff1D1A20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Hasta Yaşı: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20),
                    ),
                  ),
                  Text(age.toString()),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Kan Grubu: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20),
                    ),
                  ),
                  Text(blood),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'İl: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20),
                    ),
                  ),
                  Text(cityy),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'İlçe: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20),
                    ),
                  ),
                  Text(districtt),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: 'İstenen Donör'
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Text(
                            'İstenen Donör: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Roboto',
                              color: Color(0xff1D1A20),
                            ),
                          ),
                          Text(amount.toString()),
                        ],
                      ),
                    ),
                  ),
                  // Right side: time
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 14),
                          const SizedBox(width: 4),
                          Text(time),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
