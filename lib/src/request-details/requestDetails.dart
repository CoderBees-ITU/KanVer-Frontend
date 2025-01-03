import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/home/home.dart';
import 'package:kanver/src/widgets/pressButton.dart';
import 'package:kanver/src/widgets/requestDetailCard.dart';

class RequestDetails extends StatefulWidget {
  final String bloodType;
  final String donorAmount;
  final int patientAge;
  final String request_id;
  final String patient_name;
  final String patient_surname;
  final String hospitalName;
  final String additionalInfo;
  final LatLng hospitalLocation;
  final String type;

  const RequestDetails({
    Key? key,
    required this.bloodType,
    required this.donorAmount,
    required this.patientAge,
    required this.patient_name,
    required this.patient_surname,
    required this.request_id,
    required this.hospitalName,
    required this.additionalInfo,
    required this.hospitalLocation,
    required this.type,
  }) : super(key: key);

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  GoogleMapController? mapController;

  /// Track loading state when the button is pressed
  bool _isLoading = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// This method is triggered when your "press and hold" button completes
  void _onDonationButtonPressed() {
    setState(() {
      _isLoading = true; // Start loading spinner
    });

    BloodRequestService().setOnTheWay(requestId: widget.request_id).then(
      (response) {
        if (!mounted) return;
        setState(() {
          _isLoading = false; // Stop loading spinner
        });

        if (response['success']) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
            ),
          );
        }
      },
    ).catchError((error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading if error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kan Bağışı İsteği'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // --- Main Content ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  title: "Hasta Adı",
                  desc: "${widget.patient_name} ${widget.patient_surname}",
                  icon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Gereken Kan",
                  desc: widget.bloodType,
                  icon: const Icon(Icons.bloodtype),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Gereken Donör Sayısı",
                  desc: widget.donorAmount,
                  icon: const Icon(Icons.monitor_heart),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Hasta Yaşı",
                  desc: widget.patientAge.toString(),
                  icon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Hastane",
                  desc: widget.hospitalName,
                  icon: const Icon(Icons.local_hospital),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Ek Bilgiler: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: widget.additionalInfo,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 250, // fixed height for the map
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: widget.hospitalLocation,
                        zoom: 15.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('center_marker'),
                          position: widget.hospitalLocation,
                          infoWindow: InfoWindow(
                            title: widget.hospitalName,
                            snippet: 'Hastane Lokasyonu',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Space for the sticky button
              ],
            ),
          ),

          // --- Sticky Button at Bottom ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedPressButton(
                      text: (widget.type == 'bloodRequest')
                          ? 'Bağış Yapacağım'
                          : 'İsteği İptal et',
                      completeFunction: _onDonationButtonPressed,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Bağış Yapmak İçin Basılı Tutun",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // --- Full-Screen Loading Overlay ---
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
