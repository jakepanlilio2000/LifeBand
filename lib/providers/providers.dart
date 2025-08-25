// lib/providers/providers.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/services/auth_service.dart';
import 'package:lifeband/services/firebase_service.dart';
import 'package:lifeband/services/location_service.dart';

// Provider for the authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider that listens to authentication state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// The FirebaseService provider now creates a single, global instance.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// The user data stream now directly watches the global firebaseServiceProvider.
final userStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(firebaseServiceProvider).getUserStream();
});

// The location service provider gets the single instance of FirebaseService.
final locationServiceProvider = Provider<LocationService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return LocationService(firebaseService);
});