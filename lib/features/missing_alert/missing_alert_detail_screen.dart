import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:petalert/shared/models/missing_alert.dart';
import 'package:petalert/shared/services/missing_alert_storage.dart';

class MissingAlertDetailScreen extends StatefulWidget {
  final MissingAlert alert;
  final int index;

  const MissingAlertDetailScreen({
    super.key,
    required this.alert,
    required this.index,
  });

  @override
  State<MissingAlertDetailScreen> createState() =>
      _MissingAlertDetailScreenState();
}

class _MissingAlertDetailScreenState extends State<MissingAlertDetailScreen> {
  late MissingAlert _alert;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _alert = widget.alert;
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Not set';
    final s = dt.toLocal().toString();
    return s.substring(0, 16); // yyyy-MM-dd HH:mm
  }

  bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  Future<void> _toggleStatus() async {
    final newStatus =
        _alert.status.toLowerCase() == 'active' ? 'resolved' : 'active';

    setState(() => _updating = true);
    try {
      final list = await MissingAlertStorage.loadAlerts();

      int idx = widget.index;
      if (idx < 0 || idx >= list.length || list[idx].id != _alert.id) {
        idx = list.indexWhere((a) => a.id == _alert.id);
      }
      if (idx == -1) return;

      final updated = _alert.copyWith(status: newStatus);
      list[idx] = updated;
      await MissingAlertStorage.saveAlerts(list);

      setState(() => _alert = updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'active'
                ? 'Alert marked as Active.'
                : 'Alert marked as Resolved.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _deleteAlert() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this missing alert?'),
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

    final list = await MissingAlertStorage.loadAlerts();
    list.removeWhere((a) => a.id == _alert.id);
    await MissingAlertStorage.saveAlerts(list);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  /// ✅ “Share output” = this text
  void _shareAlert() {
    final b = StringBuffer();

    b.writeln('🚨 Missing Pet Alert: ${_alert.petName}');
    b.writeln('');

    if (_hasText(_alert.lastSeenLocation)) {
      b.writeln('📍 Last seen near: ${_alert.lastSeenLocation!.trim()}');
    }

    if (_alert.lastSeenAt != null) {
      b.writeln('🕒 When: ${_formatDateTime(_alert.lastSeenAt)}');
    }

    // ✅ NEW: optional details
    if (_hasText(_alert.microchipId)) {
      b.writeln('🧾 Microchip ID: ${_alert.microchipId!.trim()}');
    }
    if (_hasText(_alert.distinguishingMarks)) {
      b.writeln('🔎 Distinguishing marks: ${_alert.distinguishingMarks!.trim()}');
    }

    if (_hasText(_alert.notes)) {
      b.writeln('');
      b.writeln('ℹ️ Details: ${_alert.notes!.trim()}');
    }

    if (_hasText(_alert.contactName) || _hasText(_alert.contactPhone)) {
      b.writeln('');
      b.write('📞 Contact: ');
      if (_hasText(_alert.contactName)) {
        b.write(_alert.contactName!.trim());
        if (_hasText(_alert.contactPhone)) b.write(' – ');
      }
      if (_hasText(_alert.contactPhone)) {
        b.write(_alert.contactPhone!.trim());
      }
      b.writeln();
    }

    b.writeln('');
    b.writeln('Shared via PetAlert 🐾');

    Share.share(b.toString());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _alert.status.toLowerCase() == 'active';
    final statusColor = isActive ? Colors.redAccent : Colors.green;
    final statusLabel = isActive ? 'Active (still missing)' : 'Resolved';

    return Scaffold(
      appBar: AppBar(
        title: Text('Alert: ${_alert.petName}'),
        actions: [
          IconButton(
            onPressed: _shareAlert,
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share alert',
          ),
          IconButton(
            onPressed: _deleteAlert,
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Delete alert',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.campaign_rounded, size: 48, color: cs.primary),
                    const SizedBox(height: 12),
                    Text(
                      _alert.petName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _InfoSection(
                title: 'Last seen',
                children: [
                  _InfoRow(
                    label: 'Location',
                    value: _alert.lastSeenLocation ?? 'Not provided',
                  ),
                  _InfoRow(
                    label: 'When',
                    value: _formatDateTime(_alert.lastSeenAt),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ NEW SECTION
              _InfoSection(
                title: 'Optional details',
                children: [
                  _InfoRow(
                    label: 'Microchip ID',
                    value: _hasText(_alert.microchipId)
                        ? _alert.microchipId!.trim()
                        : 'Not provided',
                  ),
                  _InfoRow(
                    label: 'Marks',
                    value: _hasText(_alert.distinguishingMarks)
                        ? _alert.distinguishingMarks!.trim()
                        : 'Not provided',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _InfoSection(
                title: 'Contact',
                children: [
                  _InfoRow(
                    label: 'Name',
                    value: _alert.contactName ?? 'Not provided',
                  ),
                  _InfoRow(
                    label: 'Phone',
                    value: _alert.contactPhone ?? 'Not provided',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _InfoSection(
                title: 'Notes',
                children: [
                  Text(
                    (!_hasText(_alert.notes)) ? 'No extra notes.' : _alert.notes!.trim(),
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _InfoSection(
                title: 'Meta',
                children: [
                  _InfoRow(
                    label: 'Created at',
                    value: _formatDateTime(_alert.createdAt),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _updating ? null : _toggleStatus,
                      icon: _updating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.restart_alt_rounded,
                            ),
                      label: Text(isActive ? 'Mark as Resolved' : 'Mark as Active'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteAlert,
                      icon: const Icon(Icons.delete_outline_rounded),
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

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
