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
        String contact = '';
        List<String> availableTests = [];
        Map<String, int> testPrices = {};

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
                  decoration: InputDecoration(labelText: "Contact"),
                  onChanged: (value) => contact = value,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Available Tests (comma-separated)"),
                  onChanged: (value) {
                    availableTests =
                        value.split(',').map((e) => e.trim()).toList();
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText:
                          "Test Prices (format: test1:price1, test2:price2)"),
                  onChanged: (value) {
                    testPrices = {};
                    value.split(',').forEach((entry) {
                      List<String> parts = entry.split(':');
                      if (parts.length == 2) {
                        testPrices[parts[0].trim()] =
                            int.tryParse(parts[1].trim()) ?? 0;
                      }
                    });
                  },
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
                    'contact': contact,
                    'available_tests': availableTests,
                    'test_prices': testPrices,
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
        String contact = currentData['contact'] ?? '';
        List<String> availableTests =
            List<String>.from(currentData['available_tests'] ?? []);
        Map<String, int> testPrices =
            Map<String, int>.from(currentData['test_prices'] ?? {});

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
                  decoration: InputDecoration(labelText: "Contact"),
                  controller: TextEditingController(text: contact),
                  onChanged: (value) => contact = value,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Available Tests (comma-separated)"),
                  controller:
                      TextEditingController(text: availableTests.join(', ')),
                  onChanged: (value) {
                    availableTests =
                        value.split(',').map((e) => e.trim()).toList();
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText:
                          "Test Prices (format: test1:price1, test2:price2)"),
                  controller: TextEditingController(
                      text: testPrices.entries
                          .map((e) => "${e.key}:${e.value}")
                          .join(', ')),
                  onChanged: (value) {
                    testPrices = {};
                    value.split(',').forEach((entry) {
                      List<String> parts = entry.split(':');
                      if (parts.length == 2) {
                        testPrices[parts[0].trim()] =
                            int.tryParse(parts[1].trim()) ?? 0;
                      }
                    });
                  },
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
                    'contact': contact,
                    'available_tests': availableTests,
                    'test_prices': testPrices,
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

  void _addSlot(BuildContext context, String labId) {
    showDialog(
      context: context,
      builder: (context) {
        String time = '';
        bool availability = true;

        return AlertDialog(
          title: Text("Add Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Time (e.g., 10:00 AM)"),
                onChanged: (value) => time = value,
              ),
              SwitchListTile(
                title: Text("Available"),
                value: availability,
                onChanged: (value) => availability = value,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (time.isNotEmpty) {
                  _firestore
                      .collection('labs')
                      .doc(labId)
                      .collection('slots')
                      .add({
                    'time': time,
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

  // Function to Delete Slot
  void _deleteSlot(String labId, String slotId) {
    _firestore
        .collection('labs')
        .doc(labId)
        .collection('slots')
        .doc(slotId)
        .delete();
  }

  void _editSlot(BuildContext context, String labId, String slotId,
      Map<String, dynamic> slotData) {
    TextEditingController timeController =
        TextEditingController(text: slotData['time']);
    bool availability = slotData['availability'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: "Time (e.g., 10:00 AM)"),
              ),
              SwitchListTile(
                title: Text("Available"),
                value: availability,
                onChanged: (value) {
                  availability = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (timeController.text.isNotEmpty) {
                  _firestore
                      .collection('labs')
                      .doc(labId)
                      .collection('slots')
                      .doc(slotId)
                      .update({
                    'time': timeController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              return ExpansionTile(
                title: Text(lab['name']),
                subtitle: Text(
                    "Address: ${lab['address']} | Contact: ${lab['contact']}"),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Available Tests: ${lab['available_tests'].join(', ')}"),
                        Text("Test Prices:"),
                        ...lab['test_prices']
                            .entries
                            .map<Widget>((entry) =>
                                Text("${entry.key}: ₹${entry.value}"))
                            .toList(),
                        SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('labs')
                              .doc(doc.id)
                              .collection('slots')
                              .snapshots(),
                          builder: (context, slotSnapshot) {
                            if (!slotSnapshot.hasData)
                              return CircularProgressIndicator();
                            var slots = slotSnapshot.data!.docs;
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...slots.map((slot) {
                                    var slotData =
                                        slot.data() as Map<String, dynamic>;
                                    bool isAvailable =
                                        slotData['availability'] ?? false;
                                    return ListTile(
                                      title: Text("Slot: ${slotData['time']}"),
                                      subtitle: Text(isAvailable
                                          ? 'Available'
                                          : 'Not Available'),
                                      trailing: IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          print("Hello edit");
                                          print(doc.id + "  " + slot.id + "  ");
                                          _editSlot(
                                            context,
                                            doc.id,
                                            slot.id,
                                            slotData,
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                  ElevatedButton(
                                    onPressed: () => _addSlot(context, doc.id),
                                    child: Text("Add Slot"),
                                  ),
                                ]);
                          },
                        )
                      ],
                    ),
                  ),
                  OverflowBar(
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
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
