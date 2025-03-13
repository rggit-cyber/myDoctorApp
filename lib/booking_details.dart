import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailsPage({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final booking = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Doctor ID: ${booking['doctor_id']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Slot: ${booking['slot']}"),
                SizedBox(height: 10),
                Text("Status: ${booking['status']}"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Additional actions if needed
                  },
                  child: Text("Contact Support"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
