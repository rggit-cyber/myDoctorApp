import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddSlotsPage extends StatefulWidget {
  final String doctorId;

  AddSlotsPage({required this.doctorId});

  @override
  _AddSlotsPageState createState() => _AddSlotsPageState();
}

class _AddSlotsPageState extends State<AddSlotsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> slots = []; // List of {date, day, times}
  Set<String> selectedDates = {}; // To disable already selected dates

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() async {
    var docSnapshot =
        await _firestore.collection('doctors').doc(widget.doctorId).get();

    if (docSnapshot.exists) {
      var data = docSnapshot.data();
      if (data != null && data.containsKey('availability')) {
        var availability = data['availability'];

        if (availability is Map<String, dynamic> &&
            availability.containsKey('slots') &&
            availability['slots'] is List) {
          List<dynamic> slotData = availability['slots'];
          DateTime now = DateTime.now();

          setState(() {
            slots = slotData.map<Map<String, dynamic>>((slot) {
              DateTime slotDate = DateTime.parse(slot["date"]);
              Duration difference =
                  slotDate.difference(DateTime.parse(slotData[0]["date"]));
              DateTime newDate = now.add(difference);

              return {
                "date": DateFormat('yyyy-MM-dd').format(newDate),
                "day": DateFormat('EEEE').format(newDate),
                "times": List<String>.from(slot["times"] ?? []),
                "available": slot["available"] ?? true,
              };
            }).toList();

            selectedDates = slots
                .where((s) => s["date"] != null)
                .map<String>((s) => s["date"].toString())
                .toSet();
          });
        } else {
          setState(() {
            slots = [];
          });
        }
      }
    }
  }

  void _addDateAndDay() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _getNextAvailableDate(now), // Ensure selectable date
      firstDate: now,
      lastDate: DateTime(2101),
      selectableDayPredicate: (date) => !_isDateSelected(date),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      String day = DateFormat('EEEE').format(pickedDate);

      setState(() {
        slots.add({
          "date": formattedDate,
          "day": day,
          "times": [],
          "available": true,
        });
        selectedDates.add(formattedDate);
      });
    }
  }

  /// ✅ Ensures `initialDate` is always selectable
  DateTime _getNextAvailableDate(DateTime start) {
    while (_isDateSelected(start)) {
      start = start.add(Duration(days: 1));
    }
    return start;
  }

  /// ✅ Checks if a date is already selected
  bool _isDateSelected(DateTime date) {
    return selectedDates.contains(DateFormat('yyyy-MM-dd').format(date));
  }

  void _editDateAndDay(int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(slots[index]["date"]),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      String day = DateFormat('EEEE').format(pickedDate);

      setState(() {
        slots[index]["date"] = formattedDate;
        slots[index]["day"] = day;
      });
    }
  }

  void _addTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);

      setState(() {
        slots[index]["times"].add(formattedTime);
      });
    }
  }

  void _editTime(int dateIndex, int timeIndex) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);

      setState(() {
        slots[dateIndex]["times"][timeIndex] = formattedTime;
      });
    }
  }

  void _deleteSlot(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Slot"),
        content: Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedDates.remove(slots[index]["date"]);
                slots.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSlots() async {
    await _firestore.collection('doctors').doc(widget.doctorId).update({
      'availability.slots': slots,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Slots saved successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Slots"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addDateAndDay,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: slots.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Date, Day, Edit & Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _addTime(index),
                        ),
                        Text(
                          "${slots[index]['date']} (${slots[index]['day']})",
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editDateAndDay(index),
                        ),
                      ],
                    ),

                    // Show Time Slots
                    Column(
                      children: slots[index]['times']
                          .map<Widget>((time) => ListTile(
                                title: Text(time),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editTime(index,
                                      slots[index]['times'].indexOf(time)),
                                ),
                              ))
                          .toList(),
                    ),

                    // Availability Toggle
                    SwitchListTile(
                      title: Text("Available"),
                      value: slots[index]['available'],
                      onChanged: (value) {
                        setState(() {
                          slots[index]['available'] = value;
                        });
                      },
                    ),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _deleteSlot(index),
                          child: Text("Delete"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: _saveSlots,
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
