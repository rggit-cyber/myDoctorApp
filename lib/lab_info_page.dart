// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:doctor_app/lab_slot_selection_page.dart';
// import 'package:flutter/material.dart';

// class LabListPage extends StatelessWidget {
//   final String testId = "1";
//   final String testName;

//   LabListPage({required this.testName});

//   @override
//   Widget build(BuildContext context) {
//     print("testname" + testName);
//     return Scaffold(
//       appBar: AppBar(title: Text("$testName - Labs")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('labs')
//             .where('available_tests', arrayContains: testName)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//           print(snapshot.data?.docs);
//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               final lab = doc.data() as Map<String, dynamic>;
//               print("Lab data $lab");
//               print("doc " + doc.id);
//               print("testId" + testId);
//               return ListTile(
//                 title: Text(lab['name']),
//                 subtitle: Text("Price: ₹${lab['test_prices'][testName]}"),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SlotSelectionPage(
//                         labId: doc.id,
//                         labName: lab['name'] ?? 'Unknown Lab',
//                         testId: testId,
//                         testName: testName,
//                         price: (lab['test_prices']?[testName] ?? 0).toDouble(),
//                       ),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/lab_slot_selection_page.dart';
import 'package:flutter/material.dart';

class LabListPage extends StatefulWidget {
  final String testName;

  LabListPage({required this.testName});

  @override
  _LabListPageState createState() => _LabListPageState();
}

class _LabListPageState extends State<LabListPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> labs = [];
  List<Map<String, dynamic>> filteredLabs = [];

  @override
  void initState() {
    super.initState();
    _fetchLabs();
  }

  // Fetch labs offering the selected test
  Future<void> _fetchLabs() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('labs')
          .where('available_tests', arrayContains: widget.testName)
          .get();

      final fetchedLabs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        labs = fetchedLabs;
        filteredLabs = fetchedLabs; // Initially show all labs
      });
    } catch (e) {
      print("Error fetching labs: $e");
    }
  }

  // Search labs by name
  void _searchLabs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredLabs = labs;
      } else {
        filteredLabs = labs
            .where((lab) => lab['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.testName} - Labs")),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for labs...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchLabs,
            ),
          ),

          // Lab List
          Expanded(
            child: filteredLabs.isEmpty
                ? Center(child: Text("No labs found"))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: filteredLabs.length,
                    itemBuilder: (context, index) {
                      final lab = filteredLabs[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                            lab['name'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "Price: ₹${lab['test_prices'][widget.testName] ?? 'N/A'}"),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SlotSelectionPage(
                                  labId: lab['id'],
                                  labName: lab['name'] ?? 'Unknown Lab',
                                  testId: "1", // You can adjust this if needed
                                  testName: widget.testName,
                                  price: (lab['test_prices']
                                              ?[widget.testName] ??
                                          0)
                                      .toDouble(),
                                ),
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
