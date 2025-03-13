import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/admin_panel.dart';
import 'package:doctor_app/ambulance_service_page.dart';
import 'package:doctor_app/all_bookings_page.dart';
import 'package:doctor_app/bookings_menu_page.dart';
import 'package:doctor_app/doctor_appointment_page.dart';
// import 'package:doctor_app/doctorcard.dart';
import 'package:doctor_app/emergency.dart';
import 'package:doctor_app/hospital_admission_page.dart';
import 'package:doctor_app/lab_test_page.dart';
import 'package:doctor_app/locationservices.dart';
import 'package:doctor_app/map_page.dart';
import 'package:doctor_app/notification_page.dart';
import 'package:doctor_app/profile.dart';
import 'package:doctor_app/radiology_investigation_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:doctor_app/service_page.dart';
import 'package:doctor_app/universal_search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final String username;
  final String userId;
  const Homepage({required this.username, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool hasUnseenNotifications = false;

  int _currentIndex = 0;
  String _location = "Fetching location...";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var db = FirebaseFirestore.instance;

  String username = "User";
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> popularItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEmergencyAlert();
    });
    _fetchUserDetails();
    _fetchServices();
    _fetchPopularItems();
    _loadLocation();
    _fetchUnseenNotifications();
    _addNotification;
  }

  //add notification
  void _addNotification(String userId, String message) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId, // The user who should see the notification
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false // Mark as unseen initially
    });
  }

  //add notification

  //Fetch Notification
  Future<void> _fetchUnseenNotifications() async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: widget.userId)
        .where('seen', isEqualTo: false) // Fetch only unseen notifications
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        hasUnseenNotifications = true; // Show red dot
      });
    }
  }
  //Fetch Notification

  //Mark Notification unseen
  Future<void> _markNotificationsAsSeen() async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: widget.userId)
        .where('seen', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await _firestore
          .collection('notifications')
          .doc(doc.id)
          .update({'seen': true});
    }

    setState(() {
      hasUnseenNotifications = false; // Remove red dot
    });
  }

  //Mark Notification unseen

  //Emergency Alert
  void _showEmergencyAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Emergency Alert",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Do you need any emergency service?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog and allow normal use
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Green button for "No"
              ),
              child: const Text("No", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EmergencyPage()), // Navigate to emergency page
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red button for "Yes"
              ),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  //Emergency Alert

  // Fetch user's location

  // void _loadLocation() async {
  //   String location = await LocationService.getUserLocation();
  //   setState(() {
  //     _location = location;
  //   });
  // }
  void _loadLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = "Location services are disabled";
      });
      return;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = "Location permissions are permanently denied";
      });
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Get place name
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      setState(() {
        _location = "${place.locality}, ${place.administrativeArea}";
      });
    } else {
      setState(() {
        _location = "Unknown location";
      });
    }
  }

  // Fetch user's location
  Future<void> _fetchUserDetails() async {
    final userDoc =
        await _firestore.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      setState(() {
        username = userDoc.data()?['name'] ?? "User";
      });
    }
  }

  Future<void> _fetchServices() async {
    final servicesSnapshot = await _firestore.collection('services').get();
    setState(() {
      services = servicesSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _fetchPopularItems() async {
    final popularSnapshot = await _firestore.collection('popular_items').get();
    setState(() {
      popularItems = popularSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, ${widget.username}"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NotificationsPage(userId: widget.userId)),
                  );
                  _markNotificationsAsSeen();
                },
              ),
              if (hasUnseenNotifications) // Show red dot only if there are unseen notifications
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(
                            username: 'User',
                            userId: widget.userId,
                          )));

              // print(_firestore.collection('users').get());
              // try {
              //   final snapshot =
              //       await FirebaseFirestore.instance.collection('users').get();
              //   snapshot.docs.forEach((doc) {
              //     print(doc.data());
              //   });
              // } catch (e) {
              //   print('Error: $e');
              // }

              // Navigate to Profile Page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Section
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 8),
                  // Text("Your Location", style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      _location,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow:
                          TextOverflow.ellipsis, // Prevents overflow issues
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _loadLocation, // Refresh location on click
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage()),
                      );

                      if (result != null) {
                        setState(() {
                          _location = result;
                        });
                      }
                    },
                    child: Text("Change"),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Search Bar
              TextField(
                readOnly: true, // So user taps instead of typing directly
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UniversalSearchPage()),
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search doctors, labs...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Services Section
              Text("Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: NeverScrollableScrollPhysics(),
                children: services.map((service) {
                  return _buildServiceTile(
                      service['title'],
                      IconData(int.parse(service['icon']),
                          fontFamily: 'MaterialIcons'),
                      Color(int.parse(service['color'])));
                }).toList(),
                // [
                //   _buildServiceTile(
                //       "Doctor Appointment", Icons.local_hospital, Colors.blue),
                //   _buildServiceTile("Hospital Admission",
                //       Icons.medical_services, Colors.green),
                //   _buildServiceTile("Lab Test", Icons.science, Colors.orange),
                //   _buildServiceTile("Radiology Investigation",
                //       Icons.radio_outlined, Colors.purple),
                //   _buildServiceTile("Ambulance Service",
                //       Icons.car_crash_outlined, Colors.red),
                // ],
              ),
              SizedBox(
                height: 20,
              ),
              // Text("Popular Doctors",
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // SizedBox(height: 10),

              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(children: [
              //     DoctorCard(),
              //   ]),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // Popular Section
              // Text("Popular Near You",
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // // SizedBox(height: 10),
              // ListView(
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   children: popularItems.map((item) {
              //     return _buildPopularItem(
              //         item['name'], item['distance'], Icons.location_city);
              //   }).toList(),
              //   // [
              //   //   _buildPopularItem(
              //   //       "City Hospital", "5 km away", Icons.local_hospital),
              //   //   _buildPopularItem(
              //   //       "LabCare Diagnostics", "3 km away", Icons.science),
              //   // ],
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Bookings",
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.phone),
              label: "Call to Book",
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Your Appointments",
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "About",
              backgroundColor: Colors.red),
        ],
        onTap: (index) {
          print(index);
          setState(() {
            _currentIndex = index; // Update the current index
          });

          // Handle navigation based on index
          if (index == 3) {
            User? user = FirebaseAuth.instance.currentUser;
            // if (user != null) {
            String userId = '1';
            // user.uid;
            // Navigate to the Bookings Page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardPage(
                        userId: userId,
                      )),
            );
            // }
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserBookingsPage(
                        userId: '1',
                      )),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminPanel()),
            );
          }
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildServiceTile(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        print(title);
        if (title == 'Doctor Appointment') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DoctorAppointmentPage()));
        } else if (title == 'Hospital Admission') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HospitalAdmissionPage()));
        } else if (title == 'Lab Test') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LabTestPage()));
        } else if (title == 'Ambulance Service') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AmbulanceServicePage()));
        } else if (title == 'Radiology investigation') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RadiologyInvestigationPage()));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServicePage(title: title),
            ),
          );
        }

        // Navigate to respective service page
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItem(String name, String distance, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(name),
      subtitle: Text(distance),
      onTap: () {
        // Navigate to item details
      },
    );
  }
}
