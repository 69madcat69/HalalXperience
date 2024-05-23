import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:halalxperience/screens/product.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Colors.yellow.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
        ],
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

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No products found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var product = snapshot.data!.docs[index];
              final image = product.get('image');
              final name = product.get('name');
              final SKU = product.get('SKU');

              DocumentReference favoriteRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('favorite')
                  .doc(product.id);

              return FutureBuilder<DocumentSnapshot>(
                future: favoriteRef.get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  bool isFavorite = snapshot.hasData && snapshot.data!.exists;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              productDetailsPage(product: product),
                        ),
                      );
                    },
                    child: ListTile(
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
                      trailing: FavoriteButton(
                        product: product,
                        isFavorite: isFavorite,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final DocumentSnapshot product;
  final bool isFavorite;

  FavoriteButton({required this.product, required this.isFavorite});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  int favoriteCount = 0;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    favoriteCount = widget.product.get('favorites') ?? 0;
    isFavorite = widget.isFavorite;
  }

  Future<void> toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
      favoriteCount += isFavorite ? 1 : -1;
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
          .collection('products')
          .doc(widget.product.id)
          .update({'favorites': FieldValue.increment(1)});
    } else {
      // Remove product from favorites
      await favoritesCollection.doc(widget.product.id).delete();
      FirebaseFirestore.instance
          .collection('products')
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

class productDetailsPage extends StatelessWidget {
  final DocumentSnapshot product;

  productDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product.get('image');
    final name = product.get('name');
    final SKU = product.get('SKU');
    final company = product.get('company');
    final country = product.get('country');
    final cuisines = product.get('cuisines');
    final int favorites = product.get('favorites');

    return Scaffold(
      appBar: AppBar(
        title: Text(name ?? 'Product Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (image != null && image.isNotEmpty)
                  Image.network(
                    image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${name ?? 'Unknown'}',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'SKU: ${SKU ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Company: ${company ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Country: ${country ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Cuisines: ${cuisines ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    FavoriteButton(
                      product: product,
                      isFavorite: favorites != null && favorites > 0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${favorites}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return _buildSearchResults(context, query.toLowerCase());
  }

  Widget _buildSearchResults(BuildContext context, String query) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .snapshots(),
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

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No Products found.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var restaurant = snapshot.data!.docs[index];
            final RImage = restaurant.get('image');
            final name = restaurant.get('name');
            final SKU = restaurant.get('SKU');
            final Pid = restaurant.get('productID');
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(ProductData: Pid),
                  ),
                );
              },
              child: ListTile(
                leading: RImage != null && RImage.isNotEmpty
                    ? Image.network(
                        RImage,
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
              ),
            );
          },
        );
      },
    );
  }
}
