import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanver/services/auth_service.dart'; // Import for date formatting

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Declare the form key inside the State class
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // Declare TextEditingControllers for inputs
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedBloodType; // Variable to hold selected blood type

  // final AuthService _authService =
  //     AuthService(); // Create an instance of AuthService

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _tcController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to show DatePicker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of blood types
    final List<String> bloodTypes = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              // Prevent overflow when keyboard appears
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 40.0),
                child: Form(
                  key: _formKey, // Attach the form key for validation
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      const Text(
                        "Kayıt Ol",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      // TC Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Kimlik Numaranız:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // TC Input Field
                      Container(
                        height: 46,
                        child: TextFormField(
                          controller: _tcController,
                          decoration: InputDecoration(
                            hintText: "T.C. kimlik numaranız...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kimlik numarası gerekli!";
                            }
                            if (value.length != 11) {
                              return "Kimlik numarası 11 haneli olmalı!";
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return "Kimlik numarası sadece rakamlardan oluşmalıdır!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // First Name Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Adınız:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // First Name Input Field
                      Container(
                        height: 46,
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            hintText: "Adınız...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Ad gerekli!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Last Name Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Soyadınız:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // Last Name Input Field
                      Container(
                        height: 46,
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            hintText: "Soyadınız...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Soyad gerekli!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Email Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "E-posta:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // Email Input Field
                      Container(
                        height: 46,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "E-posta adresiniz...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "E-posta gerekli!";
                            }
                            // Simple email validation
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Geçerli bir e-posta giriniz!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Birthday Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Doğum Tarihiniz:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // Birthday Input Field
                      Container(
                        height: 46,
                        child: TextFormField(
                          controller: _birthdayController,
                          readOnly: true, // So the user can't edit directly
                          decoration: InputDecoration(
                            hintText: "Doğum tarihinizi seçin...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          onTap: () {
                            _selectDate(context);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Doğum tarihi gerekli!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Blood Type Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Kan Grubunuz:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // Blood Type Input Field
                      Container(
                        height: 46, // Adjust height for dropdown
                        child: DropdownButtonFormField<String>(
                          value: _selectedBloodType,
                          decoration: InputDecoration(
                            hintText: "Kan grubunuzu seçin...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 3,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          items: bloodTypes.map((bloodType) {
                            return DropdownMenuItem<String>(
                              value: bloodType,
                              child: Text(bloodType),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBloodType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kan grubu gerekli!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Password Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Şifre:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // Password Input Field
                      Container(
                        height: 46.0,
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: "Şifreniz...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          obscureText: true, // To hide password input
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre gerekli!";
                            }
                            if (value.length < 6) {
                              return "Şifre en az 6 karakter olmalı!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Confirm Password Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Şifre Tekrar:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      // Confirm Password Input Field
                      Container(
                        height: 46.0,
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: "Şifrenizi tekrar giriniz...",
                            hintStyle: TextStyle(
                              color: Color(0xFF544C4C),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 15.0,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 8,
                              height: 0.3,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre tekrar gerekli!";
                            }
                            if (value != _passwordController.text) {
                              return "Şifreler eşleşmiyor!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Register Button
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              final firstName = _firstNameController.text;
                              final lastName = _lastNameController.text;
                              final email = _emailController.text;
                              final birthday = _birthdayController.text;
                              final bloodType = _selectedBloodType;
                              final tc = _tcController.text;
                              final password = _passwordController.text;

                              final response = await validateUserDetails(
                                      tcNumber: tc,
                                      name: firstName,
                                      surname: lastName,
                                      birthDay: birthday.split("/").last +
                                          "-" +
                                          birthday.split("/")[1] +
                                          "-" +
                                          birthday.split("/").first)
                                  .then((value) => {
                                        if (value['result'] == true)
                                          {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Sonuç"),
                                                    content: Text(
                                                        "Doğrulama başarılı!"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("Kapat"),
                                                      ),
                                                    ],
                                                  );
                                                })
                                          }
                                        else
                                          {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Sonuç"),
                                                    content: Text(
                                                        "Kimlik bilgileriniz doğrulanamadı!"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("Kapat"),
                                                      ),
                                                    ],
                                                  );
                                                })
                                          }
                                      });

                              // showDialog(
                              //   context: context,
                              //   builder: (BuildContext context) {
                              //     return AlertDialog(
                              //       title: Text("Sonuç"),
                              //       content: Text(response.toString()),
                              //       actions: [
                              //         TextButton(
                              //           onPressed: () {
                              //             Navigator.pop(context);
                              //           },
                              //           child: Text("Kapat"),
                              //         ),
                              //       ],
                              //     );
                              //   },
                              // );

                              // // Call the register method from AuthService
                              // final response = await _authService.register(
                              //   firstName: firstName,
                              //   lastName: lastName,
                              //   email: email,
                              //   birthday: birthday,
                              //   bloodType: bloodType,
                              //   tc: tc,
                              //   password: password,
                              // );

                              // if (response['success']) {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(content: Text("Kayıt başarılı!")),
                              //   );
                              //   // Navigate to the next screen if needed
                              // } else {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(content: Text("Hata: ${response['message']}")),
                              //   );
                              // }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff6B548D), // Button color
                            fixedSize: Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 24.0),
                          ),
                          child: Text(
                            "Kayıt Ol",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto'),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Already have an account? Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Zaten bir hesabınız var mı?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // Navigate to login page
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              "Giriş Yap",
                              style: TextStyle(
                                color: Color(0xff6B548D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
