import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user_page.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _dobController = TextEditingController();
  final _subscriptionController =
      TextEditingController(text: '7 days free trial');
  final _paymentMethodController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration App',
      home: Scaffold(
        body: Container(
          color: const Color(0xFFFFB606),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Image.asset(
                    'assets/logo.png', // Replace with your image asset path
                    height: 150.0,
                    width: 150.0,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sans Serif', // Replace with your desired font
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
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            filled: true,
                            fillColor: Colors.black,
                            labelStyle: TextStyle(
                              color:
                                  Colors.white, // Set label text color to white
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
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
                              color:
                                  Colors.white, // Set label text color to white
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
                              color:
                                  Colors.white, // Set label text color to white
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _nationalityController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your nationality';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Nationality',
                            filled: true,
                            fillColor: Colors.black,
                            labelStyle: TextStyle(
                              color:
                                  Colors.white, // Set label text color to white
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _dobController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your date of birth';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            filled: true,
                            fillColor: Colors.black,
                            labelStyle: TextStyle(
                              color:
                                  Colors.white, // Set label text color to white
                            ),
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller:
                              TextEditingController(text: '7 days free trial'),
                          enabled: false,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Subscription Plan',
                            filled: true,
                            fillColor: Colors.black,
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _paymentMethodController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your preferred payment method';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                            filled: true,
                            fillColor: Colors.black,
                            labelStyle: TextStyle(
                              color:
                                  Colors.white, // Set label text color to white
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              registerUser(context);
                            }
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void registerUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'nationality': _nationalityController.text,
        'dateOfBirth': _dobController.text,
        'subscriptionPlan': _subscriptionController.text,
        'paymentMethod': _paymentMethodController.text,
        'role': 'user',
      });

      print(
          'User registered successfully! User ID: ${userCredential.user!.uid}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => userDashboard()),
      );

      // Navigate to registration success page or perform any other action
    } catch (e) {
      print('Failed to register user. Error: $e');
    }
  }
}
