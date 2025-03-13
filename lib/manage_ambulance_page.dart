// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ManageAmbulancePage extends StatefulWidget {
//   @override
//   _ManageAmbulancePageState createState() => _ManageAmbulancePageState();
// }

// class _ManageAmbulancePageState extends State<ManageAmbulancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void _addAmbulance(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String name = '';
//         String subheading = '';
//         String type = '';
//         double pricePerKm = 0.0;
//         bool availability = true;

//         return AlertDialog(
//           title: Text("Add Ambulance"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: "Ambulance Name"),
//                   onChanged: (value) => name = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Subheading"),
//                   onChanged: (value) => subheading = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Type"),
//                   onChanged: (value) => type = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Price per Km"),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) =>
//                       pricePerKm = double.tryParse(value) ?? 0.0,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (name.isNotEmpty && pricePerKm > 0.0) {
//                   _firestore.collection('ambulances').add({
//                     'name': name,
//                     'subheading': subheading,
//                     'type': type,
//                     'price_per_km': pricePerKm,
//                     'availability': availability,
//                   });
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _editAmbulance(BuildContext context, String ambulanceId,
//       Map<String, dynamic> currentData) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String name = currentData['name'] ?? '';
//         String subheading = currentData['subheading'] ?? '';
//         String type = currentData['type'] ?? '';
//         double pricePerKm = currentData['price_per_km'] ?? 0.0;
//         bool availability = currentData['availability'] ?? true;

//         return AlertDialog(
//           title: Text("Edit Ambulance"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: "Ambulance Name"),
//                   controller: TextEditingController(text: name),
//                   onChanged: (value) => name = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Subheading"),
//                   controller: TextEditingController(text: subheading),
//                   onChanged: (value) => subheading = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Type"),
//                   controller: TextEditingController(text: type),
//                   onChanged: (value) => type = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Price per Km"),
//                   controller:
//                       TextEditingController(text: pricePerKm.toString()),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) =>
//                       pricePerKm = double.tryParse(value) ?? 0.0,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (name.isNotEmpty && pricePerKm > 0.0) {
//                   _firestore.collection('ambulances').doc(ambulanceId).update({
//                     'name': name,
//                     'subheading': subheading,
//                     'type': type,
//                     'price_per_km': pricePerKm,
//                     'availability': availability,
//                   });
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteAmbulance(String ambulanceId) {
//     _firestore.collection('ambulances').doc(ambulanceId).delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Manage Ambulances"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => _addAmbulance(context),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('ambulances').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No ambulances found."));
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               final ambulance = doc.data() as Map<String, dynamic>;
//               return Card(
//                 child: ListTile(
//                   title: Text("${ambulance['name']}",
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle:
//                       Text("${ambulance['subheading']} - ${ambulance['type']}"),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Switch(
//                         value: ambulance['availability'],
//                         onChanged: (value) {
//                           _firestore
//                               .collection('ambulances')
//                               .doc(doc.id)
//                               .update({'availability': value});
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () =>
//                             _editAmbulance(context, doc.id, ambulance),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _deleteAmbulance(doc.id),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAmbulancePage extends StatefulWidget {
  @override
  _ManageAmbulancePageState createState() => _ManageAmbulancePageState();
}

class _ManageAmbulancePageState extends State<ManageAmbulancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addAmbulance(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController subheadingController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool availability = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Ambulance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Ambulance Name"),
                ),
                TextField(
                  controller: subheadingController,
                  decoration: InputDecoration(labelText: "Subheading"),
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: "Type"),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price per Km"),
                  keyboardType: TextInputType.number,
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
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  try {
                    await _firestore.collection('ambulances').add({
                      'name': nameController.text,
                      'subheading': subheadingController.text,
                      'type': typeController.text,
                      'price_per_km':
                          double.tryParse(priceController.text) ?? 0.0,
                      'availability': availability,
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding ambulance: $e");
                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editAmbulance(BuildContext context, String ambulanceId,
      Map<String, dynamic> currentData) {
    TextEditingController nameController =
        TextEditingController(text: currentData['name']);
    TextEditingController subheadingController =
        TextEditingController(text: currentData['subheading']);
    TextEditingController typeController =
        TextEditingController(text: currentData['type']);
    TextEditingController priceController =
        TextEditingController(text: currentData['price_per_km'].toString());
    bool availability = currentData['availability'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Ambulance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Ambulance Name"),
                ),
                TextField(
                  controller: subheadingController,
                  decoration: InputDecoration(labelText: "Subheading"),
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: "Type"),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price per Km"),
                  keyboardType: TextInputType.number,
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
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  try {
                    await _firestore
                        .collection('ambulances')
                        .doc(ambulanceId)
                        .update({
                      'name': nameController.text,
                      'subheading': subheadingController.text,
                      'type': typeController.text,
                      'price_per_km':
                          double.tryParse(priceController.text) ?? 0.0,
                      'availability': availability,
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error updating ambulance: $e");
                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteAmbulance(String ambulanceId) async {
    try {
      await _firestore.collection('ambulances').doc(ambulanceId).delete();
    } catch (e) {
      print("Error deleting ambulance: $e");
    }
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
        stream: _firestore.collection('ambulances').snapshots(),
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
              return Card(
                child: ListTile(
                  title: Text("${ambulance['name']}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text("${ambulance['subheading']} - ${ambulance['type']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: ambulance['availability'],
                        onChanged: (value) async {
                          try {
                            await _firestore
                                .collection('ambulances')
                                .doc(doc.id)
                                .update({'availability': value});
                          } catch (e) {
                            print("Error updating availability: $e");
                          }
                        },
                      ),
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
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
