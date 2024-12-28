import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/booking_details.dart';
import 'package:flutter/material.dart';

class BookingList extends StatelessWidget {
  final String userId;
  final String status; // "upcoming" or "past"

  const BookingList({required this.userId, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status bookings found."));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final booking = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text("Doctor: ${booking['doctor_id']}"),
              subtitle: Text("Slot: ${booking['slot']}"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsPage(bookingId: doc.id),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
