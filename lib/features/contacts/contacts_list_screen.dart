import 'package:flutter/material.dart';
import 'package:petalert/features/contacts/add_edit_contact_screen.dart';
import 'package:petalert/shared/models/contact.dart';
import 'package:petalert/shared/services/contact_firestore_service.dart';

class ContactsListScreen extends StatelessWidget {
  // --- NEW: selectMode variable ---
  final bool selectMode;
  
  // --- NEW: updated constructor ---
  const ContactsListScreen({super.key, this.selectMode = false});

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
    );
  }

  Future<void> _openEdit(BuildContext context, Contact c) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditContactScreen(existing: c)),
    );
  }

  Future<void> _delete(BuildContext context, Contact c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Delete "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ContactFirestoreService().deleteContact(c.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final svc = ContactFirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Contact>>(
        stream: svc.watchContacts(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final contacts = snap.data ?? [];
          if (contacts.isEmpty) {
            return const Center(
              child: Text(
                'No contacts yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: contacts.length,
            itemBuilder: (context, i) {
              final c = contacts[i];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.person, color: cs.primary),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (c.isPrimary) const Chip(label: Text('Primary')),
                    ],
                  ),
                  subtitle: Text(
                    '${c.phone}${c.relationship != null ? '  •  ${c.relationship}' : ''}',
                  ),
                  // --- NEW: modified onTap logic ---
                  onTap: () {
                    if (selectMode) {
                      Navigator.of(context).pop(c);
                    } else {
                      _openEdit(context, c);
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _delete(context, c),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}