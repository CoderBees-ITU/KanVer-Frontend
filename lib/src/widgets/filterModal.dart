import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterModal extends StatefulWidget {
  final Function(String?)? onBloodTypeSelected;
  final Function(String?)? onCitySelected;
  final Function(String?)? onDistrictSelected;
  final String selectedCity;
  final String selectedDistrict;
  final String selectedBloodType;
  final Function()? getBloodRequests;

  const FilterModal({
    Key? key,
    this.onBloodTypeSelected,
    this.onCitySelected,
    this.onDistrictSelected,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.selectedBloodType,
    this.getBloodRequests,
  }) : super(key: key);

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  List<dynamic> _cities = [];
  List<dynamic> _districts = [
    {"ilce_adi": "Tümü"}
  ];
  String _selectedCity = 'Tümü';
  String _selectedDistrict = 'Tümü';
  String _selectedBloodType = 'Tümü';

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _selectedDistrict = widget.selectedDistrict;
    _selectedBloodType = widget.selectedBloodType;
    _loadCities();
    if (_selectedCity != "Tümü") _loadDistricts(widget.selectedCity);
  }

  Future<void> _loadCities() async {
    try {
      final String response =
          await rootBundle.loadString('assets/il-ilce.json');
      final data = json.decode(response);
      setState(() {
        _cities = [
          {"il_adi": "Tümü", "ilceler": []},
          ...data['data']
        ];
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  Future<void> _loadDistricts(String cityName) async {
    print(cityName);
    try {
      final String response =
          await rootBundle.loadString('assets/il-ilce.json');
      final data = json.decode(response);
      final cityData = _cities.firstWhere(
        (city) => city['il_adi'] == cityName,
        orElse: () => null,
      );

      if (cityData != null) {
        setState(() {
          _districts = [
            {"ilce_adi": "Tümü"},
            ...cityData['ilceler']
          ];
          _selectedDistrict = "Tümü";
        });
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
  }

  void _onCitySelected(String? cityName) {
    widget.onCitySelected?.call(cityName);
    if (cityName == null || cityName == "Tümü") {
      setState(() {
        _selectedCity = "Tümü";
        _districts = [
          {"ilce_adi": "Tümü"}
        ];
        _selectedDistrict = "Tümü";
      });
      return;
    }

    final cityData = _cities.firstWhere(
      (city) => city['il_adi'] == cityName,
      orElse: () => null,
    );

    if (cityData != null) {
      setState(() {
        _selectedCity = cityName;
        _districts = [
          {"ilce_adi": "Tümü"},
          ...cityData['ilceler']
        ];
        _selectedDistrict = "Tümü";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Blood Type Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Kan Grubu',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              value: _selectedBloodType,
              isExpanded: true, // Prevents overflow by allowing text to wrap
              onChanged: (String? newValue) {
                widget.onBloodTypeSelected?.call(newValue);
                setState(() {
                  _selectedBloodType = newValue!;
                });
              },
              items: ['Tümü', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis, // Handles long text
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // City and District Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'İl',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    value: _selectedCity,
                    isExpanded: true, // Prevents overflow
                    onChanged: (String? newValue) {
                      _onCitySelected(newValue);
                    },
                    items: _cities.map<DropdownMenuItem<String>>((city) {
                      return DropdownMenuItem<String>(
                        value: city['il_adi'],
                        child: Text(
                          city['il_adi'],
                          overflow: TextOverflow.ellipsis, // Handles long text
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'İlçeler',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    value: _selectedDistrict,
                    isExpanded: true, // Prevents overflow
                    onChanged: (String? newValue) {
                      widget.onDistrictSelected?.call(newValue);
                      setState(() {
                        _selectedDistrict = newValue!;
                      });
                    },
                    items: _districts.map<DropdownMenuItem<String>>((district) {
                      return DropdownMenuItem<String>(
                        value: district['ilce_adi'],
                        child: Text(
                          district['ilce_adi'],
                          overflow: TextOverflow.ellipsis, // Handles long text
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Apply and Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onBloodTypeSelected?.call("Tümü");
                    widget.onCitySelected?.call("Tümü");
                    widget.onDistrictSelected?.call("Tümü");
                    setState(() {
                      _selectedBloodType = 'Tümü';
                      _selectedCity = 'Tümü';
                      _selectedDistrict = 'Tümü';
                      _districts = [
                        {"ilce_adi": "Tümü"}
                      ];
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Temizle'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // widget.getBloodRequests?.call();
                    Navigator.pop(context);
                  },
                  child: Text('Uygula'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
