import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/home/home.dart';
import 'package:kanver/src/widgets/pressButton.dart';
import 'package:kanver/src/widgets/requestDetailCard.dart';

class RequestDetails extends StatelessWidget {
  final String bloodType;
  final String donorAmount;
  final int patientAge;
  final String request_id;
  final String hospitalName;
  final String additionalInfo;
  final LatLng hospitalLocation;
  final String type;

  GoogleMapController? mapController;

  RequestDetails({
    required this.bloodType,
    required this.donorAmount,
    required this.patientAge,
    required this.request_id,
    required this.hospitalName,
    required this.additionalInfo,
    required this.hospitalLocation,
    required this.type,
  });

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kan Bağışı İsteği'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  title: "Gereken Kan",
                  desc: bloodType,
                  icon: const Icon(Icons.bloodtype),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Gereken Donör Sayısı",
                  desc: donorAmount,
                  icon: const Icon(Icons.monitor_heart),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Hasta Yaşı",
                  desc: patientAge.toString(),
                  icon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  title: "Hastane",
                  desc: hospitalName,
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
                          text: additionalInfo,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 250, // Set a fixed height for the map
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: hospitalLocation,
                        zoom: 15.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('center_marker'),
                          position: hospitalLocation,
                          infoWindow: InfoWindow(
                            title: hospitalName,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Ensures full width
                children: [
                  SizedBox(
                    width: double.infinity, // Full width
                    child: AnimatedPressButton(
                      completeFunction: () {
                        // Add your function here
                        BloodRequestService()
                            .setOnTheWay(requestId: request_id)
                            .then(
                          (response) {
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0), // Add spacing
                  const Text(
                    "Bağış Yapmak İçin Basılı Tutun",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
