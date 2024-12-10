import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final String username;
  const Homepage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, $username"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to Notifications Page
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
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
                  Text("Your Location", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Trigger location permission and fetch location
                    },
                    child: Text("Change"),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Search for services, doctors, tests...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                children: [
                  _buildServiceTile(
                      "Doctor Appointment", Icons.local_hospital, Colors.blue),
                  _buildServiceTile("Hospital Admission",
                      Icons.medical_services, Colors.green),
                  _buildServiceTile("Lab Test", Icons.science, Colors.orange),
                  _buildServiceTile("Radiology Investigation",
                      Icons.radio_outlined, Colors.purple),
                  _buildServiceTile("Ambulance Service",
                      Icons.car_crash_outlined, Colors.red),
                ],
              ),
              SizedBox(height: 20),

              // Popular Section
              Text("Popular Near You",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildPopularItem(
                      "City Hospital", "5 km away", Icons.local_hospital),
                  _buildPopularItem(
                      "LabCare Diagnostics", "3 km away", Icons.science),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.phone), label: "Call to Book"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Your Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildServiceTile(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
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
