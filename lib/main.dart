import 'package:flutter/material.dart';
import 'package:kanver/src/create-requestV1/createRequestV1.dart';
import 'package:kanver/src/login/login.dart';
import 'package:kanver/src/register/register.dart';
import 'package:kanver/src/request-details/requestDetails.dart';
import 'package:inspector/inspector.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'KanVer',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFEF7FF),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF1D1B20),
            size: 18, // Change the back icon size
          ),
          titleTextStyle: TextStyle(
            fontSize: 22, // Başlık font boyutu
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyApp(),
        '/login': (context) => Login(),
        '/request-details': (context) => RequestDetails(),
        '/create-requestV1': (context) => CreateRequestV1(),
        '/register': (context) => Register(),
      },
        builder: (context, child) => Inspector(child: child!), // Wrap [child] with [Inspector]

    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KanVer'),
      ),
      body: Center(
        child: ListView(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text("Login"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/request-details');
              },
              child: Text("Request Details"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/create-requestV1');
              },
              child: Text("Create Request V1"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
