import 'package:doctor_app/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailsPage extends StatelessWidget {
  final String doctorId;

  const DoctorDetailsPage({super.key, required this.doctorId});

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
            title: Text("Doctor Details"),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Profile Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(doctor['image_url'] ??
                                'https://via.placeholder.com/150'), // Fallback image
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['name'],
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  doctor['specialization'],
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Experience: ${doctor['experience_years']} years",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Availability Status
                  Center(
                    child: Chip(
                      label: Text(
                        isAvailable ? "Available" : "Unavailable",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isAvailable ? Colors.green : Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Available Slots
                  if (isAvailable) ...[
                    Text(
                      "Available Slots",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    if (availableSlots.isEmpty)
                      Center(
                        child: Text(
                          "No slots available",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: availableSlots.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                            child: ListTile(
                              // leading: Icon(Icons.access_time,
                              //     color: Colors.blueAccent),
                              title: Text(
                                availableSlots[index],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 18, color: Colors.grey),
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
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
