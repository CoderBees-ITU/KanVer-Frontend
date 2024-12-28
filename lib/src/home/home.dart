// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/auth_service.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/create-requestV1/createRequestV1.dart';
import 'package:kanver/src/request-details/requestDetails.dart';
import 'package:kanver/src/widgets/CitySelectModal.dart';
import 'package:kanver/src/widgets/filterModal.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:kanver/src/myRequests/myRequests.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _locationGet = false;
  String _selectedBloodType = 'Tümü';
  String _selectedCity = 'Tümü';
  String _selectedDistrict = "Tümü";
  final List<String> _cities = ["Tümü"];
  final List<Map<String, String>> _districts = [
    {"ilce_adi": "Tümü"}
  ];

  final loc.Location _location = loc.Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  late User user;
  bool _emailVerificationSent = false;
  Timer? _emailVerificationTimer;
  late Future<List<Map<String, dynamic>>> _fetchRequestsFuture;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _initializeRequests();
  }

  void _initializeUser() {
    user = Auth().user!;
    if (user.email == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (!user.emailVerified) {
      _emailVerification();
      _showEmailVerificationModal();
    } else if (!_locationGet) {
      _initializeLocation();
    }
  }

  @override
  void dispose() {
    _emailVerificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeRequests() async {
    _fetchRequestsFuture = fetchBloodRequests();
  }

  Future<List<Map<String, dynamic>>> fetchBloodRequests() async {
    try {
      final data = await BloodRequestService().getBloodRequests(
        bloodType: _selectedBloodType,
        city: _selectedCity,
        district: _selectedDistrict,
      );

      if (data['success'] != true) {
        _showError(data['message']);
        return [];
      }

      return List<Map<String, dynamic>>.from(data['data'].map((request) {
        return {
          'title': "${request['Patient_Name']} için kan aranıyor",
          'age': request['Age'] ?? 0,
          'blood': request['Blood_Type'] ?? 'N/A',
          'amount': request['Donor_Count'] ?? 0,
          'time': DateTime.parse(request['Create_Time']),
          'progress': request['Status'] ?? 'Unknown',
          'cityy': request['City'] ?? 'N/A',
          'districtt': request['District'] ?? 'N/A',
          'request': request,
        };
      }));
    } catch (e) {
      _showError("İstekler yüklenirken hata oluştu: $e");
      return [];
    }
  }

  Future<void> _emailVerification() async {
    if (_emailVerificationSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Doğrulama e-postası zaten gönderildi. Lütfen gelen kutunuzu kontrol edin."),
        ),
      );
      return;
    }

    try {
      await user.sendEmailVerification();
      setState(() {
        _emailVerificationSent = true;
      });

      _startEmailVerificationTimer();
    } catch (e) {
      _showError("E-posta doğrulama gönderilemedi: $e");
    }
  }

  void _startEmailVerificationTimer() {
    _emailVerificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await user.reload();
        if (user.emailVerified) {
          timer.cancel();
          setState(() {});
          Navigator.pop(context);
          _showSuccess("E-posta başarıyla doğrulandı!");
          _initializeLocation();
        }
      },
    );
  }

  Future<void> _initializeLocation() async {
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          _showError("Konum servisleri kapalı. Lütfen etkinleştirin.");
          return;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        final userData = await AuthService().getUserData();
        final user = userData['data'];

        if (_permissionGranted != PermissionStatus.granted &&
            user['City'] == null) {
          _showCitySelectionModal();
          return;
        }
      }

      _locationData = await _location.getLocation();
      await _updateLocationData();
    } catch (e) {
      // _showError("Konum alınamadı: $e");
    }
  }

  void _showCitySelectionModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CitySelectionModal();
      },
    ).then((result) {
      if (result != null) {
        print(
            "Selected City: ${result['city']}, District: ${result['district']}");
      }
    });
  }

  void _showEmailVerificationModal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  Text(
                    "Verify Your Email",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "A verification email has been sent to ${user.email}. Please verify your email to continue.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This window will close automatically in 60 seconds.",
                    textAlign: TextAlign.center,
                  ),
                  TweenAnimationBuilder<Duration>(
                    duration: Duration(seconds: 60),
                    tween:
                        Tween(begin: Duration(seconds: 60), end: Duration.zero),
                    onEnd: () {
                      Navigator.pop(context);
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      final minutes = value.inMinutes;
                      final seconds = value.inSeconds % 60;
                      return Text(
                        'Time remaining: $minutes:${seconds.toString().padLeft(2, '0')}',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  SizedBox(height: 1),
                  ElevatedButton(
                    onPressed: () async {
                      await _emailVerification();
                    },
                    child: Text("Resend Verification Email"),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      user.reload().then((_) {
                        print("Email Verified: ${user.emailVerified}");
                        if (user.emailVerified) {
                          // _emailVerificationTimer?.cancel();
                          Navigator.pop(context);
                          _initializeLocation();
                        }
                      });
                    },
                    child: Text("I've Verified My Email"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _updateLocationData() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final city = place.administrativeArea;
        final district = place.subAdministrativeArea;

        if (city != null && district != null) {
          await AuthService().updateLocation(city: city, district: district);
        }
      }
    } catch (e) {
      _showError("Konum bilgisi güncellenemedi: $e");
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1:
          Navigator.pushNamed(context, '/my-requests');
          break;
        case 2:
          Auth().signOut();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('İstekler'),
      ),
      body: Column(
        children: [
          _buildFilterButton(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRequestsList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff625B71),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          fixedSize: const Size(double.infinity, 40.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
        onPressed: _showFilterModal,
        child: _buildFilterButtonContent(),
      ),
    );
  }

  Widget _buildFilterButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Filtrele",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () {},
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchRequestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Kan isteği bulunmamaktadır."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              _buildRequestCard(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return _CustomCard(
      title: request['title'],
      age: request['age'],
      blood: request['blood'],
      amount: request['amount'],
      time: request['time'],
      cityy: request['cityy'],
      districtt: request['districtt'],
      progress: request['progress'],
      icon: const Icon(Icons.bloodtype),
      onArrowPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetails(
              bloodType: request['blood'],
              donorAmount: request['amount'].toString(),
              patientAge: request['age'],
              hospitalName: request['request']['Hospital'],
              additionalInfo: request['request']['Note'],
              hospitalLocation: LatLng(
                double.tryParse(request['request']['Lat']?.toString() ?? '0') ??
                    0.0,
                double.tryParse(request['request']['Lng']?.toString() ?? '0') ??
                    0.0,
              ),
              type: 'bloodRequest',
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateRequestV1()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B548D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(43),
          ),
          minimumSize: const Size(43, 43),
        ),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Ana Sayfa",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "İsteklerim",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profilim",
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xff65558F),
      unselectedItemColor: Colors.grey,
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => FilterModal(
        onBloodTypeSelected: (String? bloodType) {
          setState(() {
            _selectedBloodType = bloodType ?? 'Tümü';
          });
        },
        onCitySelected: (String? city) {
          setState(() {
            _selectedCity = city ?? 'Tümü';
          });
        },
        onDistrictSelected: (String? district) {
          setState(() {
            _selectedDistrict = district ?? 'Tümü';
          });
        },
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final String title;
  final int age;
  final String blood;
  final int amount;
  final DateTime time;
  final Icon icon;
  final VoidCallback onArrowPressed;
  final String progress;
  final String cityy;
  final String districtt;

  const _CustomCard({
    Key? key,
    required this.title,
    required this.age,
    required this.blood,
    required this.amount,
    required this.time,
    required this.icon,
    required this.onArrowPressed,
    required this.progress,
    required this.cityy,
    required this.districtt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetails(
              bloodType: blood,
              donorAmount: amount.toString(),
              patientAge: age,
              hospitalName: 'Hastane Adı',
              additionalInfo: 'Ek bilgi',
              hospitalLocation: const LatLng(41.0082, 28.9784),
              type: 'bloodRequest',
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(),
              _buildPatientInfo(),
              _buildLocationInfo(),
              _buildDonorInfo(),
            ],
          ),
        ),
      ),
    );
  }
  // Previous code remains the same until _CustomCard class's _buildCardHeader

  Widget _buildCardHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(progress.toString()),
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
    );
  }

  Widget _buildPatientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildInfoRow('Hasta Yaşı: ', age.toString()),
        const SizedBox(height: 4),
        _buildInfoRow('Kan Grubu: ', blood),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _buildInfoRow('İl: ', cityy),
        const SizedBox(height: 4),
        _buildInfoRow('İlçe: ', districtt),
      ],
    );
  }

  Widget _buildDonorInfo() {
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildInfoRow('İstenen Donör: ', amount.toString()),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 14),
                    const SizedBox(width: 4),
                    Text(_formatTime(time)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
            color: Color(0xff1D1A20),
          ),
        ),
        Text(value),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
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
  final String districtt;
  final Map<String, dynamic> request;

  const BloodRequest({
    required this.title,
    required this.age,
    required this.blood,
    required this.amount,
    required this.time,
    required this.progress,
    required this.cityy,
    required this.districtt,
    required this.request,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      title: "${json['Patient_Name']} için kan aranıyor",
      age: json['Age'] ?? 0,
      blood: json['Blood_Type'] ?? 'N/A',
      amount: json['Donor_Count'] ?? 0,
      time: json['Create_Time'] ?? '',
      progress: json['Status'] ?? 0.0,
      cityy: json['City'] ?? 'N/A',
      districtt: json['District'] ?? 'N/A',
      request: json,
    );
  }
}
