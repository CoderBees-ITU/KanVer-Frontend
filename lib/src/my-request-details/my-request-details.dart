import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/request_service.dart';
import 'package:kanver/src/widgets/OnTheWayPerson.dart';
import 'package:kanver/src/widgets/requestDetailCard.dart';
import 'package:kanver/src/widgets/pressButton.dart';

class MyRequestDetails extends StatefulWidget {
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

  /// This is the new property with the list of donors who are on the way or have completed
  final List<dynamic>? onTheWays;

  const MyRequestDetails({
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
    this.onTheWays,
  }) : super(key: key);

  @override
  State<MyRequestDetails> createState() => _MyRequestDetailsState();
}

class _MyRequestDetailsState extends State<MyRequestDetails> {
  GoogleMapController? mapController;

  /// Track loading state when the button is pressed
  bool _isLoading = false;

  /// Handles the logic for deleting the request
  void _onDonationButtonPressedForDeleteRequest() {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    int? requestId = int.tryParse(widget.request_id);
    if (requestId == null) {
      debugPrint("Invalid request_id: ${widget.request_id}");
      return;
    }

    BloodRequestService().deleteBloodRequest(requestId: requestId).then(
      (response) {
        if (!mounted) return;
        setState(() {
          _isLoading = false; // Stop loading spinner
        });

        if (response['success']) {
          // Pop back to previous screen
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
        // If there's a callback function passed in, call it
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

  void checkRequestCompeted() {
    if (widget.onTheWays != null) {
      for (var onTheWay in widget.onTheWays!) {
        if (onTheWay["Status"] == "completed") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bağış tamamlandı!'),
            ),
          );
          break;
        }
      }
    }
  }

  bool checkJustOneOnTheWay() {
    if (widget.onTheWays != null) {
      int count = 0;
      for (var onTheWay in widget.onTheWays!) {
        if (onTheWay["Status"] == "on_the_way") {
          count++;
          if (count > 1) {
            return false;
          }
        }
      }
      return count == 1;
    }
    return false;
  }




  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kan Bağışı İsteği'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            // --- Main Content Scrollable ---
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
                    additionalIcon: const Icon(Icons.directions),
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

                  // -------- OnTheWay Person Cards --------
                  if (widget.onTheWays != null && widget.onTheWays!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Bağış İçin Yolda Olanlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Map each item in onTheWays to an OnTheWayCard
                        ...widget.onTheWays!.map((onTheWay) {
                          return OnTheWayCard(
                            donorName: onTheWay["Donor_Name"] ?? "",
                            donorSurname: onTheWay["Donor_Surname"] ?? "",
                            donorBloodType: onTheWay["Donor_Blood_Type"] ?? "",
                            donorCity: onTheWay["Donor_City"] ?? "",
                            initialStatus: onTheWay["Status"] ?? "",
                            createTime: DateTime.parse(onTheWay["Create_Time"] + "Z").toLocal(),
                            requestId: int.parse(widget.request_id),
                            onTheWayId: onTheWay["ID"],
                            checkOnTheWayCount: () => checkJustOneOnTheWay(),
                          );
                        }).toList(),
                      ],
                    ),

                  // Add space so nothing is covered by the sticky button
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // --- Sticky Button at the Bottom ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedPressButton(
                        text: 'İsteği İptal et',
                        completeFunction: _onDonationButtonPressedForDeleteRequest,
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
      ),
    );
  }
}
