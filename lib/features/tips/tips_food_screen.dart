import 'package:flutter/material.dart';
import 'package:petalert/shared/data/toxic_food_data.dart';
import 'package:petalert/shared/models/toxic_food.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class TipsFoodScreen extends StatefulWidget {
  const TipsFoodScreen({super.key});

  @override
  State<TipsFoodScreen> createState() => _TipsFoodScreenState();
}

class _TipsFoodScreenState extends State<TipsFoodScreen> {
  String _query = 'Toxic';

  // --- NEW CHATGPT HELPER FUNCTIONS START ---
  String _emergencyText() {
    return '🚨 PetAlert: Possible toxic ingestion.\n'
        'If severe symptoms (collapse, seizures, trouble breathing), go to an ER vet now.\n'
        'Otherwise, contact your vet ASAP.\n'
        'Include: what was eaten, how much, pet weight, and time of ingestion.';
  }

  Future<void> _copyEmergency() async {
    await Clipboard.setData(ClipboardData(text: _emergencyText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied emergency message')),
    );
  }
  // --- NEW CHATGPT HELPER FUNCTIONS END ---

  List<ToxicFood> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return toxicFoods;
    return toxicFoods.where((x) {
      return x.name.toLowerCase().contains(q) ||
          x.category.toLowerCase().contains(q) ||
          x.shortInfo.toLowerCase().contains(q);
    }).toList();
  }

  IconData _iconFor(String cat) {
    switch (cat) {
      case 'Toxic':
        return Icons.warning_rounded;
      case 'Safe':
        return Icons.check_circle_rounded;
      case 'Emergency':
        return Icons.local_hospital_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Toxic Foods'),
        actions: [
          IconButton(
            tooltip: 'Share emergency info',
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                'PetAlert — If your pet ate something toxic: contact your vet immediately. '
                'If severe symptoms, go to an emergency vet right away.',
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search (e.g., chocolate, grapes)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _Chip(
                    text: 'Toxic',
                    selected: _query == 'Toxic',
                    onTap: () => setState(() => _query = 'Toxic'),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    text: 'Safe',
                    selected: _query == 'Safe',
                    onTap: () => setState(() => _query = 'Safe'),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    text: 'Emergency',
                    selected: _query == 'Emergency',
                    onTap: () => setState(() => _query = 'Emergency'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- NEW CHATGPT EMERGENCY CARD START ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_hospital_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Emergency quick guide',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _emergencyText(),
                              style: const TextStyle(height: 1.25),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _copyEmergency,
                                  icon: const Icon(Icons.copy_rounded),
                                  label: const Text('Copy'),
                                ),
                                FilledButton.icon(
                                  onPressed: () => Share.share(_emergencyText()),
                                  icon: const Icon(Icons.share_rounded),
                                  label: const Text('Share'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --- NEW CHATGPT EMERGENCY CARD END ---

            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No matches found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final x = items[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primary.withValues(alpha: 0.15),
                              child: Icon(_iconFor(x.category), color: cs.primary),
                            ),
                            title: Text(
                              x.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text('${x.category} • ${x.shortInfo}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(x.details),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}