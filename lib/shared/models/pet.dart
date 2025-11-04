import 'dart:convert';

class Pet {
  final String id;         // unique id (e.g., timestamp/uuid)
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'species': species,
        'age': age,
        'notes': notes,
        'photoPath': photoPath,
      };

  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
        id: map['id'] as String,
        name: map['name'] as String,
        species: map['species'] as String,
        age: map['age'] as int?,
        notes: map['notes'] as String?,
        photoPath: map['photoPath'] as String?,
      );

  String toJson() => jsonEncode(toMap());
  factory Pet.fromJson(String source) => Pet.fromMap(jsonDecode(source));
}
