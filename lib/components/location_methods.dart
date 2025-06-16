import 'package:geolocator/geolocator.dart';

class LocationMethods{
  static Future<Position> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied. Open settings.");
    }

    // Use the new settings parameter instead of deprecated desiredAccuracy
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high, // Same as before, but using new method
      ),
    );
    // print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    return position;
  }

}