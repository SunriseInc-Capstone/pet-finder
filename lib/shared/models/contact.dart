import 'dart:convert';

class Contact {
  final String id;
  final String name;
  final String phone;
  final String? relationship; // e.g., Owner, Friend, Vet
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'isPrimary': isPrimary,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'] as String,
        name: (map['name'] as String?) ?? '',
        phone: (map['phone'] as String?) ?? '',
        relationship: map['relationship'] as String?,
        isPrimary: (map['isPrimary'] as bool?) ?? false,
        createdAt: map['createdAt'] == null
            ? null
            : DateTime.tryParse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] == null
            ? null
            : DateTime.tryParse(map['updatedAt'] as String),
      );

  String toJson() => jsonEncode(toMap());
  factory Contact.fromJson(String source) =>
      Contact.fromMap(jsonDecode(source) as Map<String, dynamic>);
}