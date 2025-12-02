import 'package:shared_preferences/shared_preferences.dart';
import 'package:petalert/shared/models/missing_alert.dart';

/// Simple local storage for MissingAlert objects.
///
/// For Sprint 3 this uses SharedPreferences with a String list,
/// same pattern as PetStorage, so everything stays consistent.
class MissingAlertStorage {
  static const _key = 'missing_alerts_list';

  /// Save the full list of alerts.
  static Future<void> saveAlerts(List<MissingAlert> alerts) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert each alert to a JSON string.
    final jsonList = alerts.map((a) => a.toJson()).toList();

    await prefs.setStringList(_key, jsonList);
  }

  /// Load all alerts. Returns an empty list if none are saved yet.
  static Future<List<MissingAlert>> loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);

    if (jsonList == null) return [];

    final alerts = jsonList
        .map((j) => MissingAlert.fromJson(j))
        .toList();

    // Optional: sort so newest alerts appear first
    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return alerts;
  }

  /// Remove all saved alerts (useful for testing / reset).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
