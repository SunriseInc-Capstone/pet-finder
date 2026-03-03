import 'package:flutter/material.dart';
import 'package:petalert/shared/models/missing_alert.dart';

// --- NEW IMPORT ---
import 'package:petalert/shared/services/missing_alert_firestore_service.dart';

import 'package:petalert/features/missing_alert/create_missing_alert_screen.dart';
import 'package:petalert/features/missing_alert/missing_alert_detail_screen.dart';

class MissingAlertListScreen extends StatefulWidget {
  const MissingAlertListScreen({super.key});

  @override
  State<MissingAlertListScreen> createState() => _MissingAlertListScreenState();
}

class _MissingAlertListScreenState extends State<MissingAlertListScreen> {
  // Initialize the new Firestore service
  final svc = MissingAlertFirestoreService();

  Future<void> _addAlert() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateMissingAlertScreen()),
    );
    // No need to reload manually anymore! StreamBuilder does it automatically.
  }

  // Updated to use Firestore
  Future<void> _deleteAlert(MissingAlert alert) async {
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

    // Delete directly from Firestore
    await svc.deleteAlert(alert.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missing Alerts'),
        // Removed the refresh button because Firestore updates live automatically!
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addAlert,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add_alert_rounded),
      ),

      // Use StreamBuilder for real-time cloud data
      body: SafeArea(
        child: StreamBuilder<List<MissingAlert>>(
          stream: svc.streamAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final alerts = snapshot.data ?? [];

            if (alerts.isEmpty) {
              return const _EmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: alerts.length,
              itemBuilder: (context, i) {
                final alert = alerts[i];

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
                    await _deleteAlert(alert);
                    return false; // Let StreamBuilder handle UI removal
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MissingAlertDetailScreen(
                              alert: alert,
                              index: i,
                            ),
                          ),
                        );
                      },
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

// UI components kept exactly the same!
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