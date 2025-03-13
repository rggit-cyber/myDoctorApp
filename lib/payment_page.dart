// import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId; // Firestore document ID
  final String paymentType; // "doctor" or "lab"

  const PaymentPage({required this.bookingId, required this.paymentType});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isProcessing = false;
  double amount = 0.0;
  String serviceName = "";
  String selectedDate = "";
  String selectedTime = "";

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
  }

  // Fetch the correct amount from Firestore
  void _fetchPaymentDetails() async {
    var doc = await FirebaseFirestore.instance
        .collection(
            widget.paymentType == "doctor" ? "bookings" : "lab_bookings")
        .doc(widget.bookingId)
        .get();

    if (doc.exists) {
      setState(() {
        amount = doc['amount']; // Fetch correct amount
        serviceName =
            doc[widget.paymentType == "doctor" ? "doctor_name" : "test_name"];
        selectedDate = doc['date'];
        selectedTime = doc['time'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.paymentType == "doctor" ? "Doctor Payment" : "Lab Payment"),
        backgroundColor: Colors.blueAccent,
      ),
      body: amount == 0.0
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading until amount is fetched
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.paymentType == "doctor"
                        ? "Doctor: $serviceName"
                        : "Lab Test: $serviceName",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Date: $selectedDate",
                      style: const TextStyle(fontSize: 16)),
                  Text("Time: $selectedTime",
                      style: const TextStyle(fontSize: 16)),
                  const Divider(height: 30),
                  Text(
                    "Total Amount: ₹${amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () => _processPayment(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Center(
                            child: Text(
                              "Pay Now",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  void _processPayment() async {
    setState(() => isProcessing = true);

    // Simulate payment processing (Replace this with an actual payment gateway)
    await Future.delayed(const Duration(seconds: 3));

    setState(() => isProcessing = false);

    // Update Firestore with payment status
    await FirebaseFirestore.instance
        .collection(
            widget.paymentType == "doctor" ? "bookings" : "lab_bookings")
        .doc(widget.bookingId)
        .update({'status': 'paid'});

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Successful"),
        content: Text(
            "Your ${widget.paymentType == "doctor" ? "doctor appointment" : "lab test"} is confirmed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to the previous page
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class PaymentPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Payment"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Payment Page (Integration Pending)"),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Simulate payment completion
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Payment Successful!")),
//                 );
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               },
//               child: Text("Pay"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
