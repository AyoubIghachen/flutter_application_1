import 'package:flutter/material.dart';
import 'package:flutter_application_1/helpers/DBHelper.dart';
import 'package:flutter_application_1/models/User.dart';
import 'package:flutter_application_1/pages/PageSuperviseur.dart';
import 'package:flutter_application_1/pages/PageAgent.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0), // Add space between the fields
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0), // Add space between the fields
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      User? user = await DBHelper.instance.authenticate(
                        _usernameController.text,
                        _passwordController.text,
                      );
                      if (user != null) {
                        if (user.role == 'supervisor') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PageSuperviseur(),
                            ),
                          );
                        } else if (user.role == 'agent') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgentPage(),
                            ),
                          );
                        }
                      } else {
                        // Show an error message
                      }
                    }
                  },
                  child: Text('Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
