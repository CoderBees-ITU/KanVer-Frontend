import 'package:flutter/material.dart';

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
