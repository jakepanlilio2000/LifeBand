import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/providers/providers.dart';
import 'package:lifeband/screen/edit_emergency_contact_screen.dart';
import 'package:lifeband/screen/edit_profile_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
          final profile = user['profile'] as Map<String, dynamic>?;
          final emergencyContact = user['emergencyContact']?['contact'] as Map<String, dynamic>?;
          final heartrate = user['sensor']?['heartrate'] as Map<String, dynamic>?;
          final location = user['location'] as Map<String, dynamic>?;
          final motion = user['motion'] as Map<String, dynamic>?;
          final sos = user['sos'] as Map<String, dynamic>?;


          return RefreshIndicator(
            onRefresh: () async {
              try {
                // 1. Fetch the LATEST user data directly from Firebase
                final latestUserData = await ref.read(firebaseServiceProvider).getCurrentUser();

                if (latestUserData != null) {
                  // 2. Extract coordinates from the fresh data
                  final location = latestUserData['location'] as Map<String, dynamic>?;
                  final lat = location?['latitude'];
                  final lng = location?['longitude'];

                  // 3. Proceed with the update using the latest coordinates
                  if (lat is num && lng is num) {
                    await ref.read(locationServiceProvider).updateAddressFromCoordinates(lat.toDouble(), lng.toDouble());
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coordinates not available to refresh address.')),
                    );
                  }
                }
              } catch (e) {
                // --- ADD THIS CATCH BLOCK ---
                // Handle the timeout error and show a message to the user
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Network error: Could not update address.')),
                );
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileCard(profile),
                const SizedBox(height: 16),
                _buildEmergencyContactCard(emergencyContact),
                const SizedBox(height: 16),
                _buildMapCard(location),
                const SizedBox(height: 16),
                _buildVitalsCard(heartrate),
                const SizedBox(height: 16),
                _buildLocationCard(location),
                const SizedBox(height: 16),
                _buildStatusCard(motion, sos),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMapCard(Map<String, dynamic>? location) {
    final lat = location?['latitude'];
    final lng = location?['longitude'];

    // Only build the map if we have valid coordinates
    if (lat is num && lng is num) {
      final userLocation = LatLng(lat.toDouble(), lng.toDouble());
      return Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias, // Ensures the map respects the card's rounded corners
        child: SizedBox(
          height: 250, // Give the map a fixed height
          child: FlutterMap(
            options: MapOptions(
              initialCenter: userLocation,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.OlfuLB.lifeband', // Replace with your app's package name
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    width: 80,
                    height: 80,
                    child: Icon(Icons.location_pin, size: 60, color: Colors.red.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Return a placeholder if no location is available
    return Card(
      elevation: 4,
      child: Container(
        height: 250,
        alignment: Alignment.center,
        child: const Text('Map data not available.'),
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

    final latNum = double.tryParse(location?['latitude']?.toString() ?? '');
    final lat = latNum != null ? latNum.toStringAsFixed(5) : 'N/A';

    final lngNum = double.tryParse(location?['longitude']?.toString() ?? '');
    final lng = lngNum != null ? lngNum.toStringAsFixed(5) : 'N/A';

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