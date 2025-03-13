import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class UserBookingsPage extends StatefulWidget {
  final String userId; // Logged-in user ID

  UserBookingsPage({required this.userId});

  @override
  _UserBookingsPageState createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = "lab_test_bookings"; // Default: Lab Bookings

  Stream<QuerySnapshot> _getFilteredBookings() {
    return _firestore
        .collection(selectedCategory)
        .where('user_id', isEqualTo: widget.userId)
        .snapshots();
  }

  void _confirmCancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Booking?"),
        content: Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore
                  .collection(selectedCategory)
                  .doc(bookingId)
                  .update({'status': 'cancelled'});
              Navigator.pop(context); // Close dialog
            },
            child: Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  void _rescheduleBooking(String bookingId, String currentDate) async {
    print("Hello");
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
      _firestore
          .collection(selectedCategory)
          .doc(bookingId)
          .update({'requested_date': formattedDate, 'status': 'requested'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(
                  value: "lab_test_bookings", child: Text("Lab Tests")),
              DropdownMenuItem(
                  value: "hospital_bookings", child: Text("Hospitals")),
              DropdownMenuItem(
                  value: "ambulance_bookings", child: Text("Ambulance")),
              DropdownMenuItem(
                  value: "radiology_bookings", child: Text("Radiology")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                });
              }
            },
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

              return Card(
                child: ListTile(
                  title: Text(_getBookingTitle(booking)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getLocationText(booking)),
                      Text("Date: ${booking['date']}"),
                      Text("Status: ${booking['status']}"),
                      Text("Price: ₹${booking['price']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (booking['status'] !=
                          'cancelled') // Show cancel button only if not cancelled
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _confirmCancelBooking(doc.id),
                        ),
                      if (booking['status'] !=
                          'cancelled') // Show reschedule button only if not cancelled
                        IconButton(
                          icon: Icon(Icons.edit_calendar, color: Colors.blue),
                          onPressed: () =>
                              _rescheduleBooking(doc.id, booking['date']),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Determine the title based on the selected category
  String _getBookingTitle(Map<String, dynamic> booking) {
    switch (selectedCategory) {
      case "lab_test_bookings":
        return booking['test_name'] ?? "Lab Test";
      case "hospital_bookings":
        return booking['doctor_name'] ?? "Hospital Visit";
      case "ambulance_bookings":
        return booking['ambulance_type'] ?? "Ambulance Booking";
      case "radiology_bookings":
        return booking['test_name'] ?? "Radiology Test";
      default:
        return "Booking";
    }
  }

  // Determine the location-based field dynamically
  String _getLocationText(Map<String, dynamic> booking) {
    switch (selectedCategory) {
      case "lab_test_bookings":
        return "Lab: ${booking['lab_name']}";
      case "hospital_bookings":
        return "Hospital: ${booking['hospital_name']}";
      case "ambulance_bookings":
        return "Pickup: ${booking['pickup_location']} → ${booking['destination']}";
      case "radiology_bookings":
        return "Center: ${booking['radiology_center']}";
      default:
        return "";
    }
  }
}
