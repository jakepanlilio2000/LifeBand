import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, dynamic>?> getUserStream() {
    return _dbRef.child('user').onValue.map((event) {
      if (event.snapshot.value != null) {
        final value = event.snapshot.value;
        if (value is Map) {
          return Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
        }
      }
      return null;
    });
  }

  // --- ADD THIS NEW METHOD ---
  // Performs a single, one-time fetch of the current user data.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final snapshot = await _dbRef.child('user').get();
    if (snapshot.exists && snapshot.value != null) {
      final value = snapshot.value;
      if (value is Map) {
        // Use the same robust conversion to prevent type errors
        return Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
      }
    }
    return null;
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) {
    return _dbRef.child('user/profile').update(profileData);
  }

  Future<void> updateEmergencyContact(Map<String, dynamic> contactData) {
    return _dbRef.child('user/emergencyContact/contact').update(contactData);
  }

  Future<void> updateUserLocation(double lat, double lng, String address) {
    return _dbRef.child('user/location').update({
      'latitude': lat,
      'longitude': lng,
      'address': address,
    });
  }

  Future<void> updateUserAddress(String address) {
    return _dbRef.child('user/location').update({'address': address});
  }
}