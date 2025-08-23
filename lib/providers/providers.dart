import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/services/firebase_service.dart';
import 'package:lifeband/services/location_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final userStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(firebaseServiceProvider).getUserStream();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return LocationService(firebaseService);
});