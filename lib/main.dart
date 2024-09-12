import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MerchantApp());
}
class MyHomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  MyHomePage({super.key});

  void _signIn() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      // Handle successful sign-in
      print('Signed in as ${user.displayName}');
    }
  }

  void _signOut() async {
    await _authService.signOut();
    // Handle sign-out
    print('Signed out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In with Google'),
            ),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
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

  @override
  void initState() {
    super.initState();

    // Listener to update the final bill when total bill changes
    _billController.addListener(() {
      setState(() {
        _totalBill = double.tryParse(_billController.text) ?? 0.0;
        _finalBill = _totalBill; // Set the initial final amount to the total bill
      });
    });
  }

  void _onQRCodeScanned(Barcode barcode) {
    setState(() {
      _scannedData = barcode.rawValue ?? '';

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
      print('Error saving to Firebase: $e');
    }
  }

  @override
  void dispose() {
    _billController.dispose();
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
                    builder: (context) => QRScannerScreen(
                      onQRCodeScanned: _onQRCodeScanned,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
  final Function(Barcode) onQRCodeScanned;

  const QRScannerScreen({super.key, required this.onQRCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: MobileScanner(
          controller: MobileScannerController(),
          onDetect: (barcode, _) {
            final String code = barcode.rawValue ?? '';
            if (code.isNotEmpty) {
              onQRCodeScanned(barcode);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
