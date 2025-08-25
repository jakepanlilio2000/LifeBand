// lib/services/location_service.dart

import 'package:geocoding/geocoding.dart';
import 'package:lifeband/services/firebase_service.dart';

class LocationService {
  final FirebaseService _firebaseService;

  LocationService(this._firebaseService);

  Future<void> updateAddressFromCoordinates(double lat, double lng) async {
    try {
      // **MODIFIED:** The 'localeIdentifier' parameter has been removed.
      // The geocoding package will use the device's default locale.
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = '${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}';

        await _firebaseService.updateUserLocation({'address': address});
      }
    } catch (e) {
      await _firebaseService.updateUserLocation({'address': 'Could not get address'});
    }
  }
}