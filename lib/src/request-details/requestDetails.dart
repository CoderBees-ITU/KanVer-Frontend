import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/src/widgets/requestDetailCard.dart';

class RequestDetails extends StatelessWidget {
  GoogleMapController? mapController;

  final LatLng _center = const LatLng(41.097952, 28.990461);

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32.0, 38.0, 32.0, 32.0),
                child: Column(
                  children: [
                    const CustomCard(
                        title: "Gereken Kan",
                        desc: "0 rh-",
                        icon: Icon(Icons.bloodtype)),
                    const SizedBox(height: 16),
                    const CustomCard(
                        title: "Gereken Donör Sayısı",
                        desc: "2 ünite kan",
                        icon: Icon(Icons.monitor_heart)),
                    const SizedBox(height: 16),
                    const CustomCard(
                        title: "Hasta Yaşı",
                        desc: "23",
                        icon: Icon(Icons.person)),
                    const SizedBox(height: 16),
                    const CustomCard(
                        title: "Hastane",
                        desc: "İstinye Sarıyer Devlet Hastanesi",
                        icon: Icon(Icons.local_hospital)),
                    const SizedBox(height: 16),
                     Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Ek Bilgiler: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Hasta çok ağır bir trafik kazası geçirdi ve bugün akşam 8’de ameliyata girecek.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 250, // Set a fixed height for the map
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 11.0,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('center_marker'),
                            position: _center,
                            infoWindow: const InfoWindow(
                              title: 'İstinye Sarıyer Devlet Hastanesi',
                              snippet: 'Hastane Lokasyonu',
                            ),
                          ),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff65558F),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        title: Text("Başlık"),
                        content: Text("İçerik"),
                      );
                    },
                  );
                },
                label: const Text("Bağış Yapacağım"),
                icon: const Icon(Icons.check),
              ),
            )
          ],
        ),
      ),
    );
  }
}
