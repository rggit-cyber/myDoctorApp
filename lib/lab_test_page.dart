import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LabTestPage extends StatefulWidget {
  @override
  _LabTestPageState createState() => _LabTestPageState();
}

class _LabTestPageState extends State<LabTestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> labTests = [];

  @override
  void initState() {
    super.initState();
    _fetchLabTests();
  }

  Future<void> _fetchLabTests() async {
    final labTestsSnapshot = await _firestore.collection('lab_tests').get();
    setState(() {
      labTests = labTestsSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab Tests"),
      ),
      body: ListView.builder(
        itemCount: labTests.length,
        itemBuilder: (context, index) {
          final labTest = labTests[index];
          return ListTile(
            leading: Icon(Icons.science),
            title: Text(labTest['name']),
            subtitle: Text("Category: ${labTest['category']}"),
            onTap: () {
              // Navigate to Lab Test Details or Booking Page
            },
          );
        },
      ),
    );
  }
}
