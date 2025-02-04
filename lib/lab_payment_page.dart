import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String labId;
  final String labName;
  final String testId;
  final String testName;
  final String slot;
  final double price;

  PaymentPage({
    required this.labId,
    required this.labName,
    required this.testId,
    required this.testName,
    required this.slot,
    required this.price,
  });

  Future<void> _confirmBooking(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('lab_test_bookings').add({
        'lab_id': labId,
        'lab_name': labName,
        'test_id': testId,
        'test_name': testName,
        'slot': slot,
        'price': price,
        'user_id': 'current_user_id', // Replace with actual user ID
        'status': 'pending',
        'booking_date': DateTime.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Booking confirmed!")));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to confirm booking: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Lab: $labName", style: TextStyle(fontSize: 18)),
            Text("Test: $testName", style: TextStyle(fontSize: 18)),
            Text("Slot: $slot", style: TextStyle(fontSize: 18)),
            Text("Price: ₹$price", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmBooking(context),
              child: Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
