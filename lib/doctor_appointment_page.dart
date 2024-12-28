import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/doctor_details_page.dart';
import 'package:flutter/material.dart';

class DoctorAppointmentPage extends StatefulWidget {
  @override
  _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final doctorsSnapshot = await _firestore.collection('doctors').get();
    setState(() {
      doctors = doctorsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Appointments"),
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(doctor['name']),
            subtitle: Text("Specialization: ${doctor['specialization']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailsPage(
                    doctorId: doctor['id'],
                  ),
                ),
              );
              // Navigate to Doctor Details or Booking Page
            },
          );
        },
      ),
    );
  }
}
