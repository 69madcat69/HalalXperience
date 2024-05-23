import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class addProductPage extends StatefulWidget {
  @override
  _addProductPageState createState() => _addProductPageState();
}

class _addProductPageState extends State<addProductPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _SKUController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _CompanyController = TextEditingController();
  TextEditingController _CountryController = TextEditingController();
  List<String> _selectedCuisines = [];

  File? _selectedImage;

  List<String> _categories = [
    'Baked Goods',
    'Snacks',
    'Frozen Products',
    'Dairy',
    'Cakes',
    'Organic',
    'Poultry',
  ];

  Future<void> _pickImage(ImageSource source, {bool isLogo = false}) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _selectCategory(String category) {
    setState(() {
      if (_selectedCuisines.contains(category)) {
        _selectedCuisines.remove(category);
      } else {
        if (_selectedCuisines.length < 3) {
          _selectedCuisines.add(category);
        }
      }
    });
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCuisines.contains(category);

    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (_) => _selectCategory(category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _SKUController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _CompanyController,
                decoration: const InputDecoration(
                  labelText: 'Product Company',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _CountryController,
                decoration: const InputDecoration(
                  labelText: 'Coutry of Production',
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                children: _categories.map((category) {
                  return _buildCategoryChip(category);
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text('Upload Product Image'),
                  ),
                  const SizedBox(width: 16.0),
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      width: 80.0,
                      height: 80.0,
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  try {
                    String name = _nameController.text;
                    String SKU = _SKUController.text;
                    String phoneNumber = _phoneNumberController.text;
                    String company = _CompanyController.text;
                    String country = _CountryController.text;

                    String? imageUrl = await uploadFileToStorage(
                        name, _selectedImage, 'image');

                    addProductToFirestore(
                      name,
                      SKU,
                      country,
                      company,
                      imageUrl,
                    );

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Success'),
                        content: const Text('Product added successfully'),
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
                  } catch (e) {
                    print('Error adding product: $e');
                  }
                },
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> uploadFileToStorage(
      String uid, File? file, String fileType) async {
    if (file == null) return null;

    try {
      // Upload the file to Firestore Storage
      String fileName = '${fileType}_$uid';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(file);

      // Get the download URL of the uploaded file
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading $fileType: $e');
      return null;
    }
  }

  void addProductToFirestore(
    String name,
    String SKU,
    String Company,
    String Country,
    String? imageUrl,
  ) async {
// Add the Product to Firestore
    CollectionReference productsRef =
        FirebaseFirestore.instance.collection('products');

    DocumentReference newDocRef = productsRef.doc();

    String productID = newDocRef.id;

    await newDocRef.set({
      'productID': productID,
      'name': name,
      'country': Country,
      'company': Company,
      'SKU': SKU,
      'image': imageUrl,
      'cuisines': _selectedCuisines,
      'favorites': 0,
    });
  }
}
