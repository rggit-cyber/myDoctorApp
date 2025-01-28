import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAmbulancePage extends StatefulWidget {
  @override
  _ManageAmbulancePageState createState() => _ManageAmbulancePageState();
}

class _ManageAmbulancePageState extends State<ManageAmbulancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addAmbulance(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String type = '';
        double pricePerKm = 0.0;
        bool availability = true;

        return AlertDialog(
          title: Text("Add Ambulance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Type"),
                  onChanged: (value) => type = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Price per Km"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      pricePerKm = double.tryParse(value) ?? 0.0,
                ),
                SwitchListTile(
                  title: Text("Availability"),
                  value: availability,
                  onChanged: (value) => availability = value,
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
                if (type.isNotEmpty && pricePerKm > 0.0) {
                  _firestore.collection('ambulance_services').add({
                    'type': type,
                    'price_per_km': pricePerKm,
                    'availability': availability,
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

  void _editAmbulance(BuildContext context, String ambulanceId,
      Map<String, dynamic> currentData) {
    showDialog(
      context: context,
      builder: (context) {
        String type = currentData['type'] ?? '';
        double pricePerKm = currentData['price_per_km'] ?? 0.0;
        bool availability = currentData['availability'] ?? true;

        return AlertDialog(
          title: Text("Edit Ambulance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Type"),
                  controller: TextEditingController(text: type),
                  onChanged: (value) => type = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Price per Km"),
                  controller:
                      TextEditingController(text: pricePerKm.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      pricePerKm = double.tryParse(value) ?? 0.0,
                ),
                SwitchListTile(
                  title: Text("Availability"),
                  value: availability,
                  onChanged: (value) => availability = value,
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
                if (type.isNotEmpty && pricePerKm > 0.0) {
                  _firestore
                      .collection('ambulance_services')
                      .doc(ambulanceId)
                      .update({
                    'type': type,
                    'price_per_km': pricePerKm,
                    'availability': availability,
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

  void _deleteAmbulance(String ambulanceId) {
    _firestore.collection('ambulance_services').doc(ambulanceId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Ambulances"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addAmbulance(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('ambulance_services').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No ambulances found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final ambulance = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Type: ${ambulance['type']}"),
                subtitle: Text(
                    "Price per Km: ${ambulance['price_per_km']} | Available: ${ambulance['availability'] ? 'Yes' : 'No'}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _editAmbulance(context, doc.id, ambulance),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAmbulance(doc.id),
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
