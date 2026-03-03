import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:petalert/shared/models/contact.dart';

class ContactFirestoreService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('users').doc(_uid).collection('contacts');

  Stream<List<Contact>> watchContacts() {
    return _ref.orderBy('isPrimary', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        // Ensure id always exists even if doc id differs
        data['id'] = data['id'] ?? d.id;
        return Contact.fromMap(_normalizeTimestamps(data));
      }).toList();
    });
  }

  Future<void> upsertContact(Contact c) async {
    final now = DateTime.now();
    final data = {
      ...c.toMap(),
      'updatedAt': now.toIso8601String(),
      'createdAt': (c.createdAt ?? now).toIso8601String(),
    };

    // store using contact id as doc id
    await _ref.doc(c.id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteContact(String id) async {
    await _ref.doc(id).delete();
  }

  /// Firestore Timestamp compatibility if anyone stored Timestamp previously
  Map<String, dynamic> _normalizeTimestamps(Map<String, dynamic> m) {
    DateTime? toDt(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final created = toDt(m['createdAt']);
    final updated = toDt(m['updatedAt']);
    return {
      ...m,
      'createdAt': created?.toIso8601String(),
      'updatedAt': updated?.toIso8601String(),
    };
  }
}