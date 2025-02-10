import 'package:doctor_app/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailsPage extends StatelessWidget {
  final String doctorId;

  const DoctorDetailsPage({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('doctors').doc(doctorId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final doctor = snapshot.data!.data() as Map<String, dynamic>;
        final availableSlots = doctor['availability']['slots'] ?? [];
        final bool isAvailable = doctor['availability']['status'] ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(doctor['name']),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Specialization: ${doctor['specialization']}"),
                SizedBox(height: 10),
                Text("Experience: ${doctor['experience_years']} years"),
                SizedBox(height: 20),
                if (!isAvailable)
                  Center(
                    child: Text(
                      "Doctor unavailable",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  )
                else ...[
                  Text("Available Slots",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Slot: ${availableSlots[index]}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingPage(
                                  doctorId: doctorId,
                                  slot: availableSlots[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
