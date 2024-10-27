import 'package:flutter/material.dart';
import 'package:kanver/src/login/login.dart';

// void main(){
//   runApp(MaterialApp(
//     home: MyApp()
//   ));
// }

void main() {
  runApp(
    MaterialApp(
      title: 'KanVer',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => MyApp(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => Login()
      },
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
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text("Login")),
      ),
    );
  }
}
