import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateRestaurantPage extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  const UpdateRestaurantPage({required this.restaurantData});

  @override
  _UpdateRestaurantPageState createState() => _UpdateRestaurantPageState();
}

class _UpdateRestaurantPageState extends State<UpdateRestaurantPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _urlController;
  late List<String> _cuisines;
  List<String> _availableCuisines = [
    'Italian',
    'Mexican',
    'Chinese',
    'Indian',
    'Japanese',
    'Thai',
    'Greek',
    'French',
    'Spanish',
    'American',
  ];

  File? _selectedLogo;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with existing data
    _nameController =
        TextEditingController(text: widget.restaurantData['name']);
    _descriptionController =
        TextEditingController(text: widget.restaurantData['description']);
    _phoneNumberController =
        TextEditingController(text: widget.restaurantData['phoneNumber']);
    _urlController = TextEditingController(text: widget.restaurantData['url']);
    _cuisines = List<String>.from(widget.restaurantData['cuisines']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneNumberController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> updateRestaurant(BuildContext context) async {
    try {
      String? documentId = widget.restaurantData['documentId'] as String?;
      if (documentId != null) {
        String? logoUrl =
            await uploadFileToStorage(documentId, _selectedLogo, 'logo');
        String? imageUrl =
            await uploadFileToStorage(documentId, _selectedImage, 'image');

        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(documentId)
            .update({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'phoneNumber': _phoneNumberController.text,
          'url': _urlController.text,
          'cuisines': _cuisines,
          'logo': logoUrl,
          'image': imageUrl,
        });

        Navigator.pop(
            context); // Navigate back to the previous page after updating
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('The document ID is null.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while updating the restaurant.\nError: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isLogo = false}) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        if (isLogo) {
          _selectedLogo = File(pickedImage.path);
        } else {
          _selectedImage = File(pickedImage.path);
        }
      });
    }
  }

  Future<String?> uploadFileToStorage(
    String uid,
    File? file,
    String fileType,
  ) async {
    if (file == null) return null;

    try {
      // Upload the file to Firebase Storage
      String fileName = '${fileType}_$uid';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded file
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading $fileType: $e');
      return null;
    }
  }

  void _removeLogo() {
    setState(() {
      _selectedLogo = null;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Update Restaurant'),
          backgroundColor: Colors.yellow.shade700,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Website URL',
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Cuisine:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  children: _availableCuisines.map((cuisine) {
                    return FilterChip(
                      label: Text(cuisine),
                      selected: _cuisines.contains(cuisine),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _cuisines.add(cuisine);
                          } else {
                            _cuisines.remove(cuisine);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) {
                          setState(() {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                _cuisines.add(value.trim());
                              });
                            }
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Add Cuisine',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                if (_nameController.text.trim().isNotEmpty) {
                                  _cuisines.add(_nameController.text.trim());
                                  _nameController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _pickImage(ImageSource.gallery, isLogo: true),
                      child: Text('Update Logo'),
                    ),
                    SizedBox(width: 16.0),
                    if (_selectedLogo != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _selectedLogo!,
                            width: 80.0,
                            height: 80.0,
                          ),
                          IconButton(
                            onPressed: _removeLogo,
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _pickImage(ImageSource.gallery, isLogo: false),
                      child: Text('Update Restaurant Image'),
                    ),
                    SizedBox(width: 16.0),
                    if (_selectedImage != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _selectedImage!,
                            width: 80.0,
                            height: 80.0,
                          ),
                          IconButton(
                            onPressed: _removeImage,
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => updateRestaurant(context),
                  child: Text('Update Restaurant'),
                ),
              ],
            ),
          ),
        ));
  }
}
