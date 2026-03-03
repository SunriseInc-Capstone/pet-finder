import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petalert/shared/models/missing_alert.dart';

class MissingAlertFirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('users').doc(_uid).collection('missing_alerts');

  Stream<List<MissingAlert>> streamAlerts() {
    return _ref.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => MissingAlert.fromMap(doc.data()))
            .toList();
      },
    );
  }

  Future<void> saveAlert(MissingAlert alert) async {
    await _ref.doc(alert.id).set({
      ...alert.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteAlert(String id) async {
    await _ref.doc(id).delete();
  }
}