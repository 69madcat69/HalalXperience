import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'updateRestaurant.dart';

class Restaurant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
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
              child: Text('No restaurants found.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> restaurantData =
                  document.data() as Map<String, dynamic>;
              restaurantData['documentId'] =
                  document.id; // Add this line to assign the documentId

              // Retrieve the cuisines list
              List<dynamic>? cuisines =
                  restaurantData['cuisines'] as List<dynamic>?;

              return ListTile(
                leading: restaurantData['logo'] != null &&
                        restaurantData['logo'].isNotEmpty
                    ? Image.network(
                        restaurantData['logo'],
                        width: 48.0,
                        height: 48.0,
                      )
                    : Container(
                        width: 48.0,
                        height: 48.0,
                        color: Colors.grey,
                      ),
                title: Text(restaurantData['name']),
                subtitle: Text(cuisines != null ? cuisines.join(", ") : ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Handle update functionality
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // TODO: Handle delete functionality
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RestaurantDetailsPage(restaurantData: restaurantData),
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
}

class RestaurantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurantData;

  const RestaurantDetailsPage({required this.restaurantData});
  Future<void> deleteRestaurant(BuildContext context) async {
    try {
      String? documentId = restaurantData['documentId'] as String?;
      if (documentId != null) {
        await FirebaseFirestore.instance
            .collection('restaurants')
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
                'An error occurred while deleting the restaurant.\nError: $e'),
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
          title: Text('Delete Restaurant'),
          content: Text('Are you sure you want to delete this restaurant?'),
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
      deleteRestaurant(context); // Delete the restaurant
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> carouselImages = [];

    if (restaurantData['logo'] != null && restaurantData['logo'].isNotEmpty) {
      carouselImages.add(restaurantData['logo']);
    }

    if (restaurantData['image'] != null && restaurantData['image'].isNotEmpty) {
      carouselImages.add(restaurantData['image']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantData['name']),
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
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              restaurantData['description'],
              style: TextStyle(fontSize: 16),
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
            if (restaurantData['cuisines'] != null &&
                restaurantData['cuisines'].isNotEmpty)
              Text(
                restaurantData['cuisines'].join(", "),
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateRestaurantPage(
                      restaurantData: restaurantData,
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
                showDeleteConfirmation(
                    context); // Show delete confirmation dialog
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
