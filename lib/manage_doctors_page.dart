import 'package:doctor_app/add_slots.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDoctorsPage extends StatefulWidget {
  @override
  _ManageDoctorsPageState createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Doctor Dialog
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  void _addDoctor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Doctor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: specializationController,
                decoration: InputDecoration(labelText: "Specialization"),
              ),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(labelText: "Experience (Years)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    specializationController.text.isNotEmpty) {
                  await _firestore.collection('doctors').add({
                    'name': nameController.text,
                    'specialization': specializationController.text,
                    'experience_years':
                        int.tryParse(experienceController.text) ?? 0,
                    'availability': {
                      'status': true
                    }, // Default availability status
                  });
                  nameController.clear();
                  specializationController.clear();
                  experienceController.clear();
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

  // Edit Doctor Dialog
  void _editDoctor(
      BuildContext context, String doctorId, Map<String, dynamic> currentData) {
    nameController.text = currentData['name'] ?? '';
    specializationController.text = currentData['specialization'] ?? '';
    experienceController.text = currentData['experience_years'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Doctor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: specializationController,
                decoration: InputDecoration(labelText: "Specialization"),
              ),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(labelText: "Experience (Years)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('doctors').doc(doctorId).update({
                  'name': nameController.text,
                  'specialization': specializationController.text,
                  'experience_years':
                      int.tryParse(experienceController.text) ?? 0,
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete Doctor
  void _deleteDoctor(String doctorId) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Doctor deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Toggle Doctor Availability
  Future<void> toggleDoctorAvailability(
      String doctorId, bool isAvailable) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'availability.status': isAvailable,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Manage Doctors"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _addDoctor(context);
            },
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
              final bool isAvailable = doctor['availability']['status'] ?? true;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(doctor['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Specialization: ${doctor['specialization']}\nExperience: ${doctor['experience_years']} years",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            "Add Slots",
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddSlotsPage(doctorId: doc.id),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: Text("Doctor Available"),
                        value: isAvailable,
                        activeColor: Colors.green,
                        activeTrackColor: Colors.lightGreen,
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red.shade200,
                        onChanged: (bool value) {
                          toggleDoctorAvailability(doc.id, value);
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _editDoctor(context, doc.id, doctor);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteDoctor(doc.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
