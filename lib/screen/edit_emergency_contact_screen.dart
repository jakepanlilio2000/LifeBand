// lib/screen/edit_emergency_contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeband/providers/providers.dart';
import 'package:lifeband/screen/add_edit_contact_screen.dart';

class EditEmergencyContactScreen extends ConsumerWidget {
  const EditEmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userStreamProvider);

    final contactsData = userData.when<Map<String, dynamic>?>(
      data: (user) => user?['emergencyContacts'] as Map<String, dynamic>?,
      loading: () => null,
      error: (e, s) => null,
    );

    final sortedContactKeys = contactsData?.keys.toList();
    // A simple sort by key name, which might not be chronological.
    sortedContactKeys?.sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditContactScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: sortedContactKeys == null || sortedContactKeys.isEmpty
          ? const Center(child: Text('No contacts found. Add one!'))
          : ListView.builder(
        itemCount: sortedContactKeys.length,
        itemBuilder: (context, index) {
          final key = sortedContactKeys[index];
          final contact = contactsData![key] as Map<String, dynamic>;
          final name = contact['name'] ?? 'No Name';
          final phone = contact['phone']?.toString() ?? 'No Phone';

          return ListTile(
            title: Text(name),
            subtitle: Text(phone),
            leading: CircleAvatar(
              child: Text((index + 1).toString()),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditContactScreen(
                          contactKey: key,
                          initialContact: contact,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Contact?'),
                        content: Text('Are you sure you want to delete $name?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                        false;

                    if (confirm) {
                      // MODIFIED: No longer needs a UID.
                      try {
                        await ref.read(firebaseServiceProvider).removeEmergencyContact(key);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact removed')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}