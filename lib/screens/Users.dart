import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'updateProducts.dart';

class Users extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
              child: Text('No Users found.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> userData =
                  document.data() as Map<String, dynamic>;
              userData['documentId'] =
                  document.id; // Add this line to assign the documentId

              // Retrieve the cuisines list

              return ListTile(
                title: Text(userData['name']),
                subtitle: Text(userData['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailsPage(userData: userData),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete User'),
                              content: Text(
                                  'Are you sure you want to delete this user?'),
                              actions: [
                                ElevatedButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Delete'),
                                  onPressed: () async {
                                    // Delete the user from Firestore
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userData['documentId'])
                                        .delete();

                                    Navigator.of(context)
                                        .pop(); // Close the dialog

                                    // Show a snackbar to indicate successful deletion
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('User deleted'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildUserInformationItem('Name', userData['name']),
          _buildUserInformationItem('Email', userData['email']),
          _buildUserInformationItem('Nationality', userData['nationality']),
          _buildUserInformationItem('Date of Birth', userData['dateOfBirth']),
          _buildUserInformationItem(
              'Subscription Plan', userData['subscriptionPlan']),
          _buildUserInformationItem(
              'Payment Method', userData['paymentMethod']),
        ],
      ),
    );
  }

  Widget _buildUserInformationItem(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            flex: 3,
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }
}
