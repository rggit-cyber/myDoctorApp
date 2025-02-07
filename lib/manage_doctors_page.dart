// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDoctorsPage extends StatefulWidget {
  @override
  _ManageDoctorsPageState createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _slotController = TextEditingController();
  final String doctorId = "doctorId"; // Replace with dynamic booking ID
  List<String> slots = [];
  // Function to Fetch Slots
  // Future<List<String>> getSlots(String doctorId) async {
  //   DocumentSnapshot doc =
  //       await _firestore.collection('doctorId').doc(doctorId).get();

  //   if (doc.exists) {
  //     Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //     if (data != null && data.containsKey('availability')) {
  //       List<dynamic> slots = data['availability']['slots'] ?? [];
  //       return List<String>.from(slots);
  //     }
  //   }
  //   return [];
  // }

  // void _addSlot() async {
  //   String newSlot = _slotController.text.trim();
  //   if (newSlot.isNotEmpty) {
  //     await (doctorId, newSlot);
  //     _slotController.clear();
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("Slot Added!")));
  //   }
  // }

  void _addDoctor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String specialization = '';
        int experienceYears = 0;

        return AlertDialog(
          title: Text("Add Doctor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Specialization"),
                onChanged: (value) => specialization = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Experience (Years)"),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    experienceYears = int.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && specialization.isNotEmpty) {
                  _firestore.collection('doctors').add({
                    'name': name,
                    'specialization': specialization,
                    'experience_years': experienceYears,
                    'availability': {'slots': []},
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _editDoctor(
      BuildContext context, String doctorId, Map<String, dynamic> currentData) {
    showDialog(
      context: context,
      builder: (context) {
        String name = currentData['name'] ?? '';
        // Array newslot = currentData['slots'] ?? '';
        String specialization = currentData['specialization'] ?? '';
        int experienceYears = currentData['experience_years'] ?? 0;

        return AlertDialog(
          title: Text("Edit Doctor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Specialization"),
                controller: TextEditingController(text: specialization),
                onChanged: (value) => specialization = value,
              ),
              //   TextField(
              //   controller: _slotController,
              //   decoration: InputDecoration(labelText: "Enter Slot (e.g., 10:00 AM)"),
              //   onChanged: (value) => newslot = value as Array<NativeType>,
              // ),
              TextField(
                decoration: InputDecoration(labelText: "Experience (Years)"),
                controller:
                    TextEditingController(text: experienceYears.toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    experienceYears = int.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && specialization.isNotEmpty) {
                  _firestore.collection('doctors').doc(doctorId).update({
                    'name': name,
                    'specialization': specialization,
                    'experience_years': experienceYears,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteDoctor(String doctorId) {
    _firestore.collection('doctors').doc(doctorId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Doctors"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addDoctor(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final doctor = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(doctor['name']),
                subtitle: Text("Specialization: ${doctor['specialization']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editDoctor(context, doc.id, doctor),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDoctor(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
