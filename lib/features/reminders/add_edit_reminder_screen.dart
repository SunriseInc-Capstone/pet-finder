import 'package:flutter/material.dart';
import 'package:petalert/shared/models/reminder.dart';
import 'package:petalert/shared/models/pet.dart';
import 'package:petalert/shared/services/pet_storage.dart';
import 'package:petalert/shared/services/reminder_storage.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? existing;
  final int? index;

  const AddEditReminderScreen({super.key, this.existing, this.index});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _dueAt = DateTime.now().add(const Duration(hours: 1));

  List<Pet> _pets = [];
  String? _petId;
  String? _petName;

  bool _loadingPets = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _notesCtrl.text = e.notes ?? '';
      _dueAt = e.dueAt;
      _petId = e.petId;
      _petName = e.petName;
    }

    _loadPets();
  }

  Future<void> _loadPets() async {
    final list = await PetStorage.loadPets(); // still local pets; OK for now
    setState(() {
      _pets = list;
      _loadingPets = false;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );
    if (time == null) return;

    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _fmt(DateTime dt) => dt.toLocal().toString().substring(0, 16);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final id = widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final reminder = Reminder(
        id: id,
        title: _titleCtrl.text.trim(),
        dueAt: _dueAt,
        petId: _petId,
        petName: _petName,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        done: widget.existing?.done ?? false,
      );

      final list = await ReminderStorage.loadReminders();

      if (widget.index != null && widget.index! >= 0 && widget.index! < list.length) {
        list[widget.index!] = reminder;
      } else {
        list.add(reminder);
      }

      await ReminderStorage.saveReminders(list);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Reminder' : 'Add Reminder')),
      body: SafeArea(
        child: _loadingPets
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title (e.g., Vet appointment)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
                      ),
                      const SizedBox(height: 12),

                      if (_pets.isNotEmpty)
                        DropdownButtonFormField<String?>(
                          value: _petId,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('No pet selected')),
                            ..._pets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                          ],
                          onChanged: (id) {
                            setState(() {
                              _petId = id;
                              _petName = id == null ? null : _pets.firstWhere((p) => p.id == id).name;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Link to pet (optional)'),
                        ),

                      const SizedBox(height: 12),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Due date & time'),
                        subtitle: Text(_fmt(_dueAt)),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today_rounded),
                          onPressed: _pickDateTime,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notes (optional)'),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check_rounded),
                          label: Text(_saving ? 'Saving...' : 'Save'),
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