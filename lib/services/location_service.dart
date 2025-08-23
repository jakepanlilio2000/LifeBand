import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifeband/services/firebase_service.dart';

class LocationService {
  final FirebaseService _firebaseService;

  LocationService(this._firebaseService);

  // This method remains for updating both coordinates and address
  Future<void> updateLocation() async {
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
        await _firebaseService.updateUserLocation(position.latitude, position.longitude, address);
      }
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  // --- ADD THIS NEW METHOD ---
  // This method updates only the address from existing coordinates.
  Future<void> updateAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
        // Call the new Firebase service method
        await _firebaseService.updateUserAddress(address);
      }
    } catch (e) {
      print("Error updating address from coordinates: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}