// import "package:flutter/material.dart";
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Function to get the number of users from Firebase
// Future<int> getUsersCount() async {
//   QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection('users').get();
//   return snapshot.size;
// }

// // Function to get the number of admins from Firebase
// Future<int> getAdminsCount() async {
//   QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection('Admin').get();
//   return snapshot.size;
// }

// // Function to get the number of restaurants from Firebase
// Future<int> getRestaurantsCount() async {
//   QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection('restaurants').get();
//   return snapshot.size;
// }

// // Function to get the popular products accessed from Firebase
// Future<Map<String, int>> getPopularProducts() async {
//   QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection('products').get();

//   Map<String, int> productFrequency = {};

//   snapshot.docs.forEach((doc) {
//     String productName = doc['name']; // Assuming the name field contains the product name
//     if (productFrequency.containsKey(productName)) {
//       productFrequency[productName]++;
//     } else {
//       productFrequency[productName] = 1;
//     }
//   });

//   // Sort the productFrequency map by value in descending order
//   var sortedProducts = productFrequency.entries.toList()
//     ..sort((a, b) => b.value.compareTo(a.value));

//   // Return the sorted map
//   return Map.fromEntries(sortedProducts);
// }

// // Example usage of the above functions
// void generateReports() async {
//   int usersCount = await getUsersCount();
//   int adminsCount = await getAdminsCount();
//   int restaurantsCount = await getRestaurantsCount();
//   Map<String, int> popularProducts = await getPopularProducts();

//   print('Number of Users: $usersCount');
//   print('Number of Admins: $adminsCount');
//   print('Number of Restaurants: $restaurantsCount');
//   print('Popular Products:');
//   popularProducts.forEach((productName, frequency) {
//     print('$productName: $frequency');
//   });
// }

// // Call the function to generate the reports
// class GenerateReport extends StatelessWidget {
//   const GenerateReport({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: const Scaffold(
//         Text("Registered Users"),
//         ;
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int usersCount = 0;
  int adminsCount = 0;
  int restaurantsCount = 0;
  Map<String, int> popularProducts = {};

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    int users = await getUsersCount();
    int admins = await getAdminsCount();
    int restaurants = await getRestaurantsCount();
    Map<String, int> products = await getPopularProducts();

    setState(() {
      usersCount = users;
      adminsCount = admins;
      restaurantsCount = restaurants;
     popularProducts = products;
    });
  }

  Future<int> getUsersCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  Future<int> getAdminsCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Admin').get();
    return snapshot.size;
  }

  Future<int> getRestaurantsCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    return snapshot.size;
  }

  Future<Map<String, int>> getPopularProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    Map<String, int> productFrequency = {};

    snapshot.docs.forEach((doc) {
      String productName = doc['name'];
      if (productFrequency.containsKey(productName)) {
        int frequency = productFrequency[productName] ?? 0;
       // productFrequency[productName]++;
       productFrequency[productName] = frequency + 1;
      } else {
        productFrequency[productName] = 1;
      }
    });

    var sortedProducts = productFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'Number of Users: $usersCount',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Text(
            'Number of Admins: $adminsCount',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Text(
            'Number of Restaurants: $restaurantsCount',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Text(
            'Popular Products:',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: popularProducts.length,
            itemBuilder: (context, index) {
              String productName = popularProducts.keys.elementAt(index);
              int frequency = popularProducts.values.elementAt(index);

              return ListTile(
                title: Text(productName),
                trailing: Text('$frequency'),
              );
            },
          ),
        ],
      ),
    );
  }
}
