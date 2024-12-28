import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AmbulanceServicePage extends StatefulWidget {
  @override
  _AmbulanceServicePageState createState() => _AmbulanceServicePageState();
}

class _AmbulanceServicePageState extends State<AmbulanceServicePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ambulanceServices = [];

  @override
  void initState() {
    super.initState();
    _fetchAmbulanceServices();
  }

  Future<void> _fetchAmbulanceServices() async {
    final ambulanceServicesSnapshot =
        await _firestore.collection('ambulance_services').get();
    setState(() {
      ambulanceServices =
          ambulanceServicesSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ambulance Services"),
      ),
      body: ListView.builder(
        itemCount: ambulanceServices.length,
        itemBuilder: (context, index) {
          final service = ambulanceServices[index];
          return ListTile(
            leading: Icon(Icons.local_taxi),
            title: Text(service['name']),
            subtitle: Text("Contact: ${service['contact']}"),
            onTap: () {
              // Navigate to Ambulance Details or Request Page
            },
          );
        },
      ),
    );
  }
}
