import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Import the service

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Sonuç"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Kapat"),
        ),
      ],
    ),
  );
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Declare TextEditingControllers for inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService =
      AuthService(); // Create an instance of AuthService
  final Auth _auth = Auth(); // Instance of your Auth class

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges, // Listen to auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/home');
            });
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildLoginForm(context);
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "E-posta Adresiniz:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Container(
                  height: 46,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "E-posta adresinizi girin...",
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
                        return "E-posta adresi gerekli!";
                      }
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return "Geçerli bir e-posta adresi girin!";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 18),
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
                    obscureText: true,
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
                SizedBox(height: 18),
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
                SizedBox(height: 18),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text;
                        final password = _passwordController.text;

                        try {
                          // Sign in the user
                          final user = await Auth().signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // Handle success
                          print("User signed in: $email");

                          // Navigate to the next screen
                          Navigator.pushNamed(context,
                              '/home'); // Replace with your desired route
                        } catch (e) {
                          // Handle errors 
                          _showErrorDialog(context, e.toString());
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff6B548D),
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
