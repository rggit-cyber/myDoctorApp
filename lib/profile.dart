import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({required String username, required String userId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // User? currentUser;
  Map<String, dynamic>? userData;

  final userId = "Dn2C3sVCYtg6b5XYxxXD";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    // currentUser = _auth.currentUser;
  }

  /// Fetch user data from Firestore based on the logged-in user
  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    // if (currentUser == null) return null;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      // "Dn2C3sVCYtg6b5XYxxXD"

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
      print(userData);
      print(userDoc);

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return null;
  }

  /// Logout Function
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print("Logout error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body:
          // FutureBuilder<Map<String, dynamic>?>(
          // future: _fetchUserDetails(),
          // builder: (context, snapshot) {
          //   if (snapshot.connectionState == ConnectionState.waiting) {
          //     return Center(child: CircularProgressIndicator());
          //   }

          //   if (snapshot.hasError || snapshot.data == null) {
          //     return Center(child: Text("Failed to load user data."));
          //   }

          // userData = ;
          // return
          Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Info Section
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final nameController = TextEditingController(
                                    text: userData?['name']);
                                final phoneController = TextEditingController(
                                    text: userData?['phone']);
                                final emailController = TextEditingController(
                                    text: userData?['email']);
                                final ageController = TextEditingController(
                                    text: userData?['age']);
                                final criteriaController =
                                    TextEditingController(
                                        text: userData?['criteria']);

                                return AlertDialog(
                                  title: Text('Edit Profile'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                              labelText: 'Name'),
                                        ),
                                        TextField(
                                          controller: phoneController,
                                          decoration: InputDecoration(
                                              labelText: 'Phone'),
                                          keyboardType: TextInputType.phone,
                                        ),
                                        TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                              labelText: 'E-mail'),
                                          // keyboardType: TextInputType.phone,
                                        ),
                                        TextField(
                                          controller: ageController,
                                          decoration:
                                              InputDecoration(labelText: 'Age'),
                                          keyboardType: TextInputType.number,
                                        ),
                                        TextField(
                                          controller: criteriaController,
                                          decoration: InputDecoration(
                                              labelText: 'Criteria'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: Text('Save'),
                                      onPressed: () async {
                                        try {
                                          // Update the user data in Firestore
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userId)
                                              .update({
                                            'name': nameController.text,
                                            'phone': phoneController.text,
                                            'email': emailController.text,
                                            'age': ageController.text,
                                            'criteria': criteriaController.text,
                                          });

                                          // Update local userData
                                          setState(() {
                                            userData?['name'] =
                                                nameController.text;
                                            userData?['phone'] =
                                                phoneController.text;
                                            userData?['email'] =
                                                emailController.text;
                                            userData?['age'] =
                                                ageController.text;
                                            userData?['criteria'] =
                                                criteriaController.text;
                                          });
                                          print("userdata ${userData}");
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Profile updated successfully')),
                                          );
                                        } catch (e) {
                                          print('Error updating profile: $e');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to update profile')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Name'),
                        subtitle: Text(userData?['name'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('Contact Number'),
                        subtitle: Text(userData?['phone'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Email Address'),
                        subtitle: Text(userData?['email'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Age'),
                        subtitle: Text(userData?['age'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: Icon(Icons.health_and_safety),
                        title: Text('Criteria'),
                        subtitle: Text(userData?['criteria'] ?? 'N/A'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Logout Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Logout'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _logout();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
