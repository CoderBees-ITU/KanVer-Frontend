import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kanver/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:kanver/src/widgets/CitySelectModal.dart';
import 'package:location/location.dart' as loc;

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  final loc.Location _location = loc.Location();
  late bool _serviceEnabled;
  late loc.PermissionStatus _permissionGranted;
  late loc.LocationData _locationData;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await AuthService().getUserData();
      setState(() {
        userData = user['data'];
      });
      print(userData);
    } catch (e) {
      print('Failed to load user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeLocation() async {
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          print("Konum servisleri kapalı. Lütfen etkinleştirin.");
          return;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          _showCitySelectionModal();
          return;
        }
      }
      setState(() {
        _isLoading = true;
      });
      _locationData = await _location.getLocation();
      await _updateLocationData().then((_) async {
        await _loadUserData().then((_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Konum başarıyla güncellendi.'),
            ),
          );
        });
      });
    } catch (e) {
      print("Konum alınamadı: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      print("Konum bilgisi güncellenemedi: $e");
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
    ).whenComplete(() async {
      await _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Auth().signOut(),
            iconSize: 28,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Ad Soyad'),
                      subtitle:
                          Text("${userData['Name']} ${userData['Surname']}"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: const Text('TC Kimlik No'),
                      subtitle: Text(userData['TC_ID'].toString()),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.cake),
                      title: const Text('Doğum Tarihi'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(
                          DateFormat('EEE, dd MMM yyyy HH:mm:ss')
                              .parse(userData['Birth_Date']))),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.bloodtype),
                      title: const Text('Kan Grubu'),
                      subtitle: Text(userData['Blood_Type']),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('E-posta'),
                      subtitle: Text(userData['Email']),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('Konum'),
                      subtitle:
                          Text(userData["City"] + " / " + userData["District"]),
                      onTap: () {
                        _initializeLocation();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
