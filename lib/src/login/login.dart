import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Import the service

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Declare the form key inside the State class
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Declare TextEditingControllers for inputs
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService =
      AuthService(); // Create an instance of AuthService
  final Auth _auth = Auth(); // Instance of your Auth class

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _tcController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges, // Listen to auth state changes
      builder: (context, snapshot) {
        // Check if the user is authenticated
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            // User is signed in, navigate to home page or desired screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/request-details'); // Adjust route as needed
            });
            return Center(child: CircularProgressIndicator());
          } else {
            // User is not signed in, show the Register page
            return _buildLoginForm(context);
          }
        }
        // Show a loading spinner while waiting for auth state
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
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

                // TC input field

                Container(
                  height: 46,
                  child: TextFormField(
                    controller: _tcController, // Attach the controller
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
                      return null;
                    },
                  ),
                ),

                // T.C. Input Field

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
                Container(
                  height: 46.0,
                  child: TextFormField(
                    controller: _passwordController, // Attach the controller
                    decoration: InputDecoration(
                      hintText: "Şifreniz...",
                      hintStyle: TextStyle(
                        color: Color(0xFF544C4C),
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        // Customize the hint text style
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final tc = _tcController.text;
                        final password = _passwordController.text;

                        // Call the login method from AuthService
                        final response = await _authService.login(tc, password);

                        if (response['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Giriş başarılı!")),
                          );
                          Navigator.pushNamed(context, '/request-details');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Hata: ${response['message']}")),
                          );
                        }
                      }
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
                      "Giriş Yap",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto'),
                    ),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hala hesabınız yok mu? ",
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
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Kayıt Ol",
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
    );
  }
}
