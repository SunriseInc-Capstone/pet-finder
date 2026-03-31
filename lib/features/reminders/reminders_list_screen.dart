import 'package:flutter/material.dart';
import 'package:petalert/shared/models/reminder.dart';
import 'package:petalert/shared/services/reminder_firestore_service.dart';
import 'package:petalert/shared/services/reminder_notification_service.dart';
import 'add_edit_reminder_screen.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  final ReminderFirestoreService _service = ReminderFirestoreService();

  List<Reminder> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _service.streamReminders().listen((list) {
      list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    });
  }

  Future<void> _add() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditReminderScreen()),
    );
  }

  Future<void> _edit(Reminder r, int index) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditReminderScreen(existing: r, index: index),
      ),
    );
  }

  Future<void> _toggleDone(int index) async {
    await _service.toggleDone(_items[index]);
  }

  Future<void> _delete(int index) async {
    final reminder = _items[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text('This will remove the reminder permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ReminderNotificationService.instance.cancelReminder(reminder.id);
    await _service.deleteReminder(reminder.id);
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal().toString();
    return local.substring(0, 16);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(
                    child: Text(
                      'No reminders yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final r = _items[i];
                      final overdue =
                          !r.done && r.dueAt.isBefore(DateTime.now());

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: r.done,
                            onChanged: (_) => _toggleDone(i),
                          ),
                          title: Text(
                            r.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: r.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${_fmt(r.dueAt)}'
                            '${r.petName != null ? ' • ${r.petName}' : ''}'
                            '${overdue ? ' • OVERDUE' : ''}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _edit(r, i);
                              if (v == 'delete') _delete(i);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                          onTap: () => _edit(r, i),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}