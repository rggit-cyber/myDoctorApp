import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalAdmissionPage extends StatefulWidget {
  @override
  _HospitalAdmissionPageState createState() => _HospitalAdmissionPageState();
}

class _HospitalAdmissionPageState extends State<HospitalAdmissionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> hospitals = [];

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    final hospitalsSnapshot = await _firestore.collection('hospitals').get();
    setState(() {
      hospitals = hospitalsSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospital Admissions"),
      ),
      body: ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text(hospital['name']),
            subtitle: Text("Location: ${hospital['location']}"),
            onTap: () {
              // Navigate to Hospital Details or Admission Form Page
            },
          );
        },
      ),
    );
  }
}
