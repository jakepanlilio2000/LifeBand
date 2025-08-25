import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/providers/providers.dart';
import 'package:lifeband/screen/home_screen.dart';
import 'package:lifeband/screen/login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the authentication state
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        // If user is logged in, show HomeScreen
        if (user != null) {
          return const HomeScreen();
        }
        // If user is logged out, show LoginScreen
        return const LoginScreen();
      },
      // Show a loading indicator while checking auth state
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      // Show an error message if something goes wrong
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Something went wrong: $error'),
        ),
      ),
    );
  }
}