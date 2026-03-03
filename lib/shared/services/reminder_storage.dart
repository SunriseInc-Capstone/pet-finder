import 'package:shared_preferences/shared_preferences.dart';
import 'package:petalert/shared/models/reminder.dart';

class ReminderStorage {
  static const _key = 'reminders';

  static Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => Reminder.fromJson(s)).toList();
  }

  static Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final list = reminders.map((r) => r.toJson()).toList();
    await prefs.setStringList(_key, list);
  }
}