import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'prayer.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'maps.dart';
import 'user-view/products.dart';
import 'user-view/companies.dart';
import 'user-view/favorites.dart';
import 'user-view/restaurants.dart';
import 'user-view/cuisines.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Scanner.dart';

class userDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              drawer: _buildDrawer(context),
              appBar: AppBar(
                title: const Text('HalalXperience'),
                backgroundColor: Colors.yellow.shade700,
              ),
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CarouselSlider(
                          items: [
                            /*GestureDetector(
                              onTap: () => _navigateToPrayerTimesApp(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 2.0),
                                ),
                                child: Image.asset('assets/image.jpg'),
                              ),
                            ),*/
                            GestureDetector(
                              onTap: () => _navigateToPrayerTimesApp(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 2.0),
                                ),
                                child: Image.asset('assets/logo.png'),
                              ),
                            ),
                          ],
                          options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          buildButton(
                              'Prayer Timings', Icons.mosque_sharp, context),
                          buildButton('Favorites', Icons.favorite, context),
                          buildButton(
                              'Cuisines', Icons.emoji_food_beverage, context),
                          buildButton('Products', Icons.fastfood, context),
                          buildButton(
                              'Halal Organizations', Icons.business, context),
                          buildButton('Barcode Scanner',
                              Icons.qr_code_scanner_rounded, context),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SingleChildScrollView(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('restaurants')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final restaurants = snapshot.data!.docs;
                                    return Column(
                                      children: restaurants.map((doc) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        return _buildRestaurantCard(
                                          logo: data['logo'],
                                          name: data['name'],
                                          url: data['url'],
                                          id: data['restaurantID'],
                                          cuisines: List<String>.from(
                                              data['cuisines']),
                                          context: context,
                                        );
                                      }).toList(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
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
        },
      ),
    );
  }

  Widget buildButton(String label, IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          primary: Colors.yellow.shade700,
        ),
        onPressed: () {
          if (label == 'Prayer Timings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrayerTimesApp()),
            );
          } else if (label == 'Products') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductsPage()),
            );
          } else if (label == 'Favorites') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesPage()),
            );
          } else if (label == 'Cuisines') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CuisinesPage()),
            );
          } else if (label == 'Halal Organizations') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CompaniesPage()),
            );
          } else if (label == 'Barcode Scanner') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScannerPage()),
            );
          }
        },
        icon: Icon(icon),
        label: Text(
          label,
          style: TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Container(
              color: const Color(0xffFFD700),
            ),
          ),
          ListTile(
            leading: Icon(Icons.mosque_sharp),
            title: Text('Prayer Timings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrayerTimesApp()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.restaurant),
            title: Text('Restaurants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestaurantsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Favorites'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.food_bank),
            title: Text('Cuisines'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CuisinesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.fastfood),
            title: Text('Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: Text('Halal Organizations'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompaniesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.qr_code_scanner_rounded),
            title: Text('Barcode Scanner'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScannerPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              _performLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard({
    required String logo,
    required String name,
    required String url,
    required String id,
    required List<String> cuisines,
    required BuildContext context,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Restaurant(restaurantId: id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              logo,
              fit: BoxFit.contain,
              height: 150.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cuisines.map((cuisine) {
                      return Text(
                        cuisine,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPrayerTimesApp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrayerTimesApp()),
    );
  }

  void _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }
}
