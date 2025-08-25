// lib/services/firebase_service.dart

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref('user');

  FirebaseService();

  Stream<Map<String, dynamic>?> getUserStream() {
    return _userRef.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final value = event.snapshot.value;
        if (value is Map) {
          final jsonString = jsonEncode(value);
          return jsonDecode(jsonString) as Map<String, dynamic>;
        }
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final snapshot = await _userRef.get();
    if (snapshot.exists && snapshot.value != null) {
      final value = snapshot.value;
      if (value is Map) {
        final jsonString = jsonEncode(value);
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<void> createInitialUserData(String name) {
    return _userRef.set({
      'profile': {'name': name, 'age': 0, 'sex': 'N/A'},
      'emergencyContacts': {},
      'location': {
        'address': 'Unknown',
        'latitude': 0.0,
        'longitude': 0.0,
        'isPressed': false
      },
      'sensor': {
        'heartrate': {'bpm': 0, 'oxygen': 0, 'lastUpdated': ''}
      },
      'motion': {'fallDetected': false, 'lastUpdated': ''},
      'sos': {'active': false, 'lastUpdated': ''}
    });
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) {
    return _userRef.child('profile').update(profileData);
  }

  Future<void> updateUserLocation(Map<String, dynamic> locationData) {
    return _userRef.child('location').update(locationData);
  }

  // --- Start of modified section ---
  /// Adds a new emergency contact with a sequential key like 'contact1', 'contact2', etc.
  Future<void> addEmergencyContact(Map<String, dynamic> contactData) async { // MODIFIED: Added 'async'
    final contactsRef = _userRef.child('emergencyContacts');

    // Step 1: Get the current contacts to determine the next index.
    final snapshot = await contactsRef.get();
    int nextId = 1; // Default to 1 if no contacts exist

    if (snapshot.exists && snapshot.value != null) {
      final value = snapshot.value;
      if (value is Map) {
        // Ensure the map is correctly typed for key iteration
        final contacts = Map<String, dynamic>.from(value);
        int maxId = 0;

        // Find the highest existing contact number (e.g., the '3' from 'contact3')
        for (var key in contacts.keys) {
          if (key.startsWith('contact')) {
            final numberPart = key.substring('contact'.length);
            final id = int.tryParse(numberPart);
            if (id != null && id > maxId) {
              maxId = id;
            }
          }
        }
        nextId = maxId + 1;
      }
    }

    // Step 2: Create the new key (e.g., 'contact1', 'contact2').
    final String newKey = 'contact$nextId';

    // Step 3: Set the new contact data at the generated key.
    await contactsRef.child(newKey).set(contactData);
  }
  // --- End of modified section ---

  Future<void> updateEmergencyContact(String key, Map<String, dynamic> contactData) {
    return _userRef.child('emergencyContacts/$key').update(contactData);
  }

  Future<void> removeEmergencyContact(String key) {
    return _userRef.child('emergencyContacts/$key').remove();
  }
}