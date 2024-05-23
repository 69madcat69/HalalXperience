import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddCompanyPage extends StatefulWidget {
  @override
  _AddCompanyPageState createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _registrationNumberController = TextEditingController();
  String? _certificationValidity;
  String? _halalStandards;

  File? _selectedLogo;
  UserCredential? _userCredential;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedLogo = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFB606), // Set the background color here

          title: const Text('Add Company'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'HCO Name',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Email',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    // Set label text color to white
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _certificationValidity,
                  onChanged: (newValue) {
                    setState(() {
                      _certificationValidity = newValue;
                    });
                  },
                  items: <String>['1 year', '3 years']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Certification Validity',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _registrationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _halalStandards,
                  onChanged: (String? newValue) {
                    setState(() {
                      _halalStandards = newValue;
                    });
                  },
                  items: <String>['Local', 'International']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Halal Standards',
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickLogo,
                      child: const Text('Upload Logo'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFFFFB606)),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    if (_selectedLogo != null)
                      Image.file(
                        _selectedLogo!,
                        width: 80.0,
                        height: 80.0,
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Register the user with Firebase Authentication
                    await registerHCO();

                    String name = _nameController.text;
                    String email = _emailController.text;
                    String phone = _phoneController.text;
                    String country = _countryController.text;
                    String registrationNumber =
                        _registrationNumberController.text;

                    // Upload the logo to Firestore Storage
                    String? logoUrl =
                        await uploadLogoToStorage(name, _selectedLogo);

                    // Add the company to Firestore
                    addCompanyToFirestore(
                      _userCredential!.user!.uid,
                      name,
                      email,
                      phone,
                      country,
                      registrationNumber,
                      _certificationValidity ?? '',
                      _halalStandards ?? '',
                      logoUrl ?? '',
                    );

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Success'),
                        content: const Text('Company added successfully'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                              Navigator.pop(
                                  context); // Go back to the previous page
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Add Company'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFFFB606)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> registerHCO() async {
    try {
      _userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print(
          'User registered successfully! User ID: ${_userCredential!.user!.uid}');
      // Navigate to registration success page or perform any other action
    } catch (e) {
      print('Failed to register user. Error: $e');
    }
  }

  Future<String?> uploadLogoToStorage(String uid, File? logoFile) async {
    if (logoFile == null) return null;

    try {
// Upload the logo file to Firestore Storage
      String fileName = 'company_logo_$uid';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef
          .putFile(logoFile); // Get the download URL of the uploaded logo
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading logo: $e');
      return null;
    }
  }

  void addCompanyToFirestore(
    String userId,
    String name,
    String email,
    String phone,
    String country,
    String registrationNumber,
    String certificationValidity,
    String halalStandards,
    String? logoUrl,
  ) {
    // Add the company to Firestore
    CollectionReference companiesRef =
        FirebaseFirestore.instance.collection('HCO');

    companiesRef
        .doc(userId) // Use the user ID as the document ID in Firestore
        .set({
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'registrationNumber': registrationNumber,
      'certificationValidity': certificationValidity,
      'halalStandards': halalStandards,
      'logoUrl': logoUrl ?? '',
    }).then((value) {
      print('Company added successfully');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Company added successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous page
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      print('Failed to add company: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to add company'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
