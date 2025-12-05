import 'package:flutter/material.dart';
import 'package:petalert/shared/models/missing_alert.dart';
import 'package:petalert/shared/services/missing_alert_storage.dart';

import 'package:petalert/features/missing_alert/create_missing_alert_screen.dart';
import 'package:petalert/features/missing_alert/missing_alert_detail_screen.dart';

class MissingAlertListScreen extends StatefulWidget {
  const MissingAlertListScreen({super.key});

  @override
  State<MissingAlertListScreen> createState() => _MissingAlertListScreenState();
}

class _MissingAlertListScreenState extends State<MissingAlertListScreen> {
  List<MissingAlert> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final list = await MissingAlertStorage.loadAlerts();
    setState(() {
      _alerts = list;
      _loading = false;
    });
  }

  Future<void> _addAlert() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateMissingAlertScreen()),
    );

    if (ok == true) {
      _loadAlerts();
    }
  }

  Future<void> _deleteAlert(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text(
          'Are you sure you want to delete this missing alert?',
        ),
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

    final current = List<MissingAlert>.from(_alerts)..removeAt(index);
    await MissingAlertStorage.saveAlerts(current);

    setState(() => _alerts = current);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missing Alerts'),
        actions: [
          IconButton(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addAlert,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add_alert_rounded),
      ),

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _alerts.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: _loadAlerts,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _alerts.length,
                  itemBuilder: (context, i) {
                    final alert = _alerts[i];

                    return Dismissible(
                      key: ValueKey(alert.id),
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
                        await _deleteAlert(i);
                        return false;
                      },

                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          // Leading status dot
                          leading: _StatusDot(status: alert.status),

                          // Title + subtitle
                          title: Text(
                            alert.petName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (alert.lastSeenLocation != null &&
                                  alert.lastSeenLocation!.isNotEmpty)
                                Text(
                                  'Last seen: ${alert.lastSeenLocation}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (alert.lastSeenAt != null)
                                Text(
                                  'At: ${alert.lastSeenAt}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),

                          // Status badge
                          trailing: _StatusChip(status: alert.status),

                          // 🚀 Open detail screen
                          onTap: () async {
                            final changed = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => MissingAlertDetailScreen(
                                      alert: alert,
                                      index: i,
                                    ),
                                  ),
                                );

                            if (changed == true) {
                              _loadAlerts();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_rounded, size: 60, color: cs.primary),
            const SizedBox(height: 16),
            const Text(
              'No missing alerts yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'If a pet goes missing, you can create an alert to track details and share info quickly.',
              style: TextStyle(fontSize: 14, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.redAccent : Colors.green;

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.redAccent : Colors.green;
    final label = isActive ? 'Active' : 'Resolved';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
