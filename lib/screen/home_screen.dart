import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/WifiConfigScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<Position>? _positionStreamSubscription;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profileAgeController = TextEditingController();
  final TextEditingController _profileSexController = TextEditingController();


  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _firebaseService.startFallDetectionListener(); // Start listening for fall events
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _profileNameController.dispose();
    _profileAgeController.dispose();
    _profileSexController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(UserModel user) {
    _profileNameController.text = user.profileName;
    _profileAgeController.text = user.profileAge.toString();
    _profileSexController.text = user.profileSex;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Wristband User Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _profileNameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _profileAgeController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(
                  controller: _profileSexController,
                  decoration: const InputDecoration(labelText: 'Sex'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final newName = _profileNameController.text.trim();
                final newAge = int.tryParse(_profileAgeController.text.trim()) ?? 0;
                final newSex = _profileSexController.text.trim();

                if (newName.isNotEmpty && newAge > 0 && newSex.isNotEmpty) {
                  _firebaseService.updateWristbandProfile(newName, newAge, newSex);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid details.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _startLocationUpdates() async {
    final hasPermission = await _firebaseService.getCurrentLocation();
    if (hasPermission != null) {
      _firebaseService.updateLocationInFirebase(hasPermission);
      _positionStreamSubscription = _firebaseService.getLocationStream().listen((Position position) {
        _firebaseService.updateLocationInFirebase(position);
        print("Location updated: Lat ${position.latitude}, Lon ${position.longitude}");
      }, onError: (e) {
        print("Error in location stream: $e");
      });
    } else {
      print("Could not get initial location or permission denied.");
    }
  }

  void _showEditContactDialog(UserModel user) {
    _nameController.text = user.emergencyContactName;
    _phoneController.text = user.emergencyContactPhone.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Emergency Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final newName = _nameController.text.trim();
                final newPhone = int.tryParse(_phoneController.text.trim()) ?? 0;

                if (newName.isNotEmpty && newPhone > 0) {
                  _firebaseService.updateEmergencyContact(newName, newPhone);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid details.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeBand Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<UserModel>(
        stream: _firebaseService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEditableInfoCard(
                  icon: Icons.person,
                  title: 'Wristband User',
                  value: user.profileName,
                  lastUpdated: 'Age: ${user.profileAge}, Sex: ${user.profileSex}',
                  iconColor: Colors.teal,
                  onEditPressed: () => _showEditProfileDialog(user),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.favorite,
                  title: 'Heart Rate',
                  value: '${user.currentHeartRate} BPM',
                  lastUpdated: user.heartRateLastUpdated,
                  iconColor: Colors.red,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.warning,
                  title: 'Fall Detection',
                  value: user.fallDetected ? 'Fall Detected!' : 'Normal',
                  lastUpdated: user.motionLastUpdated,
                  iconColor: user.fallDetected ? Colors.orange : Colors.green,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Location',
                  value: user.address,
                  lastUpdated: 'Lat: ${user.latitude}, Lon: ${user.longitude}',
                  iconColor: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildEditableInfoCard(
                  icon: Icons.contact_phone,
                  title: 'Emergency Contact',
                  value: '${user.emergencyContactName} - ${user.emergencyContactPhone}',
                  lastUpdated: "On file",
                  iconColor: Colors.purple,
                  onEditPressed: () => _showEditContactDialog(user),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to a new Bluetooth/Wi-Fi configuration screen
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => WifiConfigScreen()));
                  },
                  child: const Text('Configure Device Wi-Fi'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _firebaseService.toggleSos(user.sosActive),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.sosActive ? Colors.grey : Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    user.sosActive ? 'SOS ACTIVE' : 'SEND SOS',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 8),
                Center(child: Text("Last SOS update: ${user.sosLastUpdated}", style: TextStyle(color: Colors.grey[600]))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String lastUpdated,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last Updated: $lastUpdated',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String lastUpdated,
    required Color iconColor,
    VoidCallback? onEditPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last Updated: $lastUpdated',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (onEditPressed != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: onEditPressed,
              ),
          ],
        ),
      ),
    );
  }
}