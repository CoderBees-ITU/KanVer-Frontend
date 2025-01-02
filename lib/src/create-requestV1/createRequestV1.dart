import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Make sure this import actually provides APIKey().MapsApiKey
import 'package:kanver/services/auth_service.dart';
import 'package:kanver/services/request_service.dart';

class CreateRequestV1 extends StatefulWidget {
  const CreateRequestV1({Key? key}) : super(key: key);

  @override
  _CreateRequestV1State createState() => _CreateRequestV1State();
}

class _CreateRequestV1State extends State<CreateRequestV1> {
  // Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // Make sure APIKey().MapsApiKey returns a non-empty string
  final String apiKey = APIKey().MapsApiKey;

  // Variables to store form inputs
  String? formType = 'Kendim için'; // Default form type
  String? tcNumber;
  String? bloodGroup;
  String? age;
  String? gender;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedHospital;
  String? unitCount;
  String? additionalInfo;
  String? patientName;
  String? patientSurname;

  // Dropdown options
  final List<String> formTypeOptions = ['Kendim için', 'Yakınım için'];
  final List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    '0+',
    '0-'
  ];
  final List<String> genderOptions = [
    'Erkek',
    'Kadın',
    'Belirtmek istemiyorum'
  ];

  // Data loaded from il-ilce.json
  List<dynamic> cities = [];
  List<dynamic> districts = [];
  List<dynamic> hospitals = [];

  /// Loading state for fetching hospitals
  bool isLoadingHospitals = false;

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  /// Loads city/district data from local JSON
  Future<void> loadCities() async {
    try {
      final String response =
          await rootBundle.loadString('assets/il-ilce.json');
      final data = json.decode(response);
      setState(() {
        cities = data['data'];
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  /// Called when the user selects a new city from the dropdown
  void onCitySelected(String? cityName) {
    if (cityName == null) {
      // If user deselected city, reset everything
      setState(() {
        selectedCity = null;
        districts = [];
        selectedDistrict = null;
        selectedHospital = null;
        hospitals = [];
      });
      return;
    }

    // Attempt to find the city in our loaded data
    final cityData = cities.firstWhere(
      (city) => city['il_adi'] == cityName,
      orElse: () => null,
    );

    if (cityData == null) {
      // City not found: reset everything
      setState(() {
        selectedCity = null;
        districts = [];
        selectedDistrict = null;
        selectedHospital = null;
        hospitals = [];
      });
      return;
    }

    // City found: update state with new city/district data
    setState(() {
      selectedCity = cityName;
      districts = cityData['ilceler'] ?? [];
      selectedDistrict = null;
      selectedHospital = null;
      hospitals = [];
    });
  }

  String text = 'Hello World';

  /// Called when the user selects a new district from the dropdown
  Future<void> onDistrictSelected(String? districtName) async {
    if (districtName == null) {
      // District deselected
      setState(() {
        selectedDistrict = null;
        selectedHospital = null;
        hospitals = [];
      });
      return;
    }

    setState(() {
      selectedDistrict = districtName;
      selectedHospital = null;
      hospitals = [];
      isLoadingHospitals = true; // Start loading
    });

    // If we have a valid API key, city, and district, fetch hospitals
    if (apiKey.isNotEmpty &&
        selectedCity != null &&
        selectedCity!.isNotEmpty &&
        districtName.isNotEmpty) {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=hastaneler+${Uri.encodeQueryComponent(selectedCity!)}+${Uri.encodeQueryComponent(districtName)}'
        '&language=tr'
        '&key=$apiKey',
      );

      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            hospitals = data['results'] ?? [];
            isLoadingHospitals = false; // Finished loading
          });

          if (hospitals.isNotEmpty) {
            debugPrint('${hospitals.length} hospitals found');
          } else {
            debugPrint('No hospitals found');
          }
        } else {
          debugPrint(
            'Failed to load hospitals. Status: ${response.statusCode}',
          );
          setState(() {
            isLoadingHospitals = false; // Stop loading even on failure
          });
        }
      } catch (error) {
        debugPrint('Error fetching hospitals: $error');
        setState(() {
          isLoadingHospitals = false;
        });
      }
    } else {
      setState(() {
        isLoadingHospitals = false; // No valid search or API key
      });
    }
    text = jsonEncode(hospitals[0]);
  }

  /// Save form to the database (mock function)
  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = {
        'formType': formType,
        'tcNumber': tcNumber,
        'bloodGroup': bloodGroup,
        'age': age,
        'gender': gender,
        'city': selectedCity,
        'district': selectedDistrict,
        'hospitalAddress': selectedHospital,
        'unitCount': unitCount,
        'additionalInfo': additionalInfo,
      };

      dynamic response = await BloodRequestService().createBloodRequest(
        patientTcId: int.tryParse(tcNumber ?? '0') ?? 0,
        bloodType: bloodGroup ?? '',
        donorCount: int.tryParse(unitCount ?? '0') ?? 0,
        patientAge: int.tryParse(age ?? '0') ?? 0,
        hospital: jsonDecode(selectedHospital!),
        note: additionalInfo ?? '',
        gender: gender!,
        city: selectedCity!,
        district: selectedDistrict!,
        patientName: patientName ?? '',
        patientSurname: patientSurname ?? '',
      );
      if (response['success']) {
        print("Request created successfully");
        Navigator.pop(context);
      } else {
        showAboutDialog(
            context: context,
            applicationName: "Error",
            children: [Text("Error creating request")]);
      }

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form successfully submitted!')),
      );
    }
  }

  /// Build the list of hospital dropdown items
  /// If loading, show a single DropdownMenuItem with a progress indicator
  List<DropdownMenuItem<String>> _buildHospitalItems() {
    if (isLoadingHospitals) {
      return [
        DropdownMenuItem<String>(
          value: null,
          child: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('Hastaneler yükleniyor...'),
            ],
          ),
        )
      ];
    }

    // If not loading, show the actual list
    return hospitals.map((hospital) {
      final hospitalMap = {
        'name': hospital['name'],
        'address': hospital['formatted_address'],
        'coordinates': {
          'latitude': hospital['geometry']['location']['lat'],
          'longitude': hospital['geometry']['location']['lng'],
        },
      };

      return DropdownMenuItem<String>(
        value: json.encode(hospitalMap),
        child: Text(hospital['name'] ?? 'Hastane'),
      );
    }).toList();
  }

  /// Build truncated or full text for the selected hospital item
  List<Widget> _buildHospitalSelectedItems(BuildContext context) {
    if (isLoadingHospitals) {
      // While loading, show the same progress text
      return [
        Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Hastaneler yükleniyor...'),
          ],
        ),
      ];
    }

    // Not loading: map hospitals to text widgets
    return hospitals.map((hospital) {
      final name = hospital['name'] ?? 'Hastane';
      return Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // show "..."
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağış İsteği Formu'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 70),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kimin için oluşturuyorum?",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Form Type Dropdown
                  DropdownButtonFormField<String>(
                    value: formType,
                    items: formTypeOptions
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                  color: Color.fromRGBO(84, 76, 76, 1),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        formType = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 300.0,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Conditionally Render Fields IF "Yakınım için"
                  if (formType == 'Yakınım için') ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hasta T.C. kimlik numarası:",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Hastanın T.C. kimlik numarası...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(84, 76, 76, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => tcNumber = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'T.C. kimlik numarası gerekli';
                        } else if (value.length != 11 ||
                            !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'T.C. kimlik numarası 11 haneli olmalıdır';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hastanın Adı:",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Hastanın Adı...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(84, 76, 76, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                      ),
                      onSaved: (value) => patientName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hasta adı gerekli';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hastanın Soyadı:",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Hastanın Soyadı...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(84, 76, 76, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                      ),
                      onSaved: (value) => patientSurname = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hasta soyadı gerekli';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Kan Grubu:",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    DropdownButtonFormField<String>(
                      value: bloodGroup,
                      items: bloodGroupOptions
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        bloodGroup = value;
                      }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kan grubu gerekli';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Hastanın kan grubu...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(84, 76, 76, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      menuMaxHeight: 300.0,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Yaş:",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Hastanın yaşı...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(84, 76, 76, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yaş gerekli';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onSaved: (value) => age = value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Cinsiyet:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: genderOptions
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      gender = value;
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cinsiyet gerekli';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Erkek/Kadın/Belirtmek istemiyorum',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 300.0,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Common Fields (applies both to "Kendim için" and "Yakınım için")
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hastane İl:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    hint: const Text('İller'),
                    items: cities
                        .map((city) => DropdownMenuItem<String>(
                              value: city['il_adi'] as String,
                              child: Text(city['il_adi'] as String),
                            ))
                        .toList(),
                    onChanged: onCitySelected,
                    decoration: InputDecoration(
                      labelText: 'İller',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'İl gerekli';
                      }
                      return null;
                    },
                    dropdownColor: Colors.white,
                    menuMaxHeight: 300.0,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hastane İlçe:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    isExpanded: true,
                    hint: const Text('İlçeler'),
                    items: districts
                        .map((district) => DropdownMenuItem<String>(
                              value: district['ilce_adi'],
                              child: Text(district['ilce_adi']),
                            ))
                        .toList(),
                    onChanged: onDistrictSelected,
                    decoration: InputDecoration(
                      labelText: 'İlçeler',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'İlçe gerekli';
                      }
                      return null;
                    },
                    dropdownColor: Colors.white,
                    menuMaxHeight: 300.0,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hastane Açık Adres:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Hospitals Dropdown with loading state
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedHospital,
                    hint: const Text(
                      'Hastane adresi...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                    ),

                    items: _buildHospitalItems(),
                    // We only need selectedItemBuilder if you want truncated text
                    selectedItemBuilder: _buildHospitalSelectedItems,
                    onChanged: (value) {
                      setState(() {
                        selectedHospital = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hastane adresi gerekli';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    menuMaxHeight: 300.0,
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kaç ünite kan gerekiyor:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonFormField<int>(
                    value: unitCount != null ? int.tryParse(unitCount!) : null,
                    items: List.generate(10, (index) => index + 1)
                        .map((number) => DropdownMenuItem<int>(
                              value: number,
                              child: Text(number.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        unitCount = value?.toString();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Adet...',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Ünite sayısı gerekli';
                      }
                      return null;
                    },
                    dropdownColor: Colors.white,
                    menuMaxHeight: 300.0,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1),
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ek Bilgiler:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Ek bilgiler (isteğe bağlı)...',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                    maxLines: 3, // Allows multiline input
                    maxLength: 240, // Restricts input to 200 characters
                    keyboardType:
                        TextInputType.multiline, // Multiline input type
                    onSaved: (value) =>
                        additionalInfo = value, // Save input to variable
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // Submit Button at the Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6B548D), // Button color
                  fixedSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 24.0,
                  ),
                ),
                child: const Text(
                  'Oluştur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
