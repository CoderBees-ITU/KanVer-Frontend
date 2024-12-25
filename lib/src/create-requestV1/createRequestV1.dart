import 'package:flutter/material.dart';

class CreateRequestV1 extends StatefulWidget {
  @override
  _CreateRequestV1State createState() => _CreateRequestV1State();
}

class _CreateRequestV1State extends State<CreateRequestV1> {
  // Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // Variables to store form inputs
  String? formType = 'Kendim için'; // Default form type
  String? tcNumber;
  String? bloodGroup;
  String? age;
  String? gender;
  String? city;
  String? district;
  String? hospitalAddress;
  String? unitCount;

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
  final List<String> cityOptions = ['İstanbul', 'Ankara', 'İzmir', 'Bursa'];
  final Map<String, List<String>> districtOptions = {
    'İstanbul': ['Beşiktaş', 'Kadıköy', 'Üsküdar'],
    'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle'],
    'İzmir': ['Karşıyaka', 'Bornova', 'Konak'],
    'Bursa': ['Osmangazi', 'Nilüfer', 'Yıldırım']
  };

  // Current district list based on selected city
  List<String> currentDistrictOptions = [];

  @override
  void initState() {
    super.initState();
    _updateDistrictOptions();
  }

  // Update district options based on selected city
  void _updateDistrictOptions() {
    setState(() {
      currentDistrictOptions = districtOptions[city ?? cityOptions.first] ?? [];
    });
  }

  // Save form to the database (mock function)
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Example: Save data to a database
      final formData = {
        'formType': formType,
        'tcNumber': tcNumber,
        'bloodGroup': bloodGroup,
        'age': age,
        'gender': gender,
        'city': city,
        'district': district,
        'hospitalAddress': hospitalAddress,
        'unitCount': unitCount,
      };

      // Mock saving to a database
      print('Form Saved: $formData');

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form successfully submitted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bağış İsteği Formu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              //LABEL FOR INPUT
              Align(
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
              SizedBox(height: 2),
              // Form Type Dropdown

              DropdownButtonFormField<String>(
                value: formType,
                items: formTypeOptions
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            textAlign: TextAlign.left, // Align text to the left
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                                color: Color.fromRGBO(84, 76, 76, 1)),
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
                      vertical: 16.0,
                      horizontal: 15.0), // Inner padding for input
                ),
                // Additional dropdown styling properties
                dropdownColor: Colors.white, // Dropdown menu background color
                menuMaxHeight: 300.0, // Set max height for the dropdown menu

                icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(84, 76, 76, 1),
                ),
              ),
              SizedBox(height: 10),

              // Conditionally Render Fields
              if (formType == 'Yakınım için') ...[
                Align(
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

                SizedBox(height: 2),
                // INPUT TC
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Hastanın T.C. kimlik numarası...',
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Prevent label from floating
                    labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 15.0),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => tcNumber = value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1)),
                ),

                SizedBox(height: 6),
                //LABEL FOR INPUT
                Align(
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
                SizedBox(height: 2),
                DropdownButtonFormField<String>(
                  items: bloodGroupOptions
                      .map((group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ))
                      .toList(),
                  onChanged: (value) => bloodGroup = value,
                  decoration: InputDecoration(
                    labelText: 'Hastanın kan grubu...',
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Prevent label from floating
                    labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 15.0),
                  ),
                  // Additional dropdown styling properties
                  dropdownColor: Colors.white, // Dropdown menu background color
                  menuMaxHeight: 300.0, // Set max height for the dropdown menu

                  icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: Color.fromRGBO(84, 76, 76, 1),
                  ),
                ),
                SizedBox(height: 6),
                Align(
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
                SizedBox(height: 2),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Hastanın yaşı...',
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Prevent label from floating
                    labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 15.0),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => age = value,
                ),
                SizedBox(height: 6),
                Align(
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
                SizedBox(height: 2),
                DropdownButtonFormField<String>(
                  items: genderOptions
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) => gender = value,
                  decoration: InputDecoration(
                    labelText: 'Erkek/Kadın/Belirtmek istemiyorum ',
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Prevent label from floating
                    labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Color.fromRGBO(84, 76, 76, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 15.0),
                  ),
                  // Additional dropdown styling properties
                  dropdownColor: Colors.white, // Dropdown menu background color
                  menuMaxHeight: 300.0, // Set max height for the dropdown menu

                  icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: Color.fromRGBO(84, 76, 76, 1),
                  ),
                ),
                SizedBox(height: 6),
              ],

              // Common Fields
              Align(
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
              SizedBox(height: 2),
              DropdownButtonFormField<String>(
                value: city,
                items: cityOptions
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    city = value;
                    _updateDistrictOptions();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'İller',
                  floatingLabelBehavior: FloatingLabelBehavior
                      .never, // Prevent label from floating
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 15.0),
                ),
                // Additional dropdown styling properties
                dropdownColor: Colors.white, // Dropdown menu background color
                menuMaxHeight: 300.0, // Set max height for the dropdown menu

                icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(84, 76, 76, 1),
                ),
              ),
              SizedBox(height: 6),
              Align(
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
              SizedBox(height: 2),
              DropdownButtonFormField<String>(
                items: currentDistrictOptions
                    .map((district) => DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        ))
                    .toList(),
                onChanged: (value) => district = value,
                decoration: InputDecoration(
                  labelText: 'İlçeler',
                  floatingLabelBehavior: FloatingLabelBehavior
                      .never, // Prevent label from floating
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 15.0),
                ),
                // Additional dropdown styling properties
                dropdownColor: Colors.white, // Dropdown menu background color
                menuMaxHeight: 300.0, // Set max height for the dropdown menu

                icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(84, 76, 76, 1),
                ),
              ),
              SizedBox(height: 6),
              Align(
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
              SizedBox(height: 2),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Hastanenin Açık Adresi...',
                  floatingLabelBehavior: FloatingLabelBehavior
                      .never, // Prevent label from floating
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 15.0),
                ),
                onSaved: (value) => hospitalAddress = value,
              ),
              SizedBox(height: 6),
              Align(
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
              SizedBox(height: 2),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Adet...',
                  floatingLabelBehavior: FloatingLabelBehavior
                      .never, // Prevent label from floating
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color.fromRGBO(84, 76, 76, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 15.0),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => unitCount = value,
              ),

              SizedBox(height: 6),

              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(
                    'Oluştur',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff6B548D), // Button color
                    fixedSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


































/* import 'package:flutter/material.dart';

class CreateRequestV1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Color(0xff1D1A20)), // Custom icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
        title: Text(
          "Bağış İsteği Formu",
          style: TextStyle(
              color: Color(0xff1D1A20), fontFamily: 'Roboto', fontSize: 22),
        ), // Title in the app bar
        backgroundColor: Color(0xffFEF7FF), // App bar color
      ),
    );
  }
}
 */