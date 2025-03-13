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

  void _addSlot(BuildContext context, String labId) async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    Future<TimeOfDay?> pickTime(BuildContext context) async {
      return await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Slot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(startTime == null
                        ? "Pick Start Time"
                        : "Start Time: ${startTime!.format(context)}"),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await pickTime(context);
                      if (picked != null) {
                        setState(() => startTime = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(endTime == null
                        ? "Pick End Time"
                        : "End Time: ${endTime!.format(context)}"),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await pickTime(context);
                      if (picked != null) {
                        setState(() => endTime = picked);
                      }
                    },
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
                    if (startTime != null && endTime != null) {
                      String slotTime =
                          "${startTime!.format(context)} - ${endTime!.format(context)}";
                      _firestore
                          .collection('labs')
                          .doc(labId)
                          .collection('slots')
                          .add({
                        'time': slotTime,
                        'availability': true,
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
    TimeOfDay? startTime = slotData['start_time'] != null
        ? TimeOfDay(
            hour: int.parse(slotData['start_time'].split(':')[0]),
            minute:
                int.parse(slotData['start_time'].split(':')[1].split(' ')[0]))
        : null;
    TimeOfDay? endTime = slotData['end_time'] != null
        ? TimeOfDay(
            hour: int.parse(slotData['end_time'].split(':')[0]),
            minute: int.parse(slotData['end_time'].split(':')[1].split(' ')[0]))
        : null;
    bool availability = slotData['availability'];

    Future<TimeOfDay?> _pickTime() async {
      return await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Slot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? picked = await _pickTime();
                      if (picked != null) {
                        setState(() {
                          startTime = picked;
                        });
                      }
                    },
                    child: Text(startTime == null
                        ? "Pick Start Time"
                        : "Start Time: ${startTime!.format(context)}"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? picked = await _pickTime();
                      if (picked != null) {
                        setState(() {
                          endTime = picked;
                        });
                      }
                    },
                    child: Text(endTime == null
                        ? "Pick End Time"
                        : "End Time: ${endTime!.format(context)}"),
                  ),
                  SwitchListTile(
                    title: Text("Available"),
                    value: availability,
                    onChanged: (value) {
                      setState(() {
                        availability = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _firestore
                        .collection('labs')
                        .doc(labId)
                        .collection('slots')
                        .doc(slotId)
                        .delete();
                    Navigator.pop(context);
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (startTime != null && endTime != null) {
                      _firestore
                          .collection('labs')
                          .doc(labId)
                          .collection('slots')
                          .doc(slotId)
                          .update({
                        'time':
                            "${startTime!.format(context)} - ${endTime!.format(context)}",
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
