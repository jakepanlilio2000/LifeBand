import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/providers/providers.dart';

class EditEmergencyContactScreen extends ConsumerStatefulWidget {
  const EditEmergencyContactScreen({super.key});

  @override
  ConsumerState<EditEmergencyContactScreen> createState() => _EditEmergencyContactScreenState();
}

class _EditEmergencyContactScreenState extends ConsumerState<EditEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userStreamProvider).value;
    _nameController = TextEditingController(text: user?['emergencyContact']?['contact']?['name'] ?? '');
    _phoneController = TextEditingController(text: user?['emergencyContact']?['contact']?['phone']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final updatedContact = {
        'name': _nameController.text,
        'phone': int.tryParse(_phoneController.text) ?? 0,
      };
      ref.read(firebaseServiceProvider).updateEmergencyContact(updatedContact).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency contact updated successfully!')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update contact: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Emergency Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Contact Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}