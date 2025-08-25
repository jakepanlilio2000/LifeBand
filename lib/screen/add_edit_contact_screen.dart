// lib/screen/add_edit_contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/providers/providers.dart';

class AddEditContactScreen extends ConsumerStatefulWidget {
  final String? contactKey;
  final Map<String, dynamic>? initialContact;

  const AddEditContactScreen({
    super.key,
    this.contactKey,
    this.initialContact,
  });

  @override
  ConsumerState<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends ConsumerState<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool get isEditing => widget.contactKey != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialContact?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.initialContact?['phone']?.toString() ?? '');
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

      // MODIFIED: The provider is no longer a .family.
      final firebaseService = ref.read(firebaseServiceProvider);

      final future = isEditing
          ? firebaseService.updateEmergencyContact(widget.contactKey!, updatedContact)
          : firebaseService.addEmergencyContact(updatedContact);

      future.then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Contact updated!' : 'Contact added!'),
          ),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
      ),
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
                decoration: const InputDecoration(labelText: 'Contact Phone (e.g., 63921...)'),
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
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}