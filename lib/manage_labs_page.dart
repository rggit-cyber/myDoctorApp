import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageLabsPage extends StatefulWidget {
  @override
  _ManageLabsPageState createState() => _ManageLabsPageState();
}

class _ManageLabsPageState extends State<ManageLabsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addLab(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String address = '';
        List<String> availableTests = [];

        return AlertDialog(
          title: Text("Add Lab"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Lab Name"),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Address"),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Available Tests (comma-separated)"),
                  onChanged: (value) => availableTests =
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
                  _firestore.collection('labs').add({
                    'name': name,
                    'address': address,
                    'available_tests': availableTests,
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

  void _editLab(
      BuildContext context, String labId, Map<String, dynamic> currentData) {
    showDialog(
      context: context,
      builder: (context) {
        String name = currentData['name'] ?? '';
        String address = currentData['address'] ?? '';
        List<String> availableTests =
            List<String>.from(currentData['available_tests'] ?? []);

        return AlertDialog(
          title: Text("Edit Lab"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Lab Name"),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Address"),
                  controller: TextEditingController(text: address),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Available Tests (comma-separated)"),
                  controller:
                      TextEditingController(text: availableTests.join(', ')),
                  onChanged: (value) => availableTests =
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
                  _firestore.collection('labs').doc(labId).update({
                    'name': name,
                    'address': address,
                    'available_tests': availableTests,
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

  void _deleteLab(String labId) {
    _firestore.collection('labs').doc(labId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Labs"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addLab(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('labs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No labs found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final lab = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(lab['name']),
                subtitle: Text(
                    "Address: ${lab['address']} | Tests: ${lab['available_tests'].join(', ')}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editLab(context, doc.id, lab),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteLab(doc.id),
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
