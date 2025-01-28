import 'package:doctor_app/manage_ambulance_page.dart';
import 'package:doctor_app/manage_lab_tests_page.dart';
import 'package:doctor_app/manage_labs_page.dart';
import 'package:flutter/material.dart';
import 'manage_doctors_page.dart';
import 'manage_bookings_page.dart';
import 'manage_hospitals_page.dart';
// import 'manage_tests_page.dart';
// import 'manage_labs_page.dart';
// import 'manage_ambulance_page.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: "Doctors"),
            Tab(text: "Bookings"),
            Tab(text: "Hospitals"),
            Tab(text: "Tests"),
            Tab(text: "Labs"),
            Tab(text: "Ambulance"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ManageDoctorsPage(),
          ManageBookingsPage(),
          ManageHospitalsPage(),
          ManageLabTestsPage(),
          ManageLabsPage(),
          ManageAmbulancePage(),
        ],
      ),
    );
  }
}
