// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart'; // Import for formatting dates
// import 'booking_page.dart';

// class DoctorDetailsPage extends StatelessWidget {
//   final String doctorId;

//   const DoctorDetailsPage({super.key, required this.doctorId});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DocumentSnapshot>(
//       future:
//           FirebaseFirestore.instance.collection('doctors').doc(doctorId).get(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Scaffold(body: Center(child: CircularProgressIndicator()));
//         }

//         final doctor = snapshot.data!.data() as Map<String, dynamic>;
//         final List<dynamic> slots =
//             (doctor['availability']?['slots'] ?? []) as List<dynamic>;
//         final bool isAvailable = doctor['availability']?['status'] ?? false;

//         DateTime now = DateTime.now();

//         // Generate updated slots dynamically while keeping the time slots unchanged
//         List<Map<String, dynamic>> updatedSlots = [];

//         for (int i = 0; i < slots.length; i++) {
//           DateTime updatedDate =
//               now.add(Duration(days: i)); // Increment day dynamically

//           updatedSlots.add({
//             "date": DateFormat('dd MMMM yyyy')
//                 .format(updatedDate), // Format: 05 March 2025
//             "day": DateFormat('EEEE').format(updatedDate), // Format: Wednesday
//             "times": List<String>.from(
//                 slots[i]["times"] ?? []), // Keep times unchanged
//             "available":
//                 slots[i]["available"] ?? true, // Keep availability status
//           });
//         }

//         return Scaffold(
//           appBar: AppBar(
//             title: Text("Doctor Details"),
//             backgroundColor: Colors.white,
//             elevation: 0,
//           ),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Doctor Profile
//                   Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 40,
//                             backgroundImage: doctor['imageUrl'] != null &&
//                                     doctor['imageUrl'].isNotEmpty
//                                 ? NetworkImage(doctor['imageUrl'])
//                                 : AssetImage('images/default_doctor.png')
//                                     as ImageProvider,
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   doctor['name'],
//                                   style: TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   doctor['specialization'],
//                                   style: TextStyle(
//                                       fontSize: 16, color: Colors.grey[700]),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   "Experience: ${doctor['experience_years']} years",
//                                   style: TextStyle(
//                                       fontSize: 14, color: Colors.grey[600]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Availability Status
//                   Center(
//                     child: Chip(
//                       label: Text(
//                         isAvailable ? "Available" : "Unavailable",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       backgroundColor: isAvailable ? Colors.green : Colors.red,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Available Slots
//                   if (isAvailable) ...[
//                     Text("Available Slots",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 10),
//                     if (updatedSlots.isEmpty)
//                       Center(
//                         child: Text("No slots available",
//                             style: TextStyle(
//                                 fontSize: 16, color: Colors.grey[700])),
//                       )
//                     else
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: updatedSlots.map((slot) {
//                           String formattedDate = slot['date'];
//                           String day = slot['day'];
//                           List<dynamic> times = slot['times'];

//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 20),
//                               Text(
//                                 "$formattedDate, $day", // Example: 04 March 2025, Tuesday
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               SizedBox(height: 10),
//                               GridView.builder(
//                                 shrinkWrap: true,
//                                 physics: NeverScrollableScrollPhysics(),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 4, // 4 slots per row
//                                   crossAxisSpacing: 8,
//                                   mainAxisSpacing: 8,
//                                   childAspectRatio: 2.5, // Button shape
//                                 ),
//                                 itemCount: times.length,
//                                 itemBuilder: (context, index) {
//                                   return OutlinedButton(
//                                     onPressed: () {
//                                       // Ensure the date is formatted correctly as "YYYY-MM-DD"
//                                       String formattedDate =
//                                           DateFormat("yyyy-MM-dd")
//                                               .format(DateTime.now());

//                                       // Create the slot value in the correct format
//                                       String slotValue =
//                                           "$formattedDate ${times[index]}";

//                                       print(
//                                           "DEBUG: Slot Value -> $slotValue"); // Debug output

//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => BookingPage(
//                                             doctorId: doctorId,
//                                             slot:
//                                                 slotValue, // Now in "YYYY-MM-DD HH:MM" format ✅
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     style: OutlinedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       side: BorderSide(
//                                           color: Colors.grey.shade400),
//                                       padding: EdgeInsets.symmetric(
//                                           vertical: 10, horizontal: 5),
//                                     ),
//                                     child: Text(
//                                       times[index],
//                                       style: TextStyle(
//                                           fontSize: 14, color: Colors.black),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               SizedBox(height: 15),
//                             ],
//                           );
//                         }).toList(),
//                       ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'booking_page.dart';

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
        final List<dynamic> slots =
            (doctor['availability']?['slots'] ?? []) as List<dynamic>;
        final bool isAvailable = doctor['availability']?['status'] ?? false;

        DateTime now = DateTime.now();
        String todayDate = DateFormat('yyyy-MM-dd').format(now);

        // Filter to include today's date and future slots
        List futureSlots = slots.where((slot) {
          DateTime slotDate = DateTime.parse(slot['date']);
          return slotDate.isAfter(now) ||
              DateFormat('yyyy-MM-dd').format(slotDate) == todayDate;
        }).map((slot) {
          return {
            "date": DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(slot['date'])), // Correct date format
            "formattedDate": DateFormat('dd MMMM yyyy')
                .format(DateTime.parse(slot['date'])), // 08 March 2025
            "day": DateFormat('EEEE')
                .format(DateTime.parse(slot['date'])), // Saturday
            "times": List<String>.from(slot["times"] ?? []),
          };
        }).toList();

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
                  // Doctor Profile
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
                            backgroundImage: doctor['imageUrl'] != null &&
                                    doctor['imageUrl'].isNotEmpty
                                ? NetworkImage(doctor['imageUrl'])
                                : AssetImage('images/default_doctor.png')
                                    as ImageProvider,
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
                    Text("Available Slots",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    if (futureSlots.isEmpty)
                      Center(
                        child: Text("No slots available",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700])),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: futureSlots.map((slot) {
                          String formattedDate = slot['formattedDate'];
                          String day = slot['day'];
                          List<dynamic> times = slot['times'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text("$formattedDate, $day",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 2.5,
                                ),
                                itemCount: times.length,
                                itemBuilder: (context, index) {
                                  return OutlinedButton(
                                    onPressed: () {
                                      // Use the correct date for the booking
                                      String slotValue =
                                          "${slot['date']} ${times[index]}";

                                      print("DEBUG: Slot Value -> $slotValue");

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingPage(
                                            doctorId: doctorId,
                                            slot: slotValue,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                    ),
                                    child: Text(times[index],
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                  );
                                },
                              ),
                              SizedBox(height: 15),
                            ],
                          );
                        }).toList(),
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
