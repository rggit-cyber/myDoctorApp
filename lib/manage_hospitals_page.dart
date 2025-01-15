import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageHospitalsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addHospital() async {
    await _firestore.collection('hospitals').add({
      'name': 'New Hospital',
      'location': {'latitude': 0.0, 'longitude': 0.0, 'address': ''},
      'departments': [],
      'availability': {'beds': 0},
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('hospitals').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final hospital = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(hospital['name']),
              subtitle: Text("Departments: ${hospital['departments'].length}"),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _firestore.collection('hospitals').doc(doc.id).delete();
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
