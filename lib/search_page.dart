import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_details_page.dart';
import 'lab_info_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
    query = query.toLowerCase();

    List<Map<String, dynamic>> results = [];

    // Fetch doctors
    final doctorsSnapshot = await _firestore.collection('doctors').get();
    results.addAll(doctorsSnapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data['name'].toLowerCase().contains(query)) {
            data['type'] = 'doctor';
            data['id'] = doc.id;
            return data;
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList());

    // Fetch lab tests
    final labTestsSnapshot = await _firestore.collection('lab_tests').get();
    results.addAll(labTestsSnapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data['name'].toLowerCase().contains(query)) {
            data['type'] = 'lab_test';
            data['id'] = doc.id;
            return data;
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList());

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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                              } else {
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
