import 'package:doctor_app/booking_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  final String userId; // Pass the logged-in user ID

  const DashboardPage({required this.userId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text("Your Bookings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BookingList(userId: widget.userId, status: "upcoming"),
          BookingList(userId: widget.userId, status: "past"),
        ],
      ),
    );
  }
}
