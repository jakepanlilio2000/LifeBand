import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_model.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
void firebaseListenerBackgroundHandler() async {
  // It is crucial to initialize Firebase here for background tasks
  // as the app might be in a killed state.
  await Firebase.initializeApp();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications for the background handler
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await _localNotifications.initialize(initializationSettings);

  _databaseReference.child('user/motion/fallDetected').onValue.listen((event) async {
    final isFallDetected = event.snapshot.value as bool? ?? false;
    if (isFallDetected) {
      await _showFallNotification();
    }
  });
}

Future<void> _showFallNotification() async {
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _audioPlayer = AudioPlayer();

  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'fall_alert_channel',
    'Fall Alerts',
    channelDescription: 'Notifications for detected falls.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    sound: RawResourceAndroidNotificationSound('alert_sound'), // Set custom sound here
  );
  const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await _localNotifications.show(
    0,
    'Fall Detected!',
    'An emergency fall has been detected.',
    platformChannelSpecifics,
  );

  await _audioPlayer.play(AssetSource('sounds/alert_sound.mp3'));
}

class FirebaseService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _audioPlayer = AudioPlayer();

  FirebaseService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    _localNotifications.initialize(initializationSettings);
  }

  Stream<UserModel> getUserData() {
    return _databaseReference.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return UserModel.fromMap(data);
    });
  }

  Future<void> toggleSos(bool currentStatus) async {
    try {
      await _databaseReference.child('user/sos/active').set(!currentStatus);
      await _databaseReference.child('user/sos/lastUpdated').set(DateTime.now().toIso8601String());
    } catch (e) {
      print("Error toggling SOS: $e");
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> showFallNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fall_alert_channel',
      'Fall Alerts',
      channelDescription: 'Notifications for detected falls.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0, // Notification ID
      'Fall Detected!',
      'An emergency fall has been detected.',
      platformChannelSpecifics,
    );

    // Play a sound
    _audioPlayer.play(AssetSource('sounds/alert_sound.mp3')); // Make sure to add alert_sound.mp3 to your assets
  }
  void startFallDetectionListener() {
    _databaseReference.child('user/motion/fallDetected').onValue.listen((event) {
      final isFallDetected = event.snapshot.value as bool? ?? false;
      if (isFallDetected) {
        showFallNotification();
      }
    });
  }
  Future<void> updateWristbandProfile(String name, int age, String sex) async {
    try {
      await _databaseReference.child('user/profile').update({
        'name': name,
        'age': age,
        'sex': sex,
      });
      print("Wristband user profile updated successfully.");
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // Modified method to update location with the address
  Future<void> updateLocationInFirebase(Position position) async {
    try {
      // Perform reverse geocoding
      String addressString = 'N/A';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          addressString = "${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
        }
      } catch (e) {
        print("Could not find address from coordinates: $e");
      }

      // Update both coordinates and the address in Firebase
      await _databaseReference.child('user/location').update({
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'address': addressString,
      });

    } catch (e) {
      print("Error updating location in Firebase: $e");
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<void> updateEmergencyContact(String name, int phone) async {
    try {
      await _databaseReference.child('user/emergencyContact/contact').update({
        'name': name,
        'phone': phone,
      });
      print("Emergency contact updated successfully.");
    } catch (e) {
      print("Error updating emergency contact: $e");
    }
  }
}