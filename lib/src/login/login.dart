import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Declare the form key inside the State class
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey, // Attach the form key for validation
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  "Giriş Yap",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: 18), // Space between the title and input fields

                // TC LABEL
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

                // TC input field
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "T.C. kimlik numaranız...",
                    hintStyle: TextStyle(
                      color: Color(0xFF544C4C),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w500, // Customize the hint text style
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
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
                    return null;
                  },
                ),
                SizedBox(height: 18), // Space between fields

                // password label
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

                // Password Input Field (Şifre)
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Şifreniz...",
                    hintStyle: TextStyle(
                      color: Color(0xFF544C4C),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w500, // Customize the hint text style
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 16.0,
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
                SizedBox(height: 18), // Space between fields and the button

                // Forgot Password Text
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      // Add your forgot password action here
                    },
                    child: Text(
                      "Şifrenizi mi unuttunuz?",
                      style: TextStyle(
                        color: Color(0xFF544C4C),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height: 18), // Space between forgot password and button

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // Add your login logic here
                    // Validate the form fields
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Giriş başarılı!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff6B548D), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
