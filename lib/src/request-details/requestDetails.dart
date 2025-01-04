import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/home/home.dart';
import 'package:kanver/src/widgets/pressButton.dart';
import 'package:kanver/src/widgets/requestDetailCard.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final Function? returnFunction;

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
    this.returnFunction,
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
    if (widget.type == 'bloodRequest') {
      _onDonationButtonPressedForSetOnTheWay();
    } else if (widget.type == 'participatedRequest') {
      _onDonationButtonPressedForDeleteOnTheWay();
    } else {
      _onDonationButtonPressedForDeleteRequest();
    }
  }

  _onDonationButtonPressedForDeleteRequest() {
    int? requestId = int.tryParse(widget.request_id);
    if (requestId == null) {
      print("Invalid request_id: ${widget.request_id}");
      return;
    }
    BloodRequestService().deleteBloodRequest(requestId: requestId).then(
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
    ).then(
      (value) {
        if (widget.returnFunction != null) {
          widget.returnFunction!();
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

  _onDonationButtonPressedForDeleteOnTheWay() {
    //final requestId = widget.request_id;
    int? requestId = int.tryParse(widget.request_id);
    if (requestId == null) {
      print("Invalid request_id: ${widget.request_id}");
      return;
    }

    BloodRequestService().deleteOnTheWay(requestId: requestId).then(
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
    ).then(
      (value) {
        if (widget.returnFunction != null) {
          widget.returnFunction!();
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

  _onDonationButtonPressedForSetOnTheWay() {
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
    ).then(
      (value) {
        if (widget.returnFunction != null) {
          widget.returnFunction!();
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

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final googleMapsAppUrl = 'geo:$latitude,$longitude';

    if (await canLaunch(googleMapsAppUrl)) {
      // Try to launch the app
      await launch(googleMapsAppUrl);
    } else if (await canLaunch(googleMapsUrl)) {
      // Fallback to web if app is not available
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
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
                GestureDetector(
                  onTap: () => _openGoogleMaps(widget.hospitalLocation.latitude,
                      widget.hospitalLocation.longitude),
                  child: CustomCard(
                    title: "Hastane",
                    desc: widget.hospitalName,
                    icon: const Icon(Icons.local_hospital),
                    additionalIcon: const Icon(Icons.directions)
                  ),
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
                      child: GestureDetector(
                          onTap: () => _openGoogleMaps(
                              widget.hospitalLocation.latitude,
                              widget.hospitalLocation.longitude),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(widget.hospitalLocation.latitude,
                                    widget.hospitalLocation.longitude),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('location'),
                                  position: LatLng(
                                      widget.hospitalLocation.latitude,
                                      widget.hospitalLocation.longitude),
                                ),
                              },
                            ),
                          ))),
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
                          : (widget.type == 'participatedRequest')
                              ? 'Bağışı İptal Et'
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
