import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompaniesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company List'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('companies').snapshots(),
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
              child: Text('No companies found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var company = snapshot.data!.docs[index];
              final logoUrl = company.get('logoUrl');
              final name = company.get('name');
              final email = company.get('email');

              DocumentReference favoriteRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('favorite')
                  .doc(company.id);

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
                              CompanyDetailsPage(company: company),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: logoUrl != null && logoUrl.isNotEmpty
                          ? Image.network(
                              logoUrl,
                              width: 48.0,
                              height: 48.0,
                            )
                          : Container(
                              width: 48.0,
                              height: 48.0,
                              color: Colors.grey,
                            ),
                      title: Text(name ?? 'Unknown'),
                      subtitle: Text(email ?? 'Unknown'),
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

class CompanyDetailsPage extends StatelessWidget {
  final DocumentSnapshot company;

  CompanyDetailsPage({required this.company});

  @override
  Widget build(BuildContext context) {
    final logoUrl = company.get('logoUrl');
    final name = company.get('name');
    final email = company.get('email');
    final phone = company.get('phone');
    final country = company.get('country');
    final registrationNumber = company.get('registrationNumber');
    final certificationValidity = company.get('certificationValidity');
    final halalStandards = company.get('halalStandards');
    final int favorite = company.get('favorite');

    return Scaffold(
      appBar: AppBar(
        title: Text(name ?? 'Company Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (logoUrl != null && logoUrl.isNotEmpty)
              Image.network(
                logoUrl,
                width: 120.0,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16.0),
            Text('Name: ${name ?? 'Unknown'}'),
            Text('Email: ${email ?? 'Unknown'}'),
            Text('Phone: ${phone ?? 'Unknown'}'),
            Text('Country: ${country ?? 'Unknown'}'),
            Text('Registration Number: ${registrationNumber ?? 'Unknown'}'),
            Text(
                'Certification Validity: ${certificationValidity ?? 'Unknown'}'),
            Text('Halal Standards: ${halalStandards ?? 'Unknown'}'),
            Text('Favorite Count: ${favorite}'),
          ],
        ),
      ),
    );
  }
}
