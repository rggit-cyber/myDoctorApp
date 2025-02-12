import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_details_page.dart';

class DoctorAppointmentPage extends StatefulWidget {
  @override
  _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctorsSnapshot = await _firestore.collection('doctors').get();
      setState(() {
        doctors = doctorsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Appointments"),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader while fetching data
          : doctors.isEmpty
              ? Center(child: Text("No doctors available"))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: doctor['imageUrl'] != null
                              ? NetworkImage(doctor['imageUrl'])
                              : AssetImage('assets/default_doctor.png')
                                  as ImageProvider,
                        ),
                        title: Text(
                          doctor['name'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("Specialization: ${doctor['specialization']}"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorDetailsPage(
                                doctorId: doctor['id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:doctor_app/doctor_details_page.dart';
// import 'package:flutter/material.dart';

// class DoctorAppointmentPage extends StatefulWidget {
//   @override
//   _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
// }

// class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> doctors = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctors();
//   }

//   Future<void> _fetchDoctors() async {
//     final doctorsSnapshot = await _firestore.collection('doctors').get();
//     setState(() {
//       doctors = doctorsSnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Doctor Appointments"),
//       ),
//       body: ListView.builder(
//         itemCount: doctors.length,
//         itemBuilder: (context, index) {
//           final doctor = doctors[index];
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(doctor['name']),
//             subtitle: Text("Specialization: ${doctor['specialization']}"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DoctorDetailsPage(
//                     doctorId: doctor['id'],
//                   ),
//                 ),
//               );
//               // Navigate to Doctor Details or Booking Page
//             },
//           );
//         },
//       ),
//     );
//   }
// }
