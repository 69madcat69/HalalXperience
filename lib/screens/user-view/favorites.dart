import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'products.dart';
import 'restaurants.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('favorite')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No favorites found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var favorite = snapshot.data!.docs[index];
              final productId = favorite.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                  if (productSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${productSnapshot.error}'),
                    );
                  }

                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (productSnapshot.hasData && productSnapshot.data!.exists) {
                    var product = productSnapshot.data!;
                    final image = product.get('image');
                    final name = product.get('name');
                    final SKU = product.get('SKU');

                    return ListTile(
                      leading: image != null && image.isNotEmpty
                          ? Image.network(
                              image,
                              width: 48.0,
                              height: 48.0,
                            )
                          : Container(
                              width: 48.0,
                              height: 48.0,
                              color: Colors.grey,
                            ),
                      title: Text(name ?? 'Unknown'),
                      subtitle: Text(SKU ?? 'Unknown'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                productDetailsPage(product: product),
                          ),
                        );
                      },
                    );
                  } else {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(productId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> restaurantSnapshot) {
                        if (restaurantSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${restaurantSnapshot.error}'),
                          );
                        }

                        if (restaurantSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (restaurantSnapshot.hasData &&
                            restaurantSnapshot.data!.exists) {
                          var restaurant = restaurantSnapshot.data!;
                          final image = restaurant.get('logo');
                          final name = restaurant.get('name');
                          final id = restaurant.get('restaurantID');
                          final phoneNumber = restaurant.get('phoneNumber');

                          return ListTile(
                            leading: image != null && image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: 48.0,
                                    height: 48.0,
                                  )
                                : Container(
                                    width: 48.0,
                                    height: 48.0,
                                    color: Colors.grey,
                                  ),
                            title: Text(name ?? 'Unknown'),
                            subtitle: Text(phoneNumber ?? 'Unknown'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Restaurant(
                                    restaurantId: id,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
// If the document ID doesn't exist in either table, display an empty SizedBox.
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
