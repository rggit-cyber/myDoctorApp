import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get user's latitude & longitude
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Convert latitude & longitude to an address (City, Country)
  static Future<String> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      return "${place.locality}, ${place.country}"; // Example: "Bhubaneswar, India"
    } catch (e) {
      return "Address not found";
    }
  }

  // Fetch location and return address
  static Future<String> getUserLocation() async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      return await getAddressFromCoordinates(position);
    }
    return "Location unavailable";
  }
}
