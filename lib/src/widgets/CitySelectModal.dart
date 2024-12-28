import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanver/services/auth_service.dart';

class CitySelectionModal extends StatefulWidget {
  @override
  _CitySelectionModalState createState() => _CitySelectionModalState();
}

class _CitySelectionModalState extends State<CitySelectionModal> {
  List<dynamic> cities = [];
  List<dynamic> districts = [];
  String? selectedCity;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    // Load the JSON file
    final String response = await rootBundle.loadString('assets/il-ilce.json');
    final data = json.decode(response);
    setState(() {
      cities = data['data'];
    });
  }

  void onCitySelected(String? cityName) {
    setState(() {
      selectedCity = cityName;
      districts =
          cities.firstWhere((city) => city['il_adi'] == cityName)['ilceler'];
      selectedDistrict = null; // Reset district selection
    });
  }

  void onDistrictSelected(String? districtName) {
    setState(() {
      selectedDistrict = districtName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Lütfen Güncel Konumunuzu Seçiniz",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedCity,
            items: cities
                .map((city) => DropdownMenuItem<String>(
                      value: city['il_adi'],
                      child: Text(city['il_adi']),
                    ))
                .toList(),
            onChanged: onCitySelected,
            decoration: InputDecoration(
              labelText: "Şehir",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedDistrict,
            items: districts
                .map((district) => DropdownMenuItem<String>(
                      value: district['ilce_adi'],
                      child: Text(district['ilce_adi']),
                    ))
                .toList(),
            onChanged: onDistrictSelected,
            decoration: InputDecoration(
              labelText: "İlçe",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedCity != null && selectedDistrict != null) {
                print("Selected City: $selectedCity, District: $selectedDistrict");
                AuthService().updateLocation(
                  city: selectedCity!,
                  district: selectedDistrict!,
                );
                Navigator.pop(context, {
                  'city': selectedCity,
                  'district': selectedDistrict,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please select both city and district"),
                  ),
                );
              }
            },
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }
}
