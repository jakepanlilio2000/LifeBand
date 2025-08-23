import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, dynamic>?> getUserStream() {
    return _dbRef.child('user').onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
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
}