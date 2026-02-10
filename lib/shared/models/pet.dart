import 'dart:convert';

class Pet {
  final String id;         // Firestore doc id
  final String name;
  final String species;    // Dog, Cat, Bird, etc.
  final int? age;          // years (optional)
  final String? notes;
  final String? photoPath; // local file path (optional)

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.age,
    this.notes,
    this.photoPath,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    int? age,
    String? notes,
    String? photoPath,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      age: age ?? this.age,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  /// For Firestore: DO NOT store `id` inside the map (doc id is the id)
  Map<String, dynamic> toMap() => {
        'name': name,
        'species': species,
        'age': age,
        'notes': notes,
        'photoPath': photoPath,
      };

  /// For local JSON (if you still use it anywhere)
  Map<String, dynamic> toLocalMap() => {
        'id': id,
        'name': name,
        'species': species,
        'age': age,
        'notes': notes,
        'photoPath': photoPath,
      };

  /// For local JSON (old style)
  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
        id: (map['id'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        species: (map['species'] ?? 'Dog') as String,
        age: map['age'] is int ? map['age'] as int : null,
        notes: map['notes'] as String?,
        photoPath: map['photoPath'] as String?,
      );

  /// ✅ For Firestore usage: docId + data map
  factory Pet.fromFirestore(String docId, Map<String, dynamic> data) => Pet(
        id: docId,
        name: (data['name'] ?? '') as String,
        species: (data['species'] ?? 'Dog') as String,
        age: data['age'] is int ? data['age'] as int : null,
        notes: data['notes'] as String?,
        photoPath: data['photoPath'] as String?,
      );

  String toJson() => jsonEncode(toLocalMap());
  factory Pet.fromJson(String source) => Pet.fromMap(jsonDecode(source));
}
