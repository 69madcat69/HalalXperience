import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalxperience/screens/maps.dart';
import 'addRestaurant.dart';
import 'addProduct.dart';
import 'HCO.dart';
import 'restaurant.dart';
import 'product.dart';
import 'login_user.dart';

class HCO_Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xffFFD700),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/registerProducts': (context) => addProductPage(),
        '/registerRestaurants': (context) => addRestaurantPage(),
        '/ViewProducts': (context) => ProductPage(),
        '/ViewRestaurants': (context) => Restaurant(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text(
          'HalalXperience',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildButton(context, 'Register Products', Icons.business,
                    '/registerProducts'),
                buildButton(context, 'Register Restaurants',
                    Icons.shopping_basket, '/registerRestaurants'),
                buildButton(
                    context, 'View Products', Icons.label, '/ViewProducts'),
                buildButton(context, 'View Restaurants', Icons.add_business,
                    '/ViewRestaurants'),
              ],
            ),
            const SizedBox(height: 8.0),
            Image.asset(
              'assets/logo.png',
              width: 250,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(
      BuildContext context, String label, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      width: 100.0, // Adjust the width here
      height: 100.0, // Adjust the height here
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          primary: Colors.yellow.shade700,
        ),
        onPressed: () {
          if (route == '/registerProducts') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => addProductPage()),
            );
          } else if (route == '/registerRestaurants') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => addRestaurantPage()),
            );
          } else if (route == '/ViewProducts') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductPage()),
            );
          } else if (route == '/ViewRestaurants') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Restaurant()),
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }
}
