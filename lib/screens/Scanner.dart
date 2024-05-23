import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as scanner;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String barcodeResult = '';
  PickedFile? pickedFile;
  Map<String, dynamic>? productInfo;

  Future<void> _scanBarcode() async {
    try {
      final result = await scanner.FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color for the scan button
        'Cancel', // Text for the cancel button
        true, // Show flash icon
        scanner.ScanMode.BARCODE, // Scan mode
      );
      if (!mounted) return;
      setState(() {
        barcodeResult = result;
        productInfo = null; // Reset the product information
      });

      // Get the product information from Firebase
      productInfo = await getProductInfo(barcodeResult);

      if (productInfo != null && productInfo!.isNotEmpty) {
        // Display the product information in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Product Information'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    productInfo!['image'],
                    alignment: Alignment.center,
                    width: 200,
                    height: 200,
                  ),
                  Text('Name: ${productInfo!['name']}'),
                  Text('SKU: ${productInfo!['SKU']}'),
                  Text('Company: ${productInfo!['company']}'),
                  Text('Country: ${productInfo!['country']}'),
                  const Text('Cuisines:'),
                  for (var cuisine in productInfo!['cuisines'])
                    Text(' • $cuisine'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        // No product found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Product Not Found'),
              content: const Text('Product not found in the database.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        barcodeResult = 'Error: $e';
      });
    }
  }

  Future<Map<String, dynamic>> getProductInfo(String barcode) async {
    // Get the product information from Firebase
    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('SKU', isEqualTo: barcode)
        .get();

    if (productSnapshot.size > 0) {
      // Return the product information
      return productSnapshot.docs[0].data();
    } else {
      // No product found
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
              ),
              child: const Text('Scan Barcode'),
            ),
            const SizedBox(height: 16),
            Text(
              'Barcode Result: $barcodeResult',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
