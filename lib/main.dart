import 'package:firestore_rpi_control/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LedControlPage(),
    );
  }
}

class LedControlPage extends StatefulWidget {
  const LedControlPage({super.key});

  @override
  State<LedControlPage> createState() => _LedControlPageState();
}

class _LedControlPageState extends State<LedControlPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'inputDevices';

  Future<void> _updateLedStatus(String ledId, bool newStatus) async {
    try {
      await _firestore.collection(collectionName).doc(ledId).update({
        'status': newStatus,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating LED status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LED Control Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLedToggle('Led_1', 'LED 1'),
            const SizedBox(height: 20),
            _buildLedToggle('Led_2', 'LED 2'),
            const SizedBox(height: 20),
            _buildLedToggle('Led_3', 'LED 3'),
          ],
        ),
      ),
    );
  }

  Widget _buildLedToggle(String ledId, String label) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection(collectionName).doc(ledId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        bool status = snapshot.data?['status'] ?? false;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 18),
                ),
                Switch(
                  value: status,
                  onChanged: (value) => _updateLedStatus(ledId, value),
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
