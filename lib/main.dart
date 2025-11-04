import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:petalert/features/pet_profile/add_pet_screen.dart';
import 'package:petalert/features/pet_profile/pet_list_screen.dart';

void main() => runApp(const PetAlertApp());

class PetAlertApp extends StatelessWidget {
  const PetAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    return MaterialApp(
      title: 'PetAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
          if (ok == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pet saved!')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer.withValues(alpha: 0.8),
              cs.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HERO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cs.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pets_rounded, size: 50, color: Colors.teal),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Welcome to PetAlert\nKeep your pets safe & organized.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'Main Features',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // NOTE: no 'const' here because one tile uses context in onTap.
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _FeatureCard(
                      'Pet Profiles',
                      Icons.badge_rounded,
                      Colors.teal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PetListScreen()),
                        );
                      },
                    ),
                    const _FeatureCard('Contacts', Icons.contact_phone_rounded, Colors.indigo),
                    const _FeatureCard('Missing Alert', Icons.campaign_rounded, Colors.orange),
                    const _FeatureCard('Reminders', Icons.event_available_rounded, Colors.pinkAccent),
                    const _FeatureCard('Tips & Foods', Icons.health_and_safety_rounded, Colors.green),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  color: cs.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_box_rounded, color: Colors.teal),
                        title: const Text('Add your first pet'),
                        subtitle: const Text('Name, species, age, photo'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () async {
                          final ok = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (_) => const AddPetScreen()),
                          );
                          if (ok == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pet saved!')),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.share_rounded, color: Colors.orange),
                        title: Text('Create a missing alert'),
                        subtitle: Text('Generate sharable text/poster'),
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ),
                    ],
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

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap; // 

  const _FeatureCard(this.title, this.icon, this.color, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap, // 
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
