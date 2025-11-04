import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petalert/shared/models/pet.dart';
import 'package:petalert/shared/services/pet_storage.dart';
import 'add_pet_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List<Pet> _pets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final list = await PetStorage.loadPets();
    setState(() {
      _pets = list;
      _loading = false;
    });
  }

  Future<void> _addPet() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddPetScreen()),
    );
    if (ok == true) _loadPets();
  }

  Future<void> _editPet(Pet pet, int index) async {
    // open AddPetScreen pre-filled with this pet
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddPetScreen(
          existingPet: pet,
          index: index,
        ),
      ),
    );
    if (ok == true) _loadPets();
  }

  Future<void> _deletePet(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet'),
        content: const Text('Are you sure you want to delete this pet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final pets = List<Pet>.from(_pets)..removeAt(index);
    await PetStorage.savePets(pets);
    setState(() => _pets = pets);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profiles'),
        actions: [
          IconButton(onPressed: _loadPets, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPet,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _pets.isEmpty
                ? const Center(
                    child: Text(
                      'No pets added yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _pets.length,
                    itemBuilder: (context, i) {
                      final pet = _pets[i];
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
                          await _deletePet(i);
                          return false; // handled manually
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
                              onPressed: () => _editPet(pet, i),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
