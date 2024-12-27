// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/auth_service.dart';
import 'package:kanver/src/create-requestV1/createRequestV1.dart';
import 'package:kanver/src/request-details/requestDetails.dart';
import 'package:kanver/src/widgets/CitySelectModal.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';

class MyRequests extends StatefulWidget {
  @override
  _IsteklerimState createState() => _IsteklerimState();
}

class _IsteklerimState extends State<MyRequests> {
  int _selectedIndex = 0;

  String _userBloodType = 'B+';

  /* Future<void> _fetchUserBloodType() async {
    try {
      // Replace this with the actual API/database call
      String bloodTypeFromDB = await AuthService().getUserBloodType();
      setState(() {
        _userBloodType = bloodTypeFromDB;
      });
    } catch (e) {
      debugPrint('Error fetching user blood type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user information.')),
      );
    }
  } */

  // Location instance
  final loc.Location _location = loc.Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    // _fetchUserBloodType();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check if location services are enabled
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          _showError("Location services are disabled. Please enable them.");
          return;
        }
      }

      // Check for location permission
      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          _showCitySelectionModal();
          return;
        }
      }

      // Retrieve location data
      _locationData = await _location.getLocation();
      print(
          "Location Data: ${_locationData.latitude}, ${_locationData.longitude}");

      // Fetch city and district using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String? city = place.administrativeArea; // City name
        String? district = place.subAdministrativeArea; // District name

        print("City (İl): $city");
        print("District (İlçe): $district");
      }
    } catch (e) {
      _showError("Failed to get location: $e");
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPermissionDeniedModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Denied"),
          content: Text(
              "Location permission is denied. Please enable it in the app settings."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Navigation logic
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/');
      } else if (index == 2) {
        Auth().signOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: "Takip Ettiklerim" and "Oluşturduklarım"
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('İsteklerim'),
          bottom: TabBar(
            tabs: [
              Tab(text: "Takip Ettiklerim"),
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
          actions: [],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Takip Ettiklerim
            _buildTakipEttiklerimTab(),
            // Tab 2: Oluşturduklarım
            _buildOlusturduklarimTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              label: "My Profile",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xff65558F),
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  // Tab for "Takip Ettiklerim"
  Widget _buildTakipEttiklerimTab() {
    return FutureBuilder<List<BloodRequest>>(
      future: fetchBloodRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Kan isteği bulunamadı'));
        } else {
          // Filter requests based on the user's blood type
          final filteredRequests = snapshot.data!.where((request) {
            // Ensure request matches user's blood type
            if (request.blood != _userBloodType || request.isClosed) {
              return false;
            }
            return true; // Include request if it matches the blood type
          }).toList();

          return ListView.builder(
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return _CustomCard(
                title: request.title,
                age: request.age,
                blood: request.blood,
                amount: request.amount,
                time: request.time,
                icon: Icon(Icons.bloodtype),
                cityy: request.cityy,
                districtt: request.districtt,
                isClosed: request.isClosed,
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetails(
                        bloodType: request.blood,
                        donorAmount: request.amount.toString(),
                        patientAge: request.age,
                        hospitalName: 'Hastane Adı',
                        additionalInfo: 'Ek bilgi',
                        hospitalLocation: LatLng(41.0082, 28.9784),
                      ),
                    ),
                  );
                },
                progress: request.progress,
              );
            },
          );
        }
      },
    );
  }

  // Tab for "Oluşturduklarım"
  Widget _buildOlusturduklarimTab() {
    return FutureBuilder<List<BloodRequest>>(
      future:
          fetchUserCreatedRequests(), // Replace this with the actual backend function
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Hata: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Oluşturduğunuz kan isteği bulunmamaktadır.',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          final userCreatedRequests = snapshot.data!;
          return ListView.builder(
            itemCount: userCreatedRequests.length,
            itemBuilder: (context, index) {
              final request = userCreatedRequests[index];
              return _CustomCard(
                title: request.title,
                age: request.age,
                blood: request.blood,
                amount: request.amount,
                time: request.time,
                icon: Icon(Icons.bloodtype),
                cityy: request.cityy,
                districtt: request.districtt,
                isClosed: request.isClosed,
                onArrowPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetails(
                        bloodType: request.blood,
                        donorAmount: request.amount.toString(),
                        patientAge: request.age,
                        hospitalName: 'Hastane Adı',
                        additionalInfo: 'Ek bilgi',
                        hospitalLocation:
                            LatLng(41.0082, 28.9784), // Mock location
                      ),
                    ),
                  );
                },
                progress: request.progress,
              );
            },
          );
        }
      },
    );
  }

  Future<List<BloodRequest>> fetchBloodRequests() async {
    // Mock data
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return [
      BloodRequest(
        title: '2 Tüp Kan Bağışı Bekleniyor',
        age: 23,
        blood: '0+',
        amount: 2,
        time: '2 saat önce',
        progress: 0.5,
        cityy: 'İstanbul',
        districtt: 'Beşiktaş',
        isClosed: false,
      ),
      BloodRequest(
        title: '2 Tüp Kan Bağışı Bekleniyor',
        age: 35,
        blood: 'A+',
        amount: 2,
        time: '2 saat önce',
        progress: 0.75,
        cityy: 'İstanbul',
        districtt: 'Kadıköy',
        isClosed: false,
      ),
      BloodRequest(
        title: '2 Tüp Kan Bağışı Bekleniyor',
        age: 23,
        blood: 'B+',
        amount: 2,
        time: '2 saat önce',
        progress: 0.25,
        cityy: 'İstanbul',
        districtt: 'Kadıköy',
        isClosed: false,
      ),
      BloodRequest(
        title: '2 Tüp Kan Bağışı Bekleniyor',
        age: 16,
        blood: '0+',
        amount: 2,
        time: '2 saat önce',
        progress: 0.5,
        cityy: 'Ankara',
        districtt: 'Çankaya',
        isClosed: false,
      ),
      BloodRequest(
        title: '2 Tüp Kan Bağışı Bekleniyor',
        age: 27,
        blood: 'A+',
        amount: 2,
        time: '2 saat önce',
        progress: 0.75,
        cityy: 'Ankara',
        districtt: 'Çankaya',
        isClosed: false,
      ),
      BloodRequest(
        title: '2 Tüp Kan Bağışı Bekleniyor',
        age: 55,
        blood: 'B+',
        amount: 2,
        time: '2 saat önce',
        progress: 0.25,
        cityy: 'Ankara',
        districtt: 'Çankaya',
        isClosed: false,
      ),
    ];
  }

  Future<List<BloodRequest>> fetchUserCreatedRequests() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return [
      BloodRequest(
        title: 'Oluşturduğunuz İstek 1',
        age: 25,
        blood: 'B+',
        amount: 2,
        time: '1 saat önce',
        progress: 0.8,
        cityy: 'İstanbul',
        districtt: 'Kadıköy',
        isClosed: false,
      ),
      BloodRequest(
        title: 'Oluşturduğunuz İstek 2',
        age: 45,
        blood: '0-',
        amount: 1,
        time: '3 yıl önce',
        progress: 0.6,
        cityy: 'Ankara',
        districtt: 'Çankaya',
        isClosed: true,
      ),
    ];
  }
}

class _CustomCard extends StatelessWidget {
  final String title;
  final int age;
  final String blood;
  final int amount;
  final String time;
  final Icon icon;
  final VoidCallback onArrowPressed;
  final double progress;
  final String cityy;
  final String districtt;
  final bool isClosed;

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
    required this.isClosed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        !isClosed ? onArrowPressed : null;
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
              if (isClosed)
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
                        Icon(Icons.check, color: Color(0xff1D1B20), size: 16)
                      ]),
                ),
              Row(
                children: [
                  if (!isClosed)
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Color(0xffE8DEF8),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xff65558F)), // Custom progress color
                      ),
                    ),
                  if (!isClosed)
                    IconButton(
                      icon: Icon(
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
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Color(0xff1D1A20)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(children: [
                Text(
                  'Hasta Yaşı: ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20)),
                ),
                Text(age.toString()),
              ]),
              SizedBox(height: 4),
              Row(children: [
                Text(
                  'Kan Grubu: ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20)),
                ),
                Text(blood),
              ]),
              SizedBox(height: 4),
              Row(children: [
                Text(
                  'İl: ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20)),
                ),
                Text(cityy),
              ]),
              SizedBox(height: 4),
              Row(children: [
                Text(
                  'İlçe: ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      color: Color(0xff1D1A20)),
                ),
                Text(districtt),
              ]),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text(
                          'İstenen Donör: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Roboto',
                              color: Color(0xff1D1A20)),
                        ),
                        Text(amount.toString()),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 14),
                          SizedBox(width: 4),
                          Text(time),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
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
  final bool isClosed;

  BloodRequest({
    required this.title,
    required this.age,
    required this.blood,
    required this.amount,
    required this.time,
    required this.progress,
    required this.cityy,
    required this.districtt,
    required this.isClosed,
  });
}
