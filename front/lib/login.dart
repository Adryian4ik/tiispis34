import 'package:flutter/material.dart';
import 'package:front/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart'; // Экран добавления и просмотра паролей

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context, String username, String password) async {
    final response = await http.post(
      Uri.parse('${host}/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String token = data['access_token'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(token: token),
        ),
      );
    } else {
      print('Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                login(context, usernameController.text, passwordController.text);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
