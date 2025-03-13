import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageLabTestsPage extends StatefulWidget {
  @override
  _ManageLabTestsPageState createState() => _ManageLabTestsPageState();
}

class _ManageLabTestsPageState extends State<ManageLabTestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addLabTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController testNameController = TextEditingController();
        TextEditingController priceController = TextEditingController();
        TextEditingController departmentController = TextEditingController();
        TextEditingController testTypeController = TextEditingController();

        return AlertDialog(
          title: Text("Add Lab Test"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: testNameController,
                  decoration: InputDecoration(labelText: "Test Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: departmentController,
                  decoration: InputDecoration(labelText: "Department"),
                ),
                TextField(
                  controller: testTypeController,
                  decoration: InputDecoration(labelText: "Category"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String testName = testNameController.text.trim();
                double price = double.tryParse(priceController.text) ?? 0.0;
                String department = departmentController.text.trim();
                String testType = testTypeController.text.trim();

                if (testName.isNotEmpty &&
                    price > 0.0 &&
                    department.isNotEmpty &&
                    testType.isNotEmpty) {
                  _firestore.collection('lab_tests').add({
                    'name': testName,
                    'price': price,
                    'department': department,
                    'test_type': testType,
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

  void _editLabTest(
      BuildContext context, String testId, Map<String, dynamic> currentData) {
    TextEditingController testNameController =
        TextEditingController(text: currentData['name'] ?? '');
    TextEditingController priceController =
        TextEditingController(text: currentData['price'].toString());
    TextEditingController departmentController =
        TextEditingController(text: currentData['department'] ?? '');
    TextEditingController testTypeController =
        TextEditingController(text: currentData['test_type'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Lab Test"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: testNameController,
                  decoration: InputDecoration(labelText: "Test Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: departmentController,
                  decoration: InputDecoration(labelText: "Department"),
                ),
                TextField(
                  controller: testTypeController,
                  decoration: InputDecoration(labelText: "Test Type"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String testName = testNameController.text.trim();
                double price = double.tryParse(priceController.text) ?? 0.0;
                String department = departmentController.text.trim();
                String testType = testTypeController.text.trim();

                if (testName.isNotEmpty &&
                    price > 0.0 &&
                    department.isNotEmpty &&
                    testType.isNotEmpty) {
                  _firestore.collection('lab_tests').doc(testId).update({
                    'name': testName,
                    'price': price,
                    'department': department,
                    'test_type': testType,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteLabTest(String testId) {
    _firestore.collection('lab_tests').doc(testId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Lab Tests"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addLabTest(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('lab_tests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No lab tests found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final labTest = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(labTest['name']),
                subtitle: Text(
                    "Price: ${labTest['price']} | Department: ${labTest['department']} | Type: ${labTest['test_type']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editLabTest(context, doc.id, labTest),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteLabTest(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ManageLabTestsPage extends StatefulWidget {
//   @override
//   _ManageLabTestsPageState createState() => _ManageLabTestsPageState();
// }

// class _ManageLabTestsPageState extends State<ManageLabTestsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void _addLabTest(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String testName = '';
//         double price = 0.0;
//         String department = '';
//         String testType = '';

//         return AlertDialog(
//           title: Text("Add Lab Test"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: "Test Name"),
//                   onChanged: (value) => testName = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Price"),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) => price = double.tryParse(value) ?? 0.0,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Department"),
//                   onChanged: (value) => department = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Test Type"),
//                   onChanged: (value) => testType = value,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (testName.isNotEmpty &&
//                     price > 0.0 &&
//                     department.isNotEmpty &&
//                     testType.isNotEmpty) {
//                   _firestore.collection('lab_tests').add({
//                     'name': testName,
//                     'price': price,
//                     'department': department,
//                     'test_type': testType,
//                   });
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text("Add"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _editLabTest(
//       BuildContext context, String testId, Map<String, dynamic> currentData) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String testName = currentData['name'] ?? '';
//         double price = currentData['price'] ?? 0.0;
//         String department = currentData['department'] ?? '';
//         String testType = currentData['test_type'] ?? '';

//         return AlertDialog(
//           title: Text("Edit Lab Test"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: "Test Name"),
//                   controller: TextEditingController(text: testName),
//                   onChanged: (value) => testName = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Price"),
//                   controller: TextEditingController(text: price.toString()),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) => price = double.tryParse(value) ?? 0.0,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Department"),
//                   controller: TextEditingController(text: department),
//                   onChanged: (value) => department = value,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: "Test Type"),
//                   controller: TextEditingController(text: testType),
//                   onChanged: (value) => testType = value,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (testName.isNotEmpty &&
//                     price > 0.0 &&
//                     department.isNotEmpty &&
//                     testType.isNotEmpty) {
//                   _firestore.collection('lab_tests').doc(testId).update({
//                     'name': testName,
//                     'price': price,
//                     'department': department,
//                     'test_type': testType,
//                   });
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteLabTest(String testId) {
//     _firestore.collection('lab_tests').doc(testId).delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Manage Lab Tests"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => _addLabTest(context),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('lab_tests').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No lab tests found."));
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               final labTest = doc.data() as Map<String, dynamic>;
//               return ListTile(
//                 title: Text(labTest['name']),
//                 subtitle: Text(
//                     "Price: ${labTest['price']} | Department: ${labTest['department']} | Type: ${labTest['test_type']}"),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () => _editLabTest(context, doc.id, labTest),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteLabTest(doc.id),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
