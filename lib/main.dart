import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merchant QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MerchantHomePage(),
    );
  }
}

class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({super.key});

  @override
  _MerchantHomePageState createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage> {
  double _totalBill = 0.0;
  double _finalBill = 0.0;
  String _scannedData = '';

  final TextEditingController _billController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController _qrViewController;
  late Barcode result;

  @override
  void initState() {
    super.initState();

    // Listener to update the final bill when total bill changes
    _billController.addListener(() {
      setState(() {
        _totalBill = double.tryParse(_billController.text) ?? 0.0;
        _finalBill =
            _totalBill; // Set the initial final amount to the total bill
      });
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        _scannedData = result.code!;

        // Parse the scanned QR code data to extract the coupon amount
        final parsedData = _scannedData.split('|');
        final amountString = parsedData
            .firstWhere((element) => element.startsWith('Amount:'))
            .split(':')[1];
        final discountAmount = double.tryParse(amountString) ?? 0.0;

        // Apply the discount to the total bill
        _finalBill = _totalBill - discountAmount;

        // Save the scanned data to Firebase
        _saveToFirebase(_scannedData, _finalBill);
      });
    });
  }

  // Save the scanned data and final bill to Firebase Firestore
  Future<void> _saveToFirebase(String scannedData, double finalBill) async {
    CollectionReference coupons =
        FirebaseFirestore.instance.collection('scannedCoupons');

    try {
      await coupons.add({
        'scannedData': scannedData,
        'finalBill': finalBill,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to Firebase: $e');
      }
    }
  }

  @override
  void dispose() {
    _qrViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant QR Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _billController,
              decoration: const InputDecoration(
                labelText: 'Enter total bill amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trigger QR scanning when this button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QRScannerScreen(onQRViewCreated: _onQRViewCreated),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Use Coupon'),
            ),
            const SizedBox(height: 20),
            Text(
              _scannedData.isNotEmpty
                  ? 'Scanned QR Code Data: $_scannedData'
                  : '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Bill Amount: $_finalBill',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  final Function(QRViewController) onQRViewCreated;

  const QRScannerScreen({super.key, required this.onQRViewCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: QRView(
          key: GlobalKey(debugLabel: 'QR'),
          onQRViewCreated: onQRViewCreated,
        ),
      ),
    );
  }
}
