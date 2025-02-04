import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/lab_slot_selection_page.dart';
import 'package:flutter/material.dart';

class LabListPage extends StatelessWidget {
  final String testId = "1";
  final String testName;

  LabListPage({required this.testName});

  @override
  Widget build(BuildContext context) {
    print("testname" + testName);
    return Scaffold(
      appBar: AppBar(title: Text("$testName - Labs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labs')
            .where('available_tests', arrayContains: testName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          print(snapshot.data?.docs);
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final lab = doc.data() as Map<String, dynamic>;
              print("Lab data $lab");
              print("doc " + doc.id);
              print("testId" + testId);
              return ListTile(
                title: Text(lab['name']),
                subtitle: Text("Price: ₹${lab['test_prices'][testName]}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SlotSelectionPage(
                        labId: doc.id,
                        labName: lab['name'],
                        testId: testId,
                        testName: testName,
                        price: lab['test_prices'][testName],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
