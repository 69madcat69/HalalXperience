import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'user_page.dart';
import 'HCO_dashboard.dart';

enum UserType { user, admin, hco }

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: Scaffold(
        body: Container(
          color: const Color(0xFFFFB606),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 150.0,
                          width: 150.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sans Serif',
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  filled: true,
                                  fillColor: Colors.black,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  filled: true,
                                  fillColor: Colors.black,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    loginUser(context);
                                  }
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print("object");

      // Check user type in three different databases
      UserType userType = await checkUserType(userCredential.user!.uid);
      print("object");
      print(_emailController.text + " " + _passwordController.text);

      // Forward to the appropriate dashboard based on user type
      switch (userType) {
        case UserType.admin:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => adminPage(),
            ),
            (route) => false, // Remove all previous routes
          );
          break;
        case UserType.user:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => userDashboard(),
            ),
            (route) => false, // Remove all previous routes
          );
          break;
        case UserType.admin:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => adminPage(),
            ),
            (route) => false, // Remove all previous routes
          );
          break;
        case UserType.hco:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HCO_Dashboard(),
            ),
            (route) => false, // Remove all previous routes
          );
          break;
        default:
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Failed'),
                content: Text('Account does not exist in the database!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
      }
    } catch (e) {
      print('Failed to log in. Error: $e');
    }
  }

  Future<UserType> checkUserType(String uid) async {
// Check if the user exists in the 'users' collection
    print(uid);

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    DocumentSnapshot adminDoc =
        await FirebaseFirestore.instance.collection('Admin').doc(uid).get();
    DocumentSnapshot hcoDoc =
        await FirebaseFirestore.instance.collection('HCO').doc(uid).get();

    if (userDoc.exists) {
      print("user blah blah");
      return UserType.user;
    } else if (adminDoc.exists) {
      // Check if the user exists in the 'admin' collection
      print("admin blah blah");
      return UserType.admin;
    } else if (hcoDoc.exists) {
      // Check if the user exists in the 'HCO' collection
      print("hco blah blah");
      return UserType.hco;
    } else {
      print(hcoDoc.exists);
      print("nothing found");
    }
// Default to no user type if not found in any database
    return UserType.user; // Return a default user type
  }
}
