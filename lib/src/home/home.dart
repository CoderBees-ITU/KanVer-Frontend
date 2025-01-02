// home.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/src/create-requestV1/createRequestV1.dart';
import 'package:kanver/src/my-profile/profile.dart';
import 'package:kanver/src/request-details/requestDetails.dart';
import 'package:kanver/src/widgets/filterModal.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kanver/services/auth_service.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/myRequests/myRequests.dart';
import 'package:kanver/src/widgets/CitySelectModal.dart';

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
    user.reload();
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
          'title': "${request['patient_name']} için kan aranıyor",
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
      print("Konum alınamadı: $e");
    }
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
    );
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
                    "E-posta Adresinizi Doğrulayın",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "E-posta adresinizi doğrulamak için size bir doğrulama e-postası gönderdik. Lütfen gelen kutunuzu kontrol edin.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _emailVerification,
                    child: Text("Doğrulama E-postası Tekrar Gönder"),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Mail Adresimi Doğruladım"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    print("Error: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent(
          selectedBloodType: _selectedBloodType,
          selectedCity: _selectedCity,
          selectedDistrict: _selectedDistrict,
          fetchRequestsFuture: _fetchRequestsFuture,
          onInitializeRequests: fetchBloodRequests,
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
        );
      case 1:
        return MyRequests();
      case 2:
        return ProfileScreen();
      default:
        return HomeContent(
          selectedBloodType: _selectedBloodType,
          selectedCity: _selectedCity,
          selectedDistrict: _selectedDistrict,
          fetchRequestsFuture: _fetchRequestsFuture,
          onInitializeRequests: _initializeRequests,
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
        );
    }
  }
}

// profile_screen.dart


// custom_bottom_navigation.dart
class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: const Color(0xff65558F),
      unselectedItemColor: Colors.grey,
    );
  }
}

// home_content.dart
class HomeContent extends StatefulWidget {
  final String selectedBloodType;
  final String selectedCity;
  final String selectedDistrict;
  final Future<List<Map<String, dynamic>>> fetchRequestsFuture;
  final Function() onInitializeRequests;
  final Function(String?) onBloodTypeSelected;
  final Function(String?) onCitySelected;
  final Function(String?) onDistrictSelected;

  const HomeContent({
    Key? key,
    required this.selectedBloodType,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.fetchRequestsFuture,
    required this.onInitializeRequests,
    required this.onBloodTypeSelected,
    required this.onCitySelected,
    required this.onDistrictSelected,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isInitialLoading = true;
  List<Map<String, dynamic>>? _requests;

  @override
  void initState() {
    super.initState();
    _loadRequests(); // First load => show full-screen spinner
  }

  /// Separate initial loading from refresh loading
  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      // Always set true so entire screen is blocked
      _isInitialLoading = true;
    });

    try {
      // optional: call initialize / fetch
      await widget.onInitializeRequests();
      final requests = await widget.onInitializeRequests();

      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isInitialLoading = false; // turn off loading after data arrives
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _requests ??= [];
        _isInitialLoading = false; // turn off loading even if error
      });
    }
  }

  Future<void> _refreshRequests() async {
    // This still calls the same method
    return _loadRequests();
  }

  @override
  void didUpdateWidget(HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedBloodType != widget.selectedBloodType ||
        oldWidget.selectedCity != widget.selectedCity ||
        oldWidget.selectedDistrict != widget.selectedDistrict) {
      // Reload after filter changes, with full-screen spinner again
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('İstekler'),
      ),
      body: Stack(
        children: [
          // Your normal content below
          Column(
            children: [
              _buildFilterButton(context),
              Expanded(
                // If you still want to use RefreshIndicator, that’s fine.
                child: RefreshIndicator(
                  onRefresh: _refreshRequests,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildRequestsList(),
                  ),
                ),
              ),
            ],
          ),

          // Full-screen overlay when loading
          if (_isInitialLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildRequestsList() {
    if (_requests == null || _requests!.isEmpty) {
      return const Center(child: Text("Kan isteği bulunmamaktadır."));
    }

    // Stack so we can overlay a top linear progress indicator when refreshing
    return Stack(
      children: [
        ListView.builder(
          itemCount: _requests!.length,
          itemBuilder: (context, index) {
            return _buildRequestCard(context, _requests![index]);
          },
        ),

        // if (_isInitialLoading) // Show a linear progress indicator at the top
        //   const Positioned(
        //     top: 0,
        //     left: 0,
        //     right: 0,
        //     child: LinearProgressIndicator(),
        //   ),
      ],
    );
  }

  // … Rest of your existing build methods (no major changes needed) …

  Widget _buildFilterButton(BuildContext context) {
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
        onPressed: () => _showFilterModal(context),
        child: _buildFilterButtonContent(),
      ),
    );
  }

  Widget _buildFloatingActionButton1(BuildContext context) {
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

  // Widget _buildRequestsList() {
  //   return FutureBuilder<List<Map<String, dynamic>>>(
  //     future: widget.fetchRequestsFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       if (snapshot.hasError) {
  //         return Center(child: Text("Hata: ${snapshot.error}"));
  //       }

  //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return const Center(child: Text("Kan isteği bulunmamaktadır."));
  //       }

  //       return ListView.builder(
  //         itemCount: snapshot.data!.length,
  //         itemBuilder: (context, index) =>
  //             _buildRequestCard(context, snapshot.data![index]),
  //       );
  //     },
  //   );
  // }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    return _CustomCard(
      title: request['title'],
      age: request['age'],
      blood: request['blood'],
      amount: request['amount'],
      time: request['time'],
      cityy: request['cityy'],
      districtt: request['districtt'],
      progress: request['progress'],
      request: request['request'],
      icon: const Icon(Icons.bloodtype),
      onArrowPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetails(
              patient_name: request['request']['patient_name'],
              patient_surname: request['request']['patient_surname'],
              request_id: request['request']['Request_ID'].toString(),
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

  Widget _buildFloatingActionButton(BuildContext context) {
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

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => FilterModal(
        onBloodTypeSelected: widget.onBloodTypeSelected,
        onCitySelected: widget.onCitySelected,
        onDistrictSelected: widget.onDistrictSelected,
        selectedCity: widget.selectedCity,
        selectedDistrict: widget.selectedDistrict,
        selectedBloodType: widget.selectedBloodType,
        getBloodRequests: widget.onInitializeRequests,
      ),
    );
  }
}

// custom_card.dart
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
  final Map<String, dynamic> request;

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
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onArrowPressed,
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

  Widget _buildCardHeader() {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: double.tryParse("0.4") ?? 0.0,
            backgroundColor: Color(0xffE8DEF8),
            valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xff65558F)), // Custom progress color
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
