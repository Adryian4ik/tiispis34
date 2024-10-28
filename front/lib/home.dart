import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List passwords = [];
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;  // По умолчанию текст скрыт

  @override
  void initState() {
    super.initState();
    fetchPasswords();
  }

  Future<void> fetchPasswords() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/passwords/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      setState(() {
        passwords = jsonDecode(response.body);
      });
    } else {
      print('Failed to load passwords');
    }
  }

  Future<void> addPassword(String account, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/passwords/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(<String, String>{
        'account': account,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      fetchPasswords();
    } else {
      print('Failed to add password');
    }
  }

  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: passwords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(passwords[index]['account']),
                  subtitle: TextField(
                    controller: TextEditingController(text: passwords[index]['password']),
                    obscureText: obscureText,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: toggleObscureText,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: accountController,
                  decoration: InputDecoration(labelText: 'Account'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: toggleObscureText,
                    ),
                  ),
                  obscureText: obscureText,
                ),
                ElevatedButton(
                  onPressed: () {
                    addPassword(accountController.text, passwordController.text);
                    accountController.clear();
                    passwordController.clear();
                  },
                  child: Text('Add Password'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
