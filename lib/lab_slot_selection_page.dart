import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/lab_payment_page.dart';
import 'package:flutter/material.dart';

class SlotSelectionPage extends StatelessWidget {
  final String labId;
  final String labName;
  final String testId;
  final String testName;
  final double price;

  SlotSelectionPage({
    required this.labId,
    required this.labName,
    required this.testId,
    required this.testName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Slot")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labs')
            .doc(labId)
            .collection('slots')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var slots = snapshot.data!.docs.map((doc) {
            final slot = doc.data() as Map<String, dynamic>;
            return {
              "time": slot['time'],
              "available": slot['availability'],
              "id": doc.id
            };
          }).toList();

          return Padding(
            padding: EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 slots per row
                childAspectRatio: 2.5, // Adjust height
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final slot = slots[index];

                return GestureDetector(
                  onTap: () {
                    if (slot['available']) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LabPaymentPage(
                            labId: labId,
                            labName: labName,
                            testId: testId,
                            testName: testName,
                            slot: slot['time'],
                            price: price,
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    color:
                        slot['available'] ? Colors.green[100] : Colors.red[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: Center(
                      child: Text(
                        slot['time'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: slot['available']
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:doctor_app/lab_payment_page.dart';
// import 'package:flutter/material.dart';

// class SlotSelectionPage extends StatelessWidget {
//   final String labId;
//   final String labName;
//   final String testId;
//   final String testName;
//   final double price;

//   SlotSelectionPage({
//     required this.labId,
//     required this.labName,
//     required this.testId,
//     required this.testName,
//     required this.price,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Slot")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('labs')
//             .doc(labId)
//             .collection('slots')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               final slot = doc.data() as Map<String, dynamic>;
//               return ListTile(
//                 title: Text("Slot: ${slot['time']}"),
//                 subtitle:
//                     Text(slot['availability'] ? "Available" : "Not Available"),
//                 onTap: () {
//                   if (slot['availability']) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LabPaymentPage(
//                           labId: labId,
//                           labName: labName,
//                           testId: testId,
//                           testName: testName,
//                           slot: slot['time'],
//                           price: price,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
