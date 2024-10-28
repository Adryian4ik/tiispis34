import 'package:flutter/material.dart';
import 'package:front/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('${host}/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      print('Registered successfully!');
    } else {
      print('Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                register(usernameController.text, passwordController.text);
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
