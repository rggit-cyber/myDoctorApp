import 'package:flutter/material.dart';

class ServicePage extends StatelessWidget {
  final String title;

  const ServicePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Available Options for $title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with real data
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.local_hospital),
                    title: Text("$title Option $index"),
                    subtitle: Text("Details for option $index"),
                    onTap: () {
                      // Navigate to booking or details
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
