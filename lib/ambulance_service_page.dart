// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AmbulanceServicePage extends StatefulWidget {
//   @override
//   _AmbulanceServicePageState createState() => _AmbulanceServicePageState();
// }

// class _AmbulanceServicePageState extends State<AmbulanceServicePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> ambulanceServices = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchAmbulanceServices();
//   }

//   Future<void> _fetchAmbulanceServices() async {
//     final ambulanceServicesSnapshot =
//         await _firestore.collection('ambulance_services').get();
//     setState(() {
//       ambulanceServices =
//           ambulanceServicesSnapshot.docs.map((doc) => doc.data()).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ambulance Services"),
//       ),
//       body: ListView.builder(
//         itemCount: ambulanceServices.length,
//         itemBuilder: (context, index) {
//           final service = ambulanceServices[index];
//           return ListTile(
//             leading: Icon(Icons.local_taxi),
//             title: Text(service['name']),
//             subtitle: Text("Contact: ${service['contact']}"),
//             onTap: () {
//               // Navigate to Ambulance Details or Request Page
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AmbulanceServicePage extends StatefulWidget {
//   @override
//   _AmbulanceServicePageState createState() => _AmbulanceServicePageState();
// }

// class _AmbulanceServicePageState extends State<AmbulanceServicePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Ambulance Services")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('ambulance_services').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No ambulance services available."));
//           }

//           return GridView.builder(
//             padding: EdgeInsets.all(10),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 1.2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final service = snapshot.data!.docs[index].data() as Map<String, dynamic>;

//               String name = service['name'] ?? "Unknown Service";
//               String description = service['description'] ?? "No description available";
//               String iconUrl = service['icon_url'] ?? "https://via.placeholder.com/100";

//               return Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 elevation: 3,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.network(iconUrl, height: 50, errorBuilder: (context, error, stackTrace) {
//                       return Icon(Icons.error, size: 50);
//                     }),
//                     SizedBox(height: 10),
//                     Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
//                     SizedBox(height: 5),
//                     Text(description, textAlign: TextAlign.center),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AmbulanceServicePage extends StatefulWidget {
  @override
  _AmbulanceServicePageState createState() => _AmbulanceServicePageState();
}

class _AmbulanceServicePageState extends State<AmbulanceServicePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ambulance Services")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('ambulances').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No ambulance services available."));
          }

          var ambulanceList = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // ✅ 2 columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // ✅ Allow better height adjustment
                  ),
                  itemCount: ambulanceList.length,
                  itemBuilder: (context, index) {
                    final service =
                        ambulanceList[index].data() as Map<String, dynamic>;

                    String name = service['name'] ?? "Unknown Service";
                    String description =
                        service['subheading'] ?? "No description available";
                    String type = service['type'] ?? "Type not specified";
                    double pricePerKm = service['price_per_km'] ?? 0.0;
                    bool availability = service['availability'] ?? true;
                    String iconUrl = service.containsKey('icon_url')
                        ? service['icon_url']
                        : "https://via.placeholder.com/100";

                    return IntrinsicHeight(
                      // ✅ Make all cards the same height
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.network(
                                iconUrl,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error, size: 50);
                                },
                              ),
                              SizedBox(height: 10),
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Expanded(
                                // ✅ Ensures text expands properly
                                child: Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("Type: $type"),
                              Text("Price: ₹$pricePerKm/km"),
                              SizedBox(height: 5),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  availability ? "Available" : "Not Available",
                                  style: TextStyle(
                                      color: availability
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
