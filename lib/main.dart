import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kanver/services/auth_service.dart';
import 'package:kanver/src/create-requestV1/createRequestV1.dart';
import 'package:kanver/src/home/home.dart';
import 'package:kanver/src/login/login.dart';
import 'package:kanver/src/register/register.dart';
import 'package:kanver/src/request-details/requestDetails.dart';
import 'package:inspector/inspector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kanver/src/myRequests/myRequests.dart';
import 'package:kanver/src/widgets/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
      initialRoute: '/splash', // Set the splash screen as the initial route
      routes: {
        '/': (context) => MyApp(),
        '/splash': (context) => SplashScreen(), // Splash screen route
        '/login': (context) => Login(),
        '/request-details': (context) => RequestDetails(
              bloodType: 'A+',
              donorAmount: "2",
              patientAge: 30,
              hospitalName: 'City Hospital',
              additionalInfo: 'Urgent',
              hospitalLocation:
                  LatLng(40.712776, -74.005974), // Example coordinates
              type: 'bloodRequest',
            ),
        '/create-requestV1': (context) => CreateRequestV1(),
        '/register': (context) => Register(),
        '/home': (context) => Home(),
        '/my-requests': (context) => MyRequests(),
      },
      builder: (context, child) =>
          Inspector(child: child!), // Wrap [child] with [Inspector]
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      /* if (user == null) {
        Navigator.pushNamed(context, '/login');
      } else {
        if (ModalRoute.of(context)?.settings.name == '/') {
          Navigator.pushNamed(context, '/home');
        }
        print('User is signed in!');
      }  */
    });
    /* return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ); */

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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Auth().signOut();
              },
              child: Text("Sign Out"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text("Ana sayfa"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/my-requests');
              },
              child: Text("İsteklerim"),
            ),
          ],
        ),
      ),
    );
  }
}
