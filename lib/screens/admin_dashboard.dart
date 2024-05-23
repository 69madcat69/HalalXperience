import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalxperience/screens/reports.dart';
import 'addHCO.dart';
import 'addRestaurant.dart';
import 'addProduct.dart';
import 'HCO.dart';
import 'restaurant.dart';
import 'product.dart';
import 'login_user.dart';
import 'home_page.dart';
import 'register_admin.dart';
import 'Users.dart';

class adminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xffFFD700),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/companies': (context) => CompaniesPage(),
        '/products': (context) => ProductPage(),
        '/restaurant': (context) => Restaurant(),
        '/addCompany': (context) => AddCompanyPage(),
        '/addAdmin': (context) => RegisterAdmin(),
        '/reports': (context) => ReportsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade700,
          title: const Text('HalalXperience'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => startPage()),
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
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildButton(context, 'Companies', Icons.business, '/companies'),
                  buildButton(
                      context, 'Products', Icons.shopping_basket, '/products'),
                  buildButton(context, 'Restaurants', Icons.label, '/restaurant'),
                  buildButton(
                      context, 'Add Company', Icons.add_business, '/addCompany'),
                  buildButton(context, 'Add Admin', Icons.business, '/addAdmin'),
                  buildButton(context, 'View Report', Icons.report, '/reports'),
                ],
              ),
              const SizedBox(height: 16.0),
              Image.asset(
                'assets/logo.png',
                width: 400,
                height: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(
      BuildContext context, String label, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 70.0,
      height: 70.0,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          primary: Colors.yellow.shade700,
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
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
