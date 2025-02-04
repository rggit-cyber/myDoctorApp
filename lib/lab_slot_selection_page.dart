import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/payment_page.dart';
import 'package:flutter/material.dart';

class SlotSelectionPage extends StatelessWidget {
  final String labId;
  final String labName;
  final String testId;
  final String testName;
  final double price;

  SlotSelectionPage({
    required this.labId,
    required this.labName,
    required this.testId,
    required this.testName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Slot")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labs')
            .doc(labId)
            .collection('slots')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final slot = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Slot: ${slot['time']}"),
                subtitle:
                    Text(slot['availability'] ? "Available" : "Not Available"),
                onTap: () {
                  if (slot['availability']) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                            // labId: labId,
                            // labName: labName,
                            // testId: testId,
                            // testName: testName,
                            // slot: slot['time'],
                            // price: price,
                            ),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
