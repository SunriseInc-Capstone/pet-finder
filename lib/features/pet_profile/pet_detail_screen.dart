import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petalert/shared/models/pet.dart';
import 'package:petalert/shared/services/pet_storage.dart';
import 'add_pet_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  final int index;

  const PetDetailScreen({super.key, required this.pet, required this.index});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  Future<void> _refreshFromStorage() async {
    final all = await PetStorage.loadPets();
    if (widget.index >= 0 && widget.index < all.length) {
      setState(() => _pet = all[widget.index]);
    }
  }

  Future<void> _edit() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddPetScreen(existingPet: _pet, index: widget.index),
      ),
    );
    if (ok == true) {
      await _refreshFromStorage();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet updated')),
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${_pet.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    final list = await PetStorage.loadPets();
    if (widget.index >= 0 && widget.index < list.length) {
      list.removeAt(widget.index);
      await PetStorage.savePets(list);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true); // pop back to list, signal change
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFromStorage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Hero image / avatar
              Hero(
                tag: 'pet-avatar-${_pet.id}',
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.15),
                    image: (_pet.photoPath != null && File(_pet.photoPath!).existsSync())
                        ? DecorationImage(
                            image: FileImage(File(_pet.photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (_pet.photoPath == null)
                      ? Icon(Icons.pets_rounded, size: 64, color: cs.primary)
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _pet.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _Chip(icon: Icons.pets_rounded, label: _pet.species),
                  if (_pet.age != null) _Chip(icon: Icons.cake_rounded, label: '${_pet.age} yr'),
                ],
              ),

              const SizedBox(height: 16),

              if ((_pet.notes ?? '').trim().isNotEmpty)
                _InfoCard(
                  title: 'Notes',
                  child: Text(
                    _pet.notes!.trim(),
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _edit,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
