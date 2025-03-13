// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:doctor_app/payment_page.dart'; // Import the payment page

// class LabBookingPage extends StatefulWidget {
//   final String testName;
//   final String selectedDate;
//   final String selectedTime;
//   final double amount; // Test price

//   const LabBookingPage({
//     required this.testName,
//     required this.selectedDate,
//     required this.selectedTime,
//     required this.amount,
//   });

//   @override
//   _LabBookingPageState createState() => _LabBookingPageState();
// }

// class _LabBookingPageState extends State<LabBookingPage> {
//   bool isChecked = false; // Checkbox for Terms & Conditions

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Confirm Lab Test Booking"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Test Name: ${widget.testName}",
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text("Date: ${widget.selectedDate}",
//                 style: const TextStyle(fontSize: 16)),
//             Text("Time: ${widget.selectedTime}",
//                 style: const TextStyle(fontSize: 16)),
//             Text("Price: ₹${widget.amount.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green)),
//             const Divider(height: 30),

//             // Terms & Conditions Checkbox
//             Row(
//               children: [
//                 Checkbox(
//                   value: isChecked,
//                   activeColor: Colors.blue,
//                   onChanged: (value) {
//                     setState(() {
//                       isChecked = value!;
//                     });
//                   },
//                 ),
//                 const Expanded(
//                   child: Text("I agree to the Terms & Conditions"),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Proceed to Payment Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isChecked
//                     ? () => _saveLabBooking(context)
//                     : null, // Only proceed if checked
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: const Text("Proceed to Payment",
//                     style: TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // **Save Booking and Navigate to Payment**
//   void _saveLabBooking(BuildContext context) async {
//     DocumentReference bookingRef =
//         await FirebaseFirestore.instance.collection('lab_bookings').add({
//       'test_name': widget.testName,
//       'date': widget.selectedDate,
//       'time': widget.selectedTime,
//       'user_id': 1, // Replace with logged-in user's ID
//       'status': 'pending',
//       'booking_date': DateTime.now(),
//       'amount': widget.amount, // Store the correct amount
//     });

//     // Navigate to Payment Page
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PaymentPage(
//           bookingId: bookingRef.id,
//           paymentType: "lab",
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LabPaymentPage extends StatelessWidget {
  final String labId;
  final String labName;
  final String testId;
  final String testName;
  final String slot;
  final double price;

  LabPaymentPage({
    required this.labId,
    required this.labName,
    required this.testId,
    required this.testName,
    required this.slot,
    required this.price,
  });

  Future<void> _confirmBooking(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('lab_test_bookings').add({
        'lab_id': labId,
        'lab_name': labName,
        'test_id': testId,
        'test_name': testName,
        'slot': slot,
        'price': price,
        'user_id': '1', // Replace with actual user ID
        'status': 'pending',
        'booking_date': DateTime.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Booking confirmed!")));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to confirm booking: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Lab: $labName", style: TextStyle(fontSize: 18)),
            Text("Test: $testName", style: TextStyle(fontSize: 18)),
            Text("Slot: $slot", style: TextStyle(fontSize: 18)),
            Text("Price: ₹$price", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmBooking(context),
              child: Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
