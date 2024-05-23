import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../maps.dart';

class Restaurant extends StatefulWidget {
  final String restaurantId;

  Restaurant({required this.restaurantId});

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<Restaurant> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _restaurantData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getRestaurantDetails();
  }

  Future<void> _getRestaurantDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _restaurantData = snapshot.data();
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error retrieving restaurant details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _restaurantData != null
              ? ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    ImageSection(
                        restaurantId: _restaurantData!['restaurantID']),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _restaurantData!['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _restaurantData!['phoneNumber'],
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ButtonSection(
                        restaurantData: _restaurantData,
                        restaurantId: widget.restaurantId),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _restaurantData!['description'],
                        textAlign: TextAlign.justify,
                        softWrap: true,
                      ),
                    ),
                  ],
                )
              : Center(child: Text('Restaurant not found.')),
    );
  }
}

class ImageSection extends StatelessWidget {
  final String restaurantId;

  ImageSection({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching images from Firestore'),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!.data();
          if (data != null) {
            final imageUrl = data['image'];
            final logoUrl = data['logo'];

            return CarouselSlider(
              items: [
                Image.network(
                  imageUrl,
                  width: 600,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Image.network(
                  logoUrl,
                  width: 600,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ],
              options: CarouselOptions(
                height: 240,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
            );
          } else {
            return Container(
              height: 240,
              child: Center(
                child: Text('No images found for this restaurant.'),
              ),
            );
          }
        } else {
          return Container(
            height: 240,
            child: Center(
              child: Text('Restaurant data not found.'),
            ),
          );
        }
      },
    );
  }
}

class ButtonSection extends StatelessWidget {
  @override
  Map<String, dynamic>? restaurantData;
  final String restaurantId;

  ButtonSection({required this.restaurantData, required this.restaurantId});

  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColorDark;
    print(restaurantData!['favorites']);
    final int favorites = restaurantData!['favorites'];
    print(favorites);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(context, color, Icons.call, 'CALL'),
        _buildButtonColumn(context, color, Icons.near_me, 'ROUTE'),
        Row(children: [
          FavoriteButton(
            product: FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantId),
            isFavorite: restaurantData!['favorite'] ?? false,
          ),
          Text(
            '${favorites}',
            style: TextStyle(fontSize: 16.0),
          ),
        ])
      ],
    );
  }

  Column _buildButtonColumn(
      BuildContext context, Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            if (label == 'CALL') {
              _callPhoneNumber(context, restaurantData!['phoneNumber']);
            } else if (label == 'ROUTE') {
              // Retrieve the restaurant location from Firebase
              GeoPoint location = await _getLocationFromFirebase(
                  restaurantData!['restaurantID']);
              // Open Google Maps with the specified latitude and longitude
              _openGoogleMaps(location.latitude, location.longitude);
            }
          },
          child: Icon(icon, color: color),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Future<GeoPoint> _getLocationFromFirebase(String restaurantId) async {
    // Retrieve the location from Firebase
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('restaurants')
        .doc(restaurantId)
        .get();

    if (snapshot.exists) {
      return snapshot.data()!['location'] as GeoPoint;
    } else {
      return GeoPoint(0, 0); // Default location (0, 0) if not found
    }
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    String url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _callPhoneNumber(BuildContext context, String phoneNumber) async {
    // Check if the phone number is valid
    if (phoneNumber.isNotEmpty) {
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Handle case where phone number is not available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Phone Number Not Available'),
            content:
                Text('The phone number for this restaurant is not available.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class FavoriteButton extends StatefulWidget {
  final DocumentReference product;
  final bool isFavorite;

  FavoriteButton({required this.product, required this.isFavorite});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  Future<void> toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite');

    if (isFavorite) {
      // Add product to favorites
      await favoritesCollection.doc(widget.product.id).set({'favorite': true});
      FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.product.id)
          .update({'favorites': FieldValue.increment(1)});
    } else {
      // Remove product from favorites
      await favoritesCollection.doc(widget.product.id).delete();
      FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.product.id)
          .update({'favorites': FieldValue.increment(-1)});
    }
  }

  Future<bool> checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite');

    final favoriteDoc = await favoritesCollection.doc(widget.product.id).get();
    return favoriteDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFavorite(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final bool isFavorite = snapshot.data ?? false;

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: toggleFavorite,
        );
      },
    );
  }
}
