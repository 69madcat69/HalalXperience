import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'updateProducts.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No products found.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> productData =
                  document.data() as Map<String, dynamic>;
              productData['documentId'] =
                  document.id; // Add this line to assign the documentId

              // Retrieve the cuisines list
              List<dynamic>? cuisines =
                  productData['cuisines'] as List<dynamic>?;

              return ListTile(
                leading: productData['image'] != null &&
                        productData['image'].isNotEmpty
                    ? Image.network(
                        productData['image'],
                        width: 48.0,
                        height: 48.0,
                      )
                    : Container(
                        width: 48.0,
                        height: 48.0,
                        color: Colors.grey,
                      ),
                title: Text(productData['name']),
                subtitle: Text(cuisines != null ? cuisines.join(", ") : ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProductsPage(
                              productData: productData,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmation(context, productData);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsPage(ProductData: productData),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> productData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(context, productData['documentId']);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(BuildContext context, String? documentId) async {
    try {
      if (documentId != null) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(documentId)
            .delete();
        Navigator.pop(
            context); // Navigate back to the previous page after deletion
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
                'An error occurred while deleting the product.\nError: $e'),
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
}

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> ProductData;

  const ProductDetailsPage({required this.ProductData});
  Future<void> deleteProduct(BuildContext context) async {
    try {
      String? documentId = ProductData['documentId'] as String?;
      if (documentId != null) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(documentId)
            .delete();
        Navigator.pop(
            context); // Navigate back to the previous page after deletion
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
                'An error occurred while deleting the product.\nError: $e'),
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

  Future<void> showDeleteConfirmation(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, false); // Return false to indicate cancellation
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, true); // Return true to indicate confirmation
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      deleteProduct(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> carouselImages = [];

    if (ProductData['image'] != null && ProductData['image'].isNotEmpty) {
      carouselImages.add(ProductData['image']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ProductData['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (carouselImages.isNotEmpty)
              CarouselSlider(
                items: carouselImages
                    .map((image) => Image.network(
                          image,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
                options: CarouselOptions(
                  height: 200.0,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              'SKU:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              ProductData['SKU'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Category:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            if (ProductData['cuisines'] != null &&
                ProductData['cuisines'].isNotEmpty)
              Text(
                ProductData['cuisines'].join(", "),
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProductsPage(
                      productData: ProductData,
                    ),
                  ),
                );
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showDeleteConfirmation(context);
              },
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(primary: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
