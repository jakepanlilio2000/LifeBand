import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screen/edit_emergency_contact_screen.dart';
import '../screen/edit_profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeBand Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.contact_emergency),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditEmergencyContactScreen()),
              );
            },
          )
        ],
      ),
      body: userData.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data found.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(locationServiceProvider).updateLocation(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileCard(user['profile']),
                const SizedBox(height: 16),
                _buildEmergencyContactCard(user['emergencyContact']['contact']),
                const SizedBox(height: 16),
                _buildVitalsCard(user['sensor']['heartrate']),
                const SizedBox(height: 16),
                _buildLocationCard(user['location']),
                const SizedBox(height: 16),
                _buildStatusCard(user['motion'], user['sos']),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic>? profile) {
    final name = profile?['name'] ?? 'N/A';
    final age = profile?['age'] ?? 'N/A';
    final sex = profile?['sex'] ?? 'N/A';

    return Card(
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.person, size: 40),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Age: $age, Sex: $sex'),
      ),
    );
  }

  Widget _buildEmergencyContactCard(Map<String, dynamic>? contact) {
    final name = contact?['name'] ?? 'N/A';
    final phone = contact?['phone']?.toString() ?? 'N/A';

    return Card(
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.contact_phone, size: 40),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Phone: $phone'),
      ),
    );
  }

  Widget _buildVitalsCard(Map<String, dynamic>? heartrate) {
    final bpm = heartrate?['bpm'] ?? 'N/A';
    final oxygen = heartrate?['oxygen'] ?? 'N/A';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildVital('Heart Rate', '$bpm BPM', Icons.favorite, Colors.red),
            _buildVital('Oxygen', '$oxygen %', Icons.local_fire_department, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildVital(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }


  Widget _buildLocationCard(Map<String, dynamic>? location) {
    final address = location?['address'] ?? 'Fetching location...';
    final lat = location?['latitude']?.toStringAsFixed(5) ?? 'N/A';
    final lng = location?['longitude']?.toStringAsFixed(5) ?? 'N/A';
    final isPressed = location?['isPressed'] ?? false;

    return Card(
      elevation: 4,
      color: isPressed ? Colors.yellow[200] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(child: Text(address)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Coordinates: ($lat, $lng)'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic>? motion, Map<String, dynamic>? sos) {
    final fallDetected = motion?['fallDetected'] ?? false;
    final sosActive = sos?['active'] ?? false;

    return Card(
      elevation: 4,
      color: (fallDetected || sosActive) ? Colors.red[300] : Colors.green[300],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem('Fall Detected', fallDetected),
            _buildStatusItem('SOS Active', sosActive),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isActive) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 8),
        Icon(
          isActive ? Icons.warning : Icons.check_circle,
          color: Colors.white,
          size: 40,
        ),
      ],
    );
  }
}