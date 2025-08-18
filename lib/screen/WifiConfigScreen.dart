import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class WifiConfigScreen extends StatefulWidget {
  const WifiConfigScreen({super.key});

  @override
  _WifiConfigScreenState createState() => _WifiConfigScreenState();
}

class _WifiConfigScreenState extends State<WifiConfigScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // A variable to store the selected ESP32 device
  BluetoothDevice? _selectedDevice;
  // A list to store discovered Bluetooth devices
  List<BluetoothDevice> _devices = [];
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  // Method to start Bluetooth device discovery
  void _startDiscovery() async {
    // Conceptual: In a real app, this would use FlutterBluetoothSerial.instance.startDiscovery()
    // For this example, we'll simulate a list of devices
    setState(() {
      _devices = [
        const BluetoothDevice(
          name: 'ESP32_LifeBand_A1',
          address: '01:23:45:67:89:AB',
        ),
        const BluetoothDevice(
          name: 'HC-05_Module',
          address: 'AC:A1:B2:C3:D4:E5',
        ),
      ];
    });
  }

  // Method to connect to a selected Bluetooth device
  Future<void> _connectToDevice() async {
    if (_selectedDevice == null) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      // Conceptual: In a real app, you would connect to the device
      // e.g., BluetoothConnection.toAddress(_selectedDevice!.address);
      await Future.delayed(const Duration(seconds: 2)); // Simulate connection delay

      _showSuccessDialog('Connected to ${_selectedDevice!.name}');
    } catch (e) {
      _showErrorDialog('Failed to connect to device.');
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  // Method to send Wi-Fi credentials to the connected device
  Future<void> _sendCredentials() async {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();

    if (ssid.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter Wi-Fi credentials.');
      return;
    }

    if (_selectedDevice == null) {
      _showErrorDialog('Please select a device first.');
      return;
    }

    try {
      // Conceptual: This is where you would write the data to the Bluetooth stream
      // e.g., connection.output.add(utf8.encode('{"ssid": "$ssid", "password": "$password"}'));
      // The ESP32 firmware would need to parse this JSON string

      _showSuccessDialog('Wi-Fi credentials sent successfully!');
    } catch (e) {
      _showErrorDialog('Failed to send credentials.');
    }
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Configuration'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Bluetooth Device',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<BluetoothDevice>(
              isExpanded: true,
              value: _selectedDevice,
              hint: const Text('Select your LifeBand device'),
              items: _devices.map((device) {
                return DropdownMenuItem<BluetoothDevice>(
                  value: device,
                  child: Text(device.name!),
                );
              }).toList(),
              onChanged: (device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isConnecting ? null : _connectToDevice,
              child: _isConnecting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Connect to Device'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter Wi-Fi Credentials',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Wi-Fi Name (SSID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Wi-Fi Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _sendCredentials,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Send Credentials',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}