import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:petalert/shared/models/pet.dart';
import 'package:petalert/shared/services/pet_storage.dart';

class AddPetScreen extends StatefulWidget {
  final Pet? existingPet;   // if provided -> edit mode
  final int? index;         // position in list when editing

  const AddPetScreen({this.existingPet, this.index, super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _species = 'Dog';
  File? _photoFile;

  final _picker = ImagePicker();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Prefill when editing
    final pet = widget.existingPet;
    if (pet != null) {
      _nameCtrl.text = pet.name;
      _species = pet.species;
      if (pet.age != null) _ageCtrl.text = pet.age!.toString();
      _notesCtrl.text = pet.notes ?? '';
      if (pet.photoPath != null) _photoFile = File(pet.photoPath!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource src) async {
    final picked = await _picker.pickImage(
      source: src,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      // Keep same id when editing; otherwise generate a new one.
      final id = widget.existingPet?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final age = _ageCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_ageCtrl.text.trim());

      // If user didn’t change photo in edit mode, retain existing path.
      final photoPath =
          _photoFile?.path ?? widget.existingPet?.photoPath;

      final pet = Pet(
        id: id,
        name: _nameCtrl.text.trim(),
        species: _species,
        age: age,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        photoPath: photoPath,
      );

      final list = await PetStorage.loadPets();

      if (widget.index != null &&
          widget.index! >= 0 &&
          widget.index! < list.length) {
        // Edit
        list[widget.index!] = pet;
      } else {
        // Add
        list.add(pet);
      }

      await PetStorage.savePets(list);

      if (!mounted) return;
      Navigator.of(context).pop(true); // success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existingPet != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Pet' : 'Add Pet')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Photo picker
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showPhotoPickerSheet,
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: cs.primary.withValues(alpha: 0.15),
                          backgroundImage:
                              _photoFile != null ? FileImage(_photoFile!) : null,
                          child: _photoFile == null
                              ? Icon(Icons.camera_alt_rounded, color: cs.primary)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _photoFile == null && widget.existingPet?.photoPath == null
                                ? 'Add a photo (optional)'
                                : 'Photo selected',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.edit_rounded, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Pet name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _species, // non-deprecated
                  items: const [
                    DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                    DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                    DropdownMenuItem(value: 'Bird', child: Text('Bird')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _species = v ?? 'Dog'),
                  decoration: const InputDecoration(labelText: 'Species'),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Age (years, optional)'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 50) return 'Enter a valid age';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_saving
                        ? (isEdit ? 'Saving changes...' : 'Saving...')
                        : (isEdit ? 'Save Changes' : 'Save Pet')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoPickerSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
