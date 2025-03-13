import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_details_page.dart';
import 'universal_search_page.dart'; // Import Universal Search Page

class DoctorAppointmentPage extends StatefulWidget {
  @override
  _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> doctors = [];
  List<String> specializations = [];
  bool isLoading = true;
  String? selectedSpecialization; // Selected specialization for filtering

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchSpecializations(); // Fetch specializations from Firestore
  }

  // Fetch doctors from Firestore (with optional filtering)
  Future<void> _fetchDoctors({String? specialization}) async {
    try {
      Query query = _firestore.collection('doctors');

      // Apply filter if a specialization is selected
      if (specialization != null && specialization != "All") {
        query = query.where('specialization', isEqualTo: specialization);
      }

      final doctorsSnapshot = await query.get();
      setState(() {
        doctors = doctorsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
      setState(() => isLoading = false);
    }
  }

  // Fetch unique specializations from Firestore
  Future<void> _fetchSpecializations() async {
    try {
      final doctorsSnapshot = await _firestore.collection('doctors').get();
      final Set<String> fetchedSpecializations = {
        "All"
      }; // Include "All" option

      for (var doc in doctorsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('specialization')) {
          fetchedSpecializations.add(data['specialization']);
        }
      }

      setState(() {
        specializations = fetchedSpecializations.toList();
      });
    } catch (e) {
      print("Error fetching specializations: $e");
    }
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filter by Specialization"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: specializations.map((specialization) {
              return ListTile(
                title: Text(specialization),
                leading: Radio<String>(
                  value: specialization,
                  groupValue: selectedSpecialization,
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialization = value;
                      _fetchDoctors(specialization: value); // Filter doctors
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Appointments"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar and Filter Button (Side by Side)
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UniversalSearchPage()),
                      );
                    },
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "Search for doctors...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
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

          // Display Doctors List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                    ? Center(child: Text("No doctors available"))
                    : ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: doctor['imageUrl'] != null &&
                                        doctor['imageUrl'].isNotEmpty
                                    ? NetworkImage(doctor['imageUrl'])
                                    : AssetImage('images/default_doctor.png')
                                        as ImageProvider,
                              ),
                              title: Text(
                                doctor['name'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  "Specialization: ${doctor['specialization']}"),
                              trailing: Icon(Icons.arrow_forward_ios, size: 18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorDetailsPage(
                                      doctorId: doctor['id'],
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
