import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(25),
          child: ListView(children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Username',
              ),
            ),
            TextField(
              controller: usernameController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  var alert = const AlertDialog(
                    title: Text("Başlık"),
                    content: Text("İçerik"),
                  );
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => alert);
                },
                child: Text("Login")),
          ]),
        )));
  }
}
