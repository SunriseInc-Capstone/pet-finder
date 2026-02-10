import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petalert/shared/models/pet.dart';
import 'package:petalert/shared/services/pet_firestore_service.dart';
import 'add_pet_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final _petFs = PetFirestoreService();

  Future<void> _addPet() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddPetScreen()),
    );
    // no manual reload needed (StreamBuilder updates automatically)
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet saved to Firestore')),
      );
    }
  }

  Future<void> _editPet(Pet pet) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddPetScreen(existingPet: pet),
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved')),
      );
    }
  }

  Future<void> _deletePet(Pet pet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Delete ${pet.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    await _petFs.deletePet(pet.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profiles'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPet,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Pet>>(
          stream: _petFs.streamPets(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Firestore error:\n${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final pets = snapshot.data!;
            if (pets.isEmpty) {
              return const Center(
                child: Text(
                  'No pets added yet.\nTap + to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pets.length,
              itemBuilder: (context, i) {
                final pet = pets[i];

                return Dismissible(
                  key: ValueKey(pet.id),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    await _deletePet(pet);
                    return false; // we delete ourselves
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: cs.primary.withValues(alpha: 0.2),
                        backgroundImage: (pet.photoPath != null && File(pet.photoPath!).existsSync())
                            ? FileImage(File(pet.photoPath!))
                            : null,
                        child: (pet.photoPath == null)
                            ? const Icon(Icons.pets_rounded, size: 30)
                            : null,
                      ),
                      title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${pet.species}${pet.age != null ? '  •  ${pet.age} yr' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () => _editPet(pet),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
