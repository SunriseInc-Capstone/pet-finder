import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petalert/shared/models/pet.dart';

class PetFirestoreService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _petsRef {
    // users/{uid}/pets/{petId}
    return _db.collection('users').doc(_uid).collection('pets');
  }

  /// Live stream of pets for the currently logged-in user.
  Stream<List<Pet>> streamPets() {
    return _petsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Pet.fromFirestore(d.id, d.data())).toList());

  }

  /// Add a new pet
  Future<void> addPet(Pet pet) async {
    await _petsRef.doc(pet.id).set({
      ...pet.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update existing pet
  Future<void> updatePet(Pet pet) async {
    await _petsRef.doc(pet.id).set({
      ...pet.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete pet
  Future<void> deletePet(String petId) async {
    await _petsRef.doc(petId).delete();
  }
}
