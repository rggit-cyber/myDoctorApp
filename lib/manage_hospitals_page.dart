import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageHospitalsPage extends StatefulWidget {
  @override
  _ManageHospitalsPageState createState() => _ManageHospitalsPageState();
}

class _ManageHospitalsPageState extends State<ManageHospitalsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addHospital(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String address = '';
        int beds = 0;
        List<String> departments = [];

        return AlertDialog(
          title: Text("Add Hospital"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Hospital Name"),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Address"),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Available Beds"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => beds = int.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Departments (comma-separated)"),
                  onChanged: (value) => departments =
                      value.split(',').map((e) => e.trim()).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && address.isNotEmpty) {
                  _firestore.collection('hospitals').add({
                    'name': name,
                    'location': {'address': address},
                    'availability': {'beds': beds},
                    'departments': departments,
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

  void _editHospital(BuildContext context, String hospitalId,
      Map<String, dynamic> currentData) {
    showDialog(
      context: context,
      builder: (context) {
        String name = currentData['name'] ?? '';
        String address = currentData['location']['address'] ?? '';
        int beds = currentData['availability']['beds'] ?? 0;
        List<String> departments =
            List<String>.from(currentData['departments'] ?? []);

        return AlertDialog(
          title: Text("Edit Hospital"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Hospital Name"),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Address"),
                  controller: TextEditingController(text: address),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Available Beds"),
                  controller: TextEditingController(text: beds.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => beds = int.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Departments (comma-separated)"),
                  controller:
                      TextEditingController(text: departments.join(', ')),
                  onChanged: (value) => departments =
                      value.split(',').map((e) => e.trim()).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && address.isNotEmpty) {
                  _firestore.collection('hospitals').doc(hospitalId).update({
                    'name': name,
                    'location': {'address': address},
                    'availability': {'beds': beds},
                    'departments': departments,
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

  void _deleteHospital(String hospitalId) {
    _firestore.collection('hospitals').doc(hospitalId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Manage Hospitals"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addHospital(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('hospitals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No hospitals found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final hospital = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(hospital['name']),
                subtitle: Text(
                    "Address: ${hospital['location']['address']} | Beds: ${hospital['availability']['beds']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editHospital(context, doc.id, hospital),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteHospital(doc.id),
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
