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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  String _selectedBloodType = 'Tümü';
  String _selectedAgeGroup = 'Tümü';
  String _selectedCity = 'Tümü';
  String _selectedDistrict = 'Tümü';
  List<String> _cities = [
    'Tümü',
    'İstanbul',
    'Ankara',
    'İzmir'
  ]; // Mock city list
  Map<String, List<String>> _districts = {
    'Tümü': ['Tümü'],
    'İstanbul': ['Tümü', 'Kadıköy', 'Beşiktaş', 'Üsküdar'],
    'Ankara': ['Tümü', 'Çankaya', 'Keçiören'],
    'İzmir': ['Tümü', 'Bornova', 'Konak'],
  };

  // Location instance
  final loc.Location _location = loc.Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('İstekler'),
        actions: [],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0), // Outer padding

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xff625B71), // Adjust the color to match the design
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                fixedSize: Size(double.infinity, 40.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 4.0),
                                    labelText:
                                        'Kan grubu', // Label above the dropdown
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  value: _selectedBloodType,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBloodType = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    'Tümü',
                                    'A+',
                                    'A-',
                                    'B+',
                                    'B-',
                                    'AB+',
                                    'AB-',
                                    'O+',
                                    'O-'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 4.0),
                                    labelText:
                                        'Yaş', // Label above the dropdown
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  value: _selectedAgeGroup,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedAgeGroup = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    'Tümü',
                                    '18-25',
                                    '26-35',
                                    '36-45',
                                    '46-60',
                                    '60+'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 4.0),
                                    labelText: 'İl', // Label above the dropdown
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  value: _selectedCity,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCity = newValue!;
                                      _selectedDistrict =
                                          'Tümü'; // Reset district
                                      print('Selected City: $_selectedCity');
                                    });
                                  },
                                  items: _cities.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 4.0),
                                    labelText:
                                        'İlçe', // Label above the dropdown
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  value: _selectedDistrict,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedDistrict = newValue!;
                                      print(
                                          'Selected District: $_selectedDistrict');
                                    });
                                  },
                                  items: _districts[_selectedCity]!
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedBloodType = 'Tümü';
                                    _selectedAgeGroup = 'Tümü';
                                    _selectedCity = 'Tümü';
                                    _selectedDistrict = 'Tümü';
                                  });
                                },
                                child: Text(
                                  'Filtreleri temizle',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Color(0xff625B71)),
                                ),
                              ),
                              /* ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Filtreleri Uygula'),
                              ), */
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
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
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          onPressed: () {}),
                      IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FutureBuilder<List<BloodRequest>>(
                      future: fetchBloodRequests(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Kan isteği bulunamadı'));
                        } else {
                          final filteredRequests =
                              snapshot.data!.where((request) {
                            if (_selectedBloodType != 'Tümü' &&
                                request.blood != _selectedBloodType) {
                              return false;
                            }
                            if (_selectedAgeGroup != 'Tümü') {
                              final age = request.age;
                              switch (_selectedAgeGroup) {
                                case '18-25':
                                  if (age < 18 || age > 25) return false;
                                  break;
                                case '26-35':
                                  if (age < 26 || age > 35) return false;
                                  break;
                                case '36-45':
                                  if (age < 36 || age > 45) return false;
                                  break;
                                case '46-60':
                                  if (age < 46 || age > 60) return false;
                                  break;
                                case '60+':
                                  if (age < 60) return false;
                                  break;
                              }
                            }
                            if (_selectedCity != 'Tümü' &&
                                request.cityy.toLowerCase() !=
                                    _selectedCity.toLowerCase()) {
                              return false;
                            }
                            if (_selectedDistrict != 'Tümü' &&
                                request.districtt.toLowerCase() !=
                                    _selectedDistrict.toLowerCase()) {
                              return false;
                            }

                            return true;
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
                                            LatLng(41.0082, 28.9784),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight, // Adjust position as needed
        child: Padding(
          padding: const EdgeInsets.all(0), // Adjust padding for spacing
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateRequestV1()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B548D), // Purple background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(43), // Rounded corners
              ),
              minimumSize: Size(43, 43), // Custom size
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 24,
                  color: Colors.white, // White icon color
                ),
              ],
            ),
          ),
        ),
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
                hospitalLocation: LatLng(41.0082, 28.9784),
              ),
            ));
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
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Color(0xffE8DEF8),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff65558F)), // Custom progress color
                    ),
                  ),
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

  BloodRequest({
    required this.title,
    required this.age,
    required this.blood,
    required this.amount,
    required this.time,
    required this.progress,
    required this.cityy,
    required this.districtt,
  });
}
