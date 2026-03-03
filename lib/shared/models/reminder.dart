import 'dart:convert';

class Reminder {
  final String id;
  final String title;
  final DateTime dueAt;
  final String? petId;
  final String? petName;
  final String? notes;
  final bool done;

  Reminder({
    required this.id,
    required this.title,
    required this.dueAt,
    this.petId,
    this.petName,
    this.notes,
    this.done = false,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dueAt,
    String? petId,
    String? petName,
    String? notes,
    bool? done,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      notes: notes ?? this.notes,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'dueAt': dueAt.toIso8601String(),
        'petId': petId,
        'petName': petName,
        'notes': notes,
        'done': done,
      };

  factory Reminder.fromMap(Map<String, dynamic> map) => Reminder(
        id: map['id'] as String,
        title: map['title'] as String,
        dueAt: DateTime.parse(map['dueAt'] as String),
        petId: map['petId'] as String?,
        petName: map['petName'] as String?,
        notes: map['notes'] as String?,
        done: map['done'] as bool? ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory Reminder.fromJson(String s) => Reminder.fromMap(jsonDecode(s));
}