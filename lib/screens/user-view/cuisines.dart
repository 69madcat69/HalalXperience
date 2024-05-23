import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurants.dart';

class CuisinesPage extends StatefulWidget {
  @override
  _CuisinesPageState createState() => _CuisinesPageState();
}

class _CuisinesPageState extends State<CuisinesPage> {
  late Stream<QuerySnapshot> _cuisinesStream;
  final List<String> cuisines = [
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

  String selectedCuisine = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuisines'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cuisines.map((cuisine) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCuisine = cuisine;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      primary: selectedCuisine == cuisine
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                    child: Text(cuisine),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _buildRestaurantList(selectedCuisine),
          ),
        ],
      ),
    );
  }
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
          MaterialPageRoute(builder: (context) => Restaurant(restaurantId: id)),
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

Widget _buildRestaurantList(String selectedCuisine) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }

      final restaurants = snapshot.data!.docs;

      final filteredRestaurants = selectedCuisine.isNotEmpty
          ? restaurants.where((restaurant) {
              final cuisines = restaurant.get('cuisines') as List<dynamic>?;
              return cuisines?.cast<String>().contains(selectedCuisine) ??
                  false;
            }).toList()
          : restaurants;

      return ListView.builder(
        itemCount: filteredRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant =
              filteredRestaurants[index].data() as Map<String, dynamic>;
          return _buildRestaurantCard(
            logo: restaurant['logo'] ?? '',
            name: restaurant['name'] ?? '',
            url: restaurant['url'] ?? '',
            id: restaurant['id'] ?? '',
            cuisines:
                (restaurant['cuisines'] as List<dynamic>?)?.cast<String>() ??
                    [],
            context: context,
          );
        },
      );
    },
  );
}
