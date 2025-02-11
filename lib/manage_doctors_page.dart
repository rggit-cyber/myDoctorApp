import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageDoctorsPage extends StatefulWidget {
  @override
  _ManageDoctorsPageState createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String doctorId = "doctorId"; // Replace with dynamic doctor ID
  //Add Doctors
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
              ListTile(
                title: Text(selectedDate == null
                    ? "Select Date"
                    : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(selectedTime == null
                    ? "Select Time"
                    : selectedTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
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
                    'availability': {'slots': []},
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
  //Add Doctors

  //Add Slot
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _addSlots(BuildContext context, String doctorId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Slots"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(selectedDate == null
                    ? "Select Date"
                    : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(selectedTime == null
                    ? "Select Time"
                    : selectedTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
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
                if (selectedDate != null && selectedTime != null) {
                  String formattedSlot =
                      "${DateFormat('yyyy-MM-dd').format(selectedDate!)} ${selectedTime!.format(context)}";

                  await _firestore.collection('doctors').doc(doctorId).update({
                    'availability.slots':
                        FieldValue.arrayUnion([formattedSlot]),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Slot added successfully!")),
                  );

                  setState(() {
                    selectedDate = null;
                    selectedTime = null;
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

  //Add Slot

  //Edit Doctors
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
  //Edit Doctors

  // Function to Add Availability Slots
  Future<void> addDoctorAvailability(String doctorId, String newSlot) async {
    if (newSlot.isEmpty) return;

    try {
      DocumentReference doctorRef =
          FirebaseFirestore.instance.collection('doctors').doc(doctorId);

      await doctorRef.update({
        'availability.slots': FieldValue.arrayUnion([newSlot]),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Slot Added Successfully!")));
      setState(() {
        selectedDate = null;
        selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Function to Toggle Doctor Availability
  Future<void> toggleDoctorAvailability(
      String doctorId, bool isAvailable) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'availability.status': isAvailable,
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Function to Edit a Slot
  void _editSlot(BuildContext context, String doctorId, String oldSlot) {
    List<String> slotParts = oldSlot.split(" ");
    DateTime initialDate = DateFormat('yyyy-MM-dd').parse(slotParts[0]);
    TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(slotParts[1].split(":")[0]),
      minute: int.parse(slotParts[1].split(":")[1]),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Edit Slot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(DateFormat('yyyy-MM-dd').format(initialDate)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          initialDate = pickedDate;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(initialTime.format(context)),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          initialTime = pickedTime;
                        });
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
                  onPressed: () async {
                    String newSlot =
                        "${DateFormat('yyyy-MM-dd').format(initialDate)} ${initialTime.format(context)}";

                    DocumentReference doctorRef =
                        _firestore.collection('doctors').doc(doctorId);

                    await doctorRef.update({
                      'availability.slots': FieldValue.arrayRemove([oldSlot]),
                    });
                    await doctorRef.update({
                      'availability.slots': FieldValue.arrayUnion([newSlot]),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Slot updated successfully!")),
                    );

                    Navigator.pop(context);
                    Navigator.pop(context);
                    // Refresh UI after closing the dialog
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

  // Function to delete a Slot
  Future<void> _deleteSlot(String doctorId, String slot) async {
    try {
      DocumentReference doctorRef =
          _firestore.collection('doctors').doc(doctorId);
      await doctorRef.update({
        'availability.slots': FieldValue.arrayRemove([slot]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Slot deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              final List slots = doctor['availability']['slots'] ?? [];
              final bool isAvailable = doctor['availability']['status'] ?? true;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(doctor['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Specialization: ${doctor['specialization']}, \n Experience: ${doctor['experience_years']} years ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            "Add Slots",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _addSlots(context, doc.id);
                            },
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                          hint: Text("Select Slot to Edit/Delete"),
                          items: slots.map<DropdownMenuItem<String>>((slot) {
                            return DropdownMenuItem<String>(
                              value: slot,
                              child: Text(slot),
                            );
                          }).toList(),
                          onChanged: (String? newSlot) {
                            if (newSlot != null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Edit or Delete Slot"),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _editSlot(context, doc.id, newSlot);
                                          // Fix: Use `doc.id`
                                          // Navigator.pop(context);
                                          // _selectDate(context);
                                        },
                                        child: Text("Edit"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _deleteSlot(doc.id, newSlot);
                                          Navigator.pop(context);
                                        },
                                        child: Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }),
                      SwitchListTile(
                        title: Text("Doctor Available"),
                        value: isAvailable,
                        activeColor: Colors.green, // Thumb color when ON
                        activeTrackColor:
                            Colors.lightGreen, // Track color when ON
                        inactiveThumbColor: Colors.red, // Thumb color when OFF
                        inactiveTrackColor:
                            Colors.red.shade200, // Track color when OFF
                        onChanged: (bool value) {
                          toggleDoctorAvailability(doc.id, value);
                        },
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      _editDoctor(context, doc.id, doctor);
                    },
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
