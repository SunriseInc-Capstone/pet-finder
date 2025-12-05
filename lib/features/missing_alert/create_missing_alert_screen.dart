import 'package:flutter/material.dart';
import 'package:petalert/shared/models/pet.dart';
import 'package:petalert/shared/models/missing_alert.dart';
import 'package:petalert/shared/services/pet_storage.dart';
import 'package:petalert/shared/services/missing_alert_storage.dart';

// We already guard context with `mounted`, so we can safely ignore this lint.
// (prevents the "Don't use BuildContext across async gaps" warning)
// ignore_for_file: use_build_context_synchronously

class CreateMissingAlertScreen extends StatefulWidget {
  const CreateMissingAlertScreen({super.key});

  @override
  State<CreateMissingAlertScreen> createState() =>
      _CreateMissingAlertScreenState();
}

class _CreateMissingAlertScreenState extends State<CreateMissingAlertScreen> {
  final _formKey = GlobalKey<FormState>();

  final _locationCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _loadingPets = true;

  DateTime? _lastSeenAt;
  String _status = 'active'; // 'active' or 'resolved'
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final pets = await PetStorage.loadPets();
    setState(() {
      _pets = pets;
      _selectedPet = pets.isNotEmpty ? pets.first : null;
      _loadingPets = false;
    });
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    setState(() {
      _lastSeenAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Not set';
    final local = dt.toLocal().toString();
    // Simple, no extra package: YYYY-MM-DD HH:MM
    return local.substring(0, 16);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPet == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a pet profile first.')));
      return;
    }

    setState(() => _saving = true);

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();

      final alert = MissingAlert(
        id: id,
        petId: _selectedPet!.id,
        petName: _selectedPet!.name,
        status: _status,
        createdAt: now,
        lastSeenLocation: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        lastSeenAt: _lastSeenAt,
        contactName: _contactNameCtrl.text.trim().isEmpty
            ? null
            : _contactNameCtrl.text.trim(),
        contactPhone: _contactPhoneCtrl.text.trim().isEmpty
            ? null
            : _contactPhoneCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      final current = await MissingAlertStorage.loadAlerts();
      current.add(alert);
      await MissingAlertStorage.saveAlerts(current);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save alert: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Missing Alert')),
      body: SafeArea(
        child: _loadingPets
            ? const Center(child: CircularProgressIndicator())
            : _pets.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets_rounded, size: 60, color: cs.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Add a pet profile first',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'To create a missing alert, you need at least one pet in Pet Profiles.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet selector
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPet?.id, // 👈 replaces `value`
                        items: _pets
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _selectedPet = _pets.firstWhere((p) => p.id == id);
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select pet',
                        ),
                        validator: (v) =>
                            v == null ? 'Please select a pet' : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _locationCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Last seen location',
                          hintText: 'e.g., Near UNT Campus, Denton',
                        ),
                      ),

                      const SizedBox(height: 12),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Last seen date & time'),
                        subtitle: Text(_formatDateTime(_lastSeenAt)),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today_rounded),
                          onPressed: _pickDateTime,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _contactNameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Contact name (optional)',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _contactPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact phone (optional)',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'Collar color, microchip, behavior, etc.',
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _status, // 👈 replaces `value`
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active (still missing)'),
                          ),
                          DropdownMenuItem(
                            value: 'resolved',
                            child: Text('Resolved (found)'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _status = v);
                        },
                        decoration: const InputDecoration(labelText: 'Status'),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(_saving ? 'Saving...' : 'Save Alert'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
