import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageBookingsPage extends StatefulWidget {
  @override
  _ManageBookingsPageState createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedStatus = 'all';
  DateTime? _selectedDate;

  Stream<QuerySnapshot> _getFilteredBookings() {
    Query<Map<String, dynamic>> query = _firestore.collection('bookings');

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    if (_selectedDate != null) {
      final start = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      ).toUtc(); // Convert to UTC
      final end =
          start.add(Duration(days: 1)).toUtc(); // Add one day for the range
      query = query.where('booking_date',
          isGreaterThanOrEqualTo: start, isLessThan: end);
    }

    return query.snapshots();
  }

  void _updateBookingStatus(
      BuildContext context, String bookingId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String newStatus = currentStatus;

        return AlertDialog(
          title: Text("Update Booking Status"),
          content: DropdownButton<String>(
            value: newStatus,
            items: ['pending', 'confirmed', 'cancelled']
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              if (value != null) newStatus = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _firestore
                    .collection('bookings')
                    .doc(bookingId)
                    .update({'status': newStatus});
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Manage Bookings"),
        actions: [
          DropdownButton<String>(
            value: _selectedStatus,
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(value: 'all', child: Text("All")),
              DropdownMenuItem(value: 'pending', child: Text("Pending")),
              DropdownMenuItem(value: 'confirmed', child: Text("Confirmed")),
              DropdownMenuItem(value: 'cancelled', child: Text("Cancelled")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No bookings found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final booking = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text("Doctor ID: ${booking['doctor_id']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Slot: ${booking['slot']}"),
                    Text("Status: ${booking['status']}"),
                    Text("User ID: ${booking['user_id']}"),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _updateBookingStatus(context, doc.id, booking['status']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
