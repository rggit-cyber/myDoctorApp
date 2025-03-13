import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lab_info_page.dart';

class LabTestPage extends StatefulWidget {
  @override
  _LabTestPageState createState() => _LabTestPageState();
}

class _LabTestPageState extends State<LabTestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  String? selectedTestType;
  List<Map<String, dynamic>> labTests = [];
  List<String> testTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchTestTypes();
    _fetchLabTests();
  }

  // Fetch lab tests with optional filtering
  Future<void> _fetchLabTests({String? testType}) async {
    Query query = _firestore.collection('lab_tests');

    if (testType != null && testType != "All") {
      query = query.where('test_type', isEqualTo: testType);
    }

    final snapshot = await query.get();
    setState(() {
      labTests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['test_type'] =
            data['test_type'] ?? "Unknown"; // Ensure test_type is not null
        return data;
      }).toList();
    });
  }

  // Fetch unique test types from Firestore
  Future<void> _fetchTestTypes() async {
    final snapshot = await _firestore.collection('lab_tests').get();
    final Set<String> fetchedTestTypes = {"All"};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String testType = data['test_type'] ?? "Unknown";
      fetchedTestTypes.add(testType);
    }

    setState(() {
      testTypes = fetchedTestTypes.toList();
    });
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filter by Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: testTypes.map((testType) {
              return ListTile(
                title: Text(testType),
                leading: Radio<String>(
                  value: testType,
                  groupValue: selectedTestType,
                  onChanged: (value) {
                    setState(() {
                      selectedTestType = value;
                      _fetchLabTests(testType: value);
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Perform search function
  void _performSearch(String query) {
    if (query.isEmpty) {
      _fetchLabTests(testType: selectedTestType);
      return;
    }

    setState(() {
      labTests = labTests
          .where((test) => test['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab Tests"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar and Filter Button Side by Side
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search for lab tests...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _performSearch,
                  ),
                ),
                SizedBox(width: 10),
                // Filter Button
                IconButton(
                  icon: Icon(Icons.filter_list, size: 28),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),

          // Lab Test List
          Expanded(
            child: labTests.isEmpty
                ? Center(child: Text("No lab tests available"))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: labTests.length,
                    itemBuilder: (context, index) {
                      final test = labTests[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                            test['name'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Category: ${test['test_type']}"),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LabListPage(testName: test['name']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// import 'package:doctor_app/lab_info_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LabTestPage extends StatelessWidget {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void _showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Filter Lab Tests"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Add filter options here
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Apply filters
//                 Navigator.pop(context);
//               },
//               child: Text("Apply"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Lab Tests"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list),
//             onPressed: () => _showFilterDialog(context),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('lab_tests').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               final labTest = doc.data() as Map<String, dynamic>;
//               return ListTile(
//                 title: Text(labTest['name']),
//                 subtitle: Text("Category: ${labTest['category']}"),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           LabListPage(testName: labTest['name']),
//                     ),
//                   );
//                 },
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
