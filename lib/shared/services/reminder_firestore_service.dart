import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petalert/shared/models/reminder.dart';

class ReminderFirestoreService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _remindersRef {
    return _db.collection('users').doc(_uid).collection('reminders');
  }

  Stream<List<Reminder>> streamReminders() {
    return _remindersRef.snapshots().map((snap) {
      final reminders = snap.docs
          .map((d) => Reminder.fromMap(d.data(), d.id))
          .toList();

      reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));
      return reminders;
    });
  }

  Future<String> addReminder(Reminder reminder) async {
  final doc = _remindersRef.doc();

  await doc.set({
    ...reminder.toMap(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  return doc.id;
}

  Future<void> updateReminder(Reminder reminder) async {
    if (reminder.id.isEmpty) {
      throw ArgumentError('Reminder ID cannot be empty for update');
    }

    await _remindersRef.doc(reminder.id).set({
      ...reminder.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteReminder(String id) async {
    await _remindersRef.doc(id).delete();
  }

  Future<void> toggleDone(Reminder reminder) async {
    await _remindersRef.doc(reminder.id).update({
      'done': !reminder.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}