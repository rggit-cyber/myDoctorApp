import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_details_page.dart';
import 'lab_info_page.dart';

class UniversalSearchPage extends StatefulWidget {
  @override
  _UniversalSearchPageState createState() => _UniversalSearchPageState();
}

class _UniversalSearchPageState extends State<UniversalSearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults.clear());
      return;
    }

    setState(() => isLoading = true);

    List<Map<String, dynamic>> results = [];
    String searchQuery = query.toLowerCase();

    try {
      // Fetch doctors
      final doctorsSnapshot = await _firestore.collection('doctors').get();
      results.addAll(doctorsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            data['type'] = 'doctor';
            return data;
          })
          .where((doc) =>
              doc['name'].toString().toLowerCase().contains(searchQuery))
          .toList());

      // Fetch lab tests
      final labTestsSnapshot = await _firestore.collection('lab_tests').get();
      results.addAll(labTestsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            data['type'] = 'lab_test';
            return data;
          })
          .where((doc) =>
              doc['name'].toString().toLowerCase().contains(searchQuery))
          .toList());
    } catch (e) {
      print("Error fetching search results: $e");
    }

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for doctors or lab tests...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? Center(child: Text("No results found"))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final result = searchResults[index];
                          return ListTile(
                            title: Text(result['name']),
                            subtitle: Text(result['type'] == 'doctor'
                                ? "Specialization: ${result['specialization']}"
                                : "Category: ${result['category']}"),
                            onTap: () {
                              if (result['type'] == 'doctor') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorDetailsPage(
                                        doctorId: result['id']),
                                  ),
                                );
                              } else if (result['type'] == 'lab_test') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LabListPage(testName: result['name']),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
