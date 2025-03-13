// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   MapLibreMapController? mapController;
//   LatLng? selectedLocation;
//   String selectedAddress = "Select a location";
//   TextEditingController searchController = TextEditingController();
//   List<LatLng> polygonPoints = [];

//   void _onMapCreated(MapLibreMapController controller) {
//     setState(() {
//       mapController = controller;
//     });
//   }

//   Future<void> _fetchCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Location permission denied")),
//           );
//         }
//         return;
//       }
//     }

//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     LatLng newLocation = LatLng(position.latitude, position.longitude);

//     if (mounted) {
//       setState(() {
//         selectedLocation = newLocation;
//       });
//     }

//     mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));

//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//     if (placemarks.isNotEmpty && mounted) {
//       setState(() {
//         selectedAddress =
//             "${placemarks[0].locality}, ${placemarks[0].administrativeArea}";
//       });
//     }
//   }

//   void _onMapTapped(LatLng latLng) async {
//     setState(() {
//       selectedLocation = latLng;
//     });

//     // Remove previous markers before adding a new one
//     mapController?.clearSymbols();

//     mapController?.addSymbol(
//       SymbolOptions(
//         geometry: latLng,
//         iconImage: "marker-15",
//         iconSize: 1.5,
//       ),
//     );

//     // Fetch the location name
//     String placeName = await _getPlaceName(latLng);
//     setState(() {
//       selectedAddress = placeName;
//     });
//   }

//   Future<String> _getPlaceName(LatLng latLng) async {
//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;

//         // Extract meaningful location name
//         String landmark = place.name ?? "";
//         String area = place.subLocality ?? "";
//         String city = place.locality ?? "";
//         String state = place.administrativeArea ?? "";

//         // Return the most specific and relevant address
//         if (landmark.isNotEmpty && area.isNotEmpty) {
//           return "$landmark, $area";
//         } else if (landmark.isNotEmpty) {
//           return landmark;
//         } else if (area.isNotEmpty) {
//           return area;
//         } else if (city.isNotEmpty) {
//           return city;
//         } else {
//           return state; // Fallback in case all are empty
//         }
//       }
//     } catch (e) {
//       print("Error getting place name: $e");
//     }
//     return "Unknown Location";
//   }

//   Future<void> _searchLocation() async {
//     String query = searchController.text;
//     if (query.isEmpty) return;

//     try {
//       List<Location> locations = await locationFromAddress(query);
//       if (locations.isNotEmpty) {
//         LatLng newLocation =
//             LatLng(locations[0].latitude, locations[0].longitude);

//         setState(() {
//           selectedLocation = newLocation;
//           selectedAddress = query;
//           _highlightArea(newLocation);
//         });

//         mapController
//             ?.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 14));

//         // Add marker for searched location
//         mapController?.clearSymbols();
//         mapController?.addSymbol(
//           SymbolOptions(
//             geometry: newLocation,
//             iconImage: "marker-15",
//             iconSize: 1.5,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Location not found")),
//         );
//       }
//     } catch (e) {
//       print("Error searching location: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error finding location")),
//       );
//     }
//   }

//   void _highlightArea(LatLng center) {
//     setState(() {
//       polygonPoints = [
//         LatLng(center.latitude + 0.01, center.longitude - 0.01),
//         LatLng(center.latitude + 0.01, center.longitude + 0.01),
//         LatLng(center.latitude - 0.01, center.longitude + 0.01),
//         LatLng(center.latitude - 0.01, center.longitude - 0.01),
//         LatLng(center.latitude + 0.01, center.longitude - 0.01),
//       ];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Location")),
//       body: Stack(
//         children: [
//           MapLibreMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: LatLng(20.8466, 85.1511), // Angul coordinates
//               zoom: 12,
//             ),
//             compassEnabled: false,
//             onMapClick: (point, latLng) => _onMapTapped(latLng),
//             styleString:
//                 "https://api.maptiler.com/maps/streets/style.json?key=EFJgnvFlvt8EChkRTBG9",
//           ),
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black26, blurRadius: 5)
//                       ],
//                     ),
//                     child: TextField(
//                       controller: searchController,
//                       decoration: InputDecoration(
//                         hintText: "Search location",
//                         prefixIcon: Icon(Icons.search),
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.search, color: Colors.blue),
//                   onPressed: _searchLocation,
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 80,
//             right: 10,
//             child: FloatingActionButton(
//               onPressed: _fetchCurrentLocation,
//               child: Icon(Icons.my_location),
//               backgroundColor: Colors.blue,
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: () {
//                 if (selectedLocation != null) {
//                   Navigator.pop(context, selectedAddress);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Please select a location first")),
//                   );
//                 }
//               },
//               child: Text("Confirm Location: $selectedAddress"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  LatLng? selectedLocation;
  String selectedAddress = "Select a location";
  TextEditingController searchController = TextEditingController();
  List<Marker> placeMarkers = [];

  Future<void> _fetchCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng newLocation = LatLng(position.latitude, position.longitude);
    String placeName = await _getPlaceName(newLocation);

    setState(() {
      selectedLocation = newLocation;
      selectedAddress = placeName;
    });

    mapController.move(newLocation, 15);
    _fetchNearbyPlaces(newLocation);
  }

  void _onMapTapped(LatLng latLng) async {
    setState(() {
      selectedLocation = latLng;
    });

    String placeName = await _getPlaceName(latLng);
    setState(() {
      selectedAddress = placeName;
    });

    _fetchNearbyPlaces(latLng);
  }

  Future<String> _getPlaceName(LatLng latLng) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('display_name')) {
          return data['display_name'];
        }
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
    return "Unknown Location";
  }

  void _searchLocation() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);

          LatLng newLocation = LatLng(lat, lon);
          String placeName = data[0]['display_name'];

          setState(() {
            selectedLocation = newLocation;
            selectedAddress = placeName;
          });

          mapController.move(newLocation, 15);
          _fetchNearbyPlaces(newLocation);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location not found")),
          );
        }
      }
    } catch (e) {
      print("Error searching location: $e");
    }
  }

  Future<void> _fetchNearbyPlaces(LatLng latLng) async {
    final overpassUrl = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=[out:json];(node["amenity"="hospital"](around:5000,${latLng.latitude},${latLng.longitude});node["amenity"="clinic"](around:5000,${latLng.latitude},${latLng.longitude});node["amenity"="pharmacy"](around:5000,${latLng.latitude},${latLng.longitude}););out;');

    try {
      final response = await http.get(overpassUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Marker> markers = [];

        for (var element in data['elements']) {
          if (element['lat'] != null && element['lon'] != null) {
            markers.add(
              Marker(
                point: LatLng(element['lat'], element['lon']),
                width: 30.0,
                height: 30.0,
                child: Icon(
                  Icons.local_hospital,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            );
          }
        }

        setState(() {
          placeMarkers = markers;
        });
      }
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(20.8466, 85.1511),
              initialZoom: 12,
              onTap: (tapPosition, latLng) {
                _onMapTapped(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                      if (selectedLocation != null)
                        Marker(
                          point: selectedLocation!,
                          width: 40.0,
                          height: 40.0,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                    ] +
                    placeMarkers,
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search location",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.blue),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton(
              onPressed: _fetchCurrentLocation,
              child: Icon(Icons.my_location),
              backgroundColor: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: selectedLocation != null
                  ? () {
                      Navigator.pop(context, selectedAddress);
                    }
                  : null,
              child: Text(selectedLocation != null
                  ? "Confirm Location: $selectedAddress"
                  : "Select a Location First"),
            ),
          ),
        ],
      ),
    );
  }
}
