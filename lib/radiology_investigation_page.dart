import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RadiologyInvestigationPage extends StatefulWidget {
  @override
  _RadiologyInvestigationPageState createState() =>
      _RadiologyInvestigationPageState();
}

class _RadiologyInvestigationPageState
    extends State<RadiologyInvestigationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> investigations = [];

  @override
  void initState() {
    super.initState();
    _fetchInvestigations();
  }

  Future<void> _fetchInvestigations() async {
    final investigationsSnapshot =
        await _firestore.collection('radiology_investigations').get();
    setState(() {
      investigations =
          investigationsSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Radiology Investigations"),
      ),
      body: ListView.builder(
        itemCount: investigations.length,
        itemBuilder: (context, index) {
          final investigation = investigations[index];
          return ListTile(
            leading: Icon(Icons.medical_services),
            title: Text(investigation['name']),
            subtitle: Text("Type: ${investigation['type']}"),
            onTap: () {
              // Navigate to Radiology Investigation Details Page
            },
          );
        },
      ),
    );
  }
}
