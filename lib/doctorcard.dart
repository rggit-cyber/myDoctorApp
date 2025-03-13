// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:doctor_app/doctor_details_page.dart';
// import 'package:flutter/material.dart';

// class DoctorCard extends StatefulWidget {
//   @override
//   State<DoctorCard> createState() => _DoctorCardState();
// }

// class _DoctorCardState extends State<DoctorCard> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> doctors = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctors();
//   }

//   Future<void> _fetchDoctors() async {
//     try {
//       final doctorsSnapshot = await _firestore.collection('doctors').get();
//       setState(() {
//         doctors = doctorsSnapshot.docs.map((doc) {
//           final data = doc.data();
//           data['id'] = doc.id;
//           return data;
//         }).toList();
//       });
//     } catch (e) {
//       print("Error fetching doctors: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 300, // Adjust as needed
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: doctors.map((doctor) {
//             return Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               margin: const EdgeInsets.all(10),
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(75),
//                       child: Image.network(
//                         doctor['image_url'] ?? '',
//                         height: 100,
//                         width: 100,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Icon(Icons.person, size: 100, color: Colors.grey),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Divider(thickness: 1),
//                     const SizedBox(height: 10),
//                     Text(doctor['name'] ?? 'Unknown'),
//                     Text(" ${doctor['specialization'] ?? 'N/A'}"),
//                     const SizedBox(height: 5),
//                     Text(
//                         "Experience: ${doctor['experience_years'] ?? 'N/A'} years"),
//                     const SizedBox(height: 10),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DoctorDetailsPage(
//                               doctorId: doctor['id'],
//                             ),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         "Book Now",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
