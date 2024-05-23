import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProductsPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const UpdateProductsPage({required this.productData});

  @override
  _UpdateProductsPageState createState() => _UpdateProductsPageState();
}

class _UpdateProductsPageState extends State<UpdateProductsPage> {
  late TextEditingController _nameController;
  late TextEditingController _SKUController;
  late TextEditingController _CountryController;
  late TextEditingController _CompanyController;
  late List<String> _cuisines;
  List<String> _categories = [
    'Baked Goods',
    'Snacks',
    'Frozen Products',
    'Dairy',
    'Cakes',
    'Organic',
    'Poultry',
  ];

  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with existing data
    _nameController = TextEditingController(text: widget.productData['name']);
    _SKUController = TextEditingController(text: widget.productData['SKU']);
    _CompanyController =
        TextEditingController(text: widget.productData['company']);
    _CountryController =
        TextEditingController(text: widget.productData['country']);
    _cuisines = List<String>.from(widget.productData['cuisines']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _SKUController.dispose();
    _CompanyController.dispose();
    _CountryController.dispose();
    super.dispose();
  }

  Future<void> updateProduct(BuildContext context) async {
    try {
      String? documentId = widget.productData['documentId'] as String?;
      if (documentId != null) {
        String? imageUrl =
            await uploadFileToStorage(documentId, _selectedImage, 'image');

        await FirebaseFirestore.instance
            .collection('products')
            .doc(documentId)
            .update({
          'name': _nameController.text,
          'SKU': _SKUController.text,
          'country': _CountryController.text,
          'company': _CompanyController.text,
          'cuisines': _cuisines,
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
                'An error occurred while updating the product.\nError: $e'),
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

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Update Product'),
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
                  controller: _SKUController,
                  decoration: InputDecoration(
                    labelText: 'SKU',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _CompanyController,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _CountryController,
                  decoration: InputDecoration(
                    labelText: 'Country of Product',
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
                  children: _cuisines.map((cuisine) {
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
                          _pickImage(ImageSource.gallery, isLogo: false),
                      child: Text('Update Product Image'),
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
                Center(
                  child: ElevatedButton(
                    onPressed: () => updateProduct(context),
                    child: Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
