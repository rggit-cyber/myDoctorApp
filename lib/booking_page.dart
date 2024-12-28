import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/payment_page.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  final String doctorId;
  final String slot;

  const BookingPage({required this.doctorId, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Booking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Doctor ID: $doctorId"),
            Text("Selected Slot: $slot"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save booking to Firestore
                _saveBooking(context);
              },
              child: Text("Proceed to Payment"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBooking(BuildContext context) async {
    await FirebaseFirestore.instance.collection('bookings').add({
      'doctor_id': doctorId,
      'slot': slot,
      'user_id': 1, // Replace with logged-in user's ID
      'status': 'pending',
      'booking_date': DateTime.now(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage()),
    );
  }
}
