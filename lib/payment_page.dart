import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Payment Page (Integration Pending)"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate payment completion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Payment Successful!")),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Pay"),
            ),
          ],
        ),
      ),
    );
  }
}
